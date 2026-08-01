#!/usr/bin/env node
/**
 * collect-git-activity.js
 *
 * Deterministic, dependency-free helper for the `monthly-project-update`
 * skill. Discovers every git repo directly under a root folder, pulls the
 * commit log for a date window from EVERY branch, strips out local noise
 * (stash artifacts), extracts issue-tracker ticket references (e.g.
 * PALM-1234, ABC-99), and prints one JSON object to stdout.
 *
 * The agent still does all the *interpretation* (categorizing, writing
 * summary lines, calling out to GitHub/GitLab/Jira/Azure/Linear for richer
 * descriptions) — this script only guarantees the raw git facts are
 * gathered consistently and correctly, without relying on the model to
 * remember to `cd` into each repo or filter out stash commits by hand.
 *
 * Usage:
 *   node collect-git-activity.js --root <dir> --month July --year 2026
 *   node collect-git-activity.js --root <dir> --since 2026-07-14 --until 2026-07-29
 *   node collect-git-activity.js --root <dir> --since 14-07-2026 --until 29-07-2026
 *   node collect-git-activity.js --root <dir> --month July --ticket-prefix PALM
 *
 * All flags:
 *   --root <dir>            Workspace root to scan for repos (default: cwd)
 *   --month <name>          Month name, e.g. "July" (pairs with --year)
 *   --year <yyyy>           Optional, defaults to current year
 *   --since <date>          Explicit range start (inclusive). Accepts
 *                           YYYY-MM-DD or DD-MM-YYYY.
 *   --until <date>          Explicit range end (inclusive, made exclusive
 *                           internally by adding 1 day for `git log`).
 *   --ticket-prefix <KEY>   Force a ticket-key prefix (e.g. "PALM") instead
 *                           of auto-detecting the most common one.
 *
 * Output shape (stdout, JSON):
 * {
 *   "window": { "since": "2026-07-01", "until": "2026-08-01" },
 *   "ticketPrefix": "PALM" | null,
 *   "repos": [
 *     {
 *       "name": "palm-srvr",
 *       "path": "/abs/path/palm-srvr",
 *       "currentBranch": "fix/PALM-2241",
 *       "defaultBranch": "main",
 *       "reachable": true,
 *       "commitCount": 8,
 *       "commits": [
 *         { "hash": "abc123", "date": "2026-07-29", "author": "...",
 *           "subject": "...", "ticketRefs": ["PALM-2241"] }
 *       ],
 *       "ticketRefs": ["PALM-2241", "PALM-2033"]
 *     }
 *   ],
 *   "skipped": [ { "name": "some-folder", "reason": "no .git" } ]
 * }
 */

'use strict';

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const MONTHS = [
  'january', 'february', 'march', 'april', 'may', 'june',
  'july', 'august', 'september', 'october', 'november', 'december',
];

// Local stash artifacts show up in `git log --all` as commits with these
// subject prefixes. They are not real project history and must be dropped.
const STASH_NOISE_RE = /^(WIP on |index on )/i;

// Matches issue-tracker ticket keys like PALM-1234, ABC-9, JIRA-42.
const TICKET_RE = /\b([A-Z][A-Z0-9]{1,9}-\d+)\b/g;

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg.startsWith('--')) {
      const key = arg.slice(2);
      const next = argv[i + 1];
      if (next === undefined || next.startsWith('--')) {
        args[key] = true;
      } else {
        args[key] = next;
        i++;
      }
    }
  }
  return args;
}

function pad2(n) {
  return String(n).padStart(2, '0');
}

/** Accepts YYYY-MM-DD or DD-MM-YYYY (or DD/MM/YYYY) and returns YYYY-MM-DD. */
function normalizeDate(input) {
  const isoMatch = /^(\d{4})-(\d{2})-(\d{2})$/.exec(input);
  if (isoMatch) return input;

  const dmyMatch = /^(\d{2})[-/](\d{2})[-/](\d{4})$/.exec(input);
  if (dmyMatch) {
    const [, dd, mm, yyyy] = dmyMatch;
    return `${yyyy}-${mm}-${dd}`;
  }

  throw new Error(
    `Unrecognized date "${input}". Use YYYY-MM-DD or DD-MM-YYYY.`
  );
}

function addDays(isoDate, days) {
  const [y, m, d] = isoDate.split('-').map(Number);
  const dt = new Date(Date.UTC(y, m - 1, d));
  dt.setUTCDate(dt.getUTCDate() + days);
  return `${dt.getUTCFullYear()}-${pad2(dt.getUTCMonth() + 1)}-${pad2(dt.getUTCDate())}`;
}

