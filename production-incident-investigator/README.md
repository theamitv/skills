# Production Incident Investigator

> SRE incident investigator — root cause analysis, timeline, postmortem, and remediation.

Investigate production incidents like an elite SRE. Correlate evidence across logs, metrics, traces, and deployments. 13-phase investigation pipeline.

## What It Does

- **13-Phase Pipeline** — Context → Timeline → Alerts → Logs → Traces → Deployments → Infrastructure → Application → Database → Network → Security → Root Cause → Recommendations
- **Evidence Classification** — Fact, Observation, Hypothesis, Assumption, Recommendation
- **Correlation Engine** — Deployments↔errors, logs↔metrics↔traces, pods↔nodes↔cluster
- **Root Cause Analysis** — Primary, secondary, contributing factors with confidence scores
- **HTML Dashboard** — Timeline viz, root cause card, impact summary, metrics charts

## Quick Start

```bash
# Install
npx skills add theamitv/production-incident-investigator

# Use in Claude Code
/production-incident-investigator Investigate today's production outage
```

## Structure

```
production-incident-investigator/
├── SKILL.md          # Skill metadata and triggers
├── README.md         # This file
├── references/
│   └── incident-types.md  # Incident type descriptions and detection
├── examples/
│   └── usage.md      # Usage examples
└── scripts/
    └── collect-evidence.sh  # System evidence collector
```

## License

MIT