function computeWindow(args) {
  if (args.since || args.until) {
    if (!args.since || !args.until) {
      throw new Error('Provide both --since and --until, or use --month instead.');
    }
    const since = normalizeDate(args.since);
    // Treat --until as inclusive; git's --until is inclusive of that
    // timestamp's day already when given a bare date, but to be safe and
    // consistent with the month-window math below, push it one day forward.
    const until = addDays(normalizeDate(args.until), 1);
    return { since, until };
  }

  if (args.month) {
    const monthIndex = MONTHS.indexOf(String(args.month).toLowerCase());
    if (monthIndex === -1) {
      throw new Error(`Unrecognized month name "${args.month}".`);
    }
    const year = args.year ? Number(args.year) : new Date().getFullYear();
    const since = `${year}-${pad2(monthIndex + 1)}-01`;
    const nextMonthIndex = (monthIndex + 1) % 12;
    const nextYear = nextMonthIndex === 0 ? year + 1 : year;
    const until = `${nextYear}-${pad2(nextMonthIndex + 1)}-01`;
    return { since, until };
  }

  throw new Error('Provide either --month [--year] or --since/--until.');
}

function isGitRepo(dirPath) {
  return fs.existsSync(path.join(dirPath, '.git'));
}

function git(repoPath, gitArgs) {
  return execFileSync('git', gitArgs, {
    cwd: repoPath,
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'pipe'],
  }).trim();
}

function safeGit(repoPath, gitArgs, fallback = '') {
  try {
    return git(repoPath, gitArgs);
  } catch {
    return fallback;
  }
}

function getDefaultBranch(repoPath) {
  const symbolic = safeGit(repoPath, ['symbolic-ref', 'refs/remotes/origin/HEAD']);
  if (symbolic) {
    const parts = symbolic.split('/');
    return parts[parts.length - 1];
  }
  for (const candidate of ['main', 'master']) {
    const exists = safeGit(repoPath, ['rev-parse', '--verify', '--quiet', `origin/${candidate}`]);
    if (exists) return candidate;
  }
  return null;
}

function collectRepoActivity(repoPath, window) {
  const name = path.basename(repoPath);
  const currentBranch = safeGit(repoPath, ['rev-parse', '--abbrev-ref', 'HEAD'], null);
  const defaultBranch = getDefaultBranch(repoPath);

  // Fetch remotes quietly so `--all` reflects up-to-date remote branches too.
  // Non-fatal if it fails (e.g. offline, no remote configured).
  safeGit(repoPath, ['fetch', '--all', '--quiet']);

  const SEP = '\u0001'; // unlikely to appear in a commit subject
  const raw = safeGit(repoPath, [
    'log', '--all',
    `--since=${window.since}`,
    `--until=${window.until}`,
    `--pretty=format:%H${SEP}%ad${SEP}%an${SEP}%s`,
    '--date=short',
  ], null);

  if (raw === null) {
    return {
      name,
      path: repoPath,
      currentBranch,
      defaultBranch,
      reachable: false,
      commitCount: 0,
      commits: [],
      ticketRefs: [],
    };
  }

  const ticketRefsSet = new Set();
  const commits = raw
    .split('\n')
    .filter(Boolean)
    .map((line) => {
      const [hash, date, author, subject] = line.split(SEP);
      return { hash, date, author, subject };
    })
    .filter((c) => c.subject && !STASH_NOISE_RE.test(c.subject))
    .map((c) => {
      const refs = [...c.subject.matchAll(TICKET_RE)].map((m) => m[1]);
      refs.forEach((r) => ticketRefsSet.add(r));
      return { ...c, ticketRefs: refs };
    });

  return {
    name,
    path: repoPath,
    currentBranch,
    defaultBranch,
    reachable: true,
    commitCount: commits.length,
    commits,
    ticketRefs: [...ticketRefsSet],
  };
}

function detectDominantTicketPrefix(repos) {
  const counts = new Map();
  for (const repo of repos) {
    for (const ref of repo.ticketRefs) {
      const prefix = ref.split('-')[0];
      counts.set(prefix, (counts.get(prefix) || 0) + 1);
    }
  }
  let best = null;
  let bestCount = 0;
  for (const [prefix, count] of counts) {
    if (count > bestCount) {
      best = prefix;
      bestCount = count;
    }
  }
  return best;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const root = path.resolve(args.root || process.cwd());
  const window = computeWindow(args);

  let entries;
  try {
    entries = fs.readdirSync(root, { withFileTypes: true });
  } catch (err) {
    console.error(`Cannot read root directory "${root}": ${err.message}`);
    process.exit(1);
  }

  const repos = [];
  const skipped = [];

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    const fullPath = path.join(root, entry.name);
    if (!isGitRepo(fullPath)) {
      skipped.push({ name: entry.name, reason: 'no .git' });
      continue;
    }
    repos.push(collectRepoActivity(fullPath, window));
  }

  const ticketPrefix = args['ticket-prefix'] || detectDominantTicketPrefix(repos) || null;

  const result = { window, ticketPrefix, repos, skipped };
  process.stdout.write(JSON.stringify(result, null, 2) + '\n');
}

main();
