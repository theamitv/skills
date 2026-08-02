# Six Root Causes of Flaky Tests

## 1. Timing

**Signature**: Test passes when artificial delays are added before assertions, fails without them.

**Common causes**:
- Race conditions between async operations and assertions
- Unawaited promises or async calls
- Missing `waitFor`, `findBy`, or `expect.poll()` in assertions
- setTimeout/setInterval not properly mocked
- Animation completion not awaited
- WebSocket/SSE message not received before assertion

**Fix**:
- Use `waitFor` / `findBy` / `expect.poll()` instead of fixed `setTimeout`
- `await` all async operations before assertions
- Use fake timers (`jest.useFakeTimers()`) for time-dependent code
- Wait for elements to be visible/stable, not just present
- Use `page.waitForSelector()` / `page.waitForResponse()` in Playwright

**Example**:
```js
// ❌ Flaky — race condition
const result = await asyncOperation();
expect(result.status).toBe(200);  // might not be set yet

// ✅ Stable — wait for the actual condition
await waitFor(() => {
  expect(result.status).toBe(200);
});
```

## 2. Shared State

**Signature**: Test passes in isolation, fails when run as part of the full suite. Different tests pass/fail depending on run order.

**Common causes**:
- Global variables or singletons mutated by one test, read by another
- Database records created by one test, affecting another
- Filesystem state (temp files, caches) not cleaned up between tests
- Module-level state (imported singletons, module cache)
- Environment variables set by one test, not restored
- In-memory caches populated by one test, consumed by another

**Fix**:
- Reset all global state in `beforeEach` / `afterEach`
- Use isolated database transactions that roll back after each test
- Use unique temp directories per test
- Clear module cache between tests (`jest.resetModules()`)
- Restore environment variables after each test
- Use `--testPathPattern` to run tests in random order to catch shared state

**Example**:
```js
// ❌ Flaky — test A sets a global, test B reads it
// test-a.test.js
beforeAll(() => { global.cache.set('key', 'value'); });

// test-b.test.js
test('reads cache', () => {
  expect(global.cache.get('key')).toBe('value');  // depends on test-a running first
});

// ✅ Stable — each test sets up its own state
test('reads cache', () => {
  global.cache.set('key', 'value');
  expect(global.cache.get('key')).toBe('value');
  global.cache.clear();
});
```

## 3. Network Dependencies

**Signature**: Test fails when network is slow, unavailable, or returns unexpected responses. Passes with mocked network.

**Common causes**:
- Real HTTP calls to external APIs in tests
- No mocking or test doubles for network requests
- API rate limiting or throttling
- Network timeouts or DNS failures
- API response shape changes (version mismatch)
- WebSocket connections that fail or timeout

**Fix**:
- Mock all external HTTP calls (MSW, nock, jest.mock, Playwright route interception)
- Use test doubles for API clients
- Add retry logic for unavoidable network calls
- Use `page.route()` in Playwright to intercept network requests
- Pin API versions or use contract testing

**Example**:
```js
// ❌ Flaky — real HTTP call
test('fetches user', async () => {
  const user = await fetchUser(1);  // real network call
  expect(user.name).toBe('Alice');
});

// ✅ Stable — mock the network
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  http.get('/api/users/1', () => HttpResponse.json({ name: 'Alice' }))
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test('fetches user', async () => {
  const user = await fetchUser(1);
  expect(user.name).toBe('Alice');
});
```

## 4. Selector Fragility

**Signature**: E2E test fails intermittently with "element not found", "stale element reference", or "element is not visible/interactable". Common in Playwright, Cypress, Selenium tests.

**Common causes**:
- CSS class-based selectors that change with styling updates
- Text-based selectors that change with copy/content updates
- Stale element references after DOM re-render
- Elements not yet rendered when selector runs
- Elements animating or transitioning when clicked
- Overlapping elements (modals, tooltips) intercepting clicks

**Fix**:
- Use `data-testid` attributes that never change with styling or content
- Prefer `getByRole` / `findByRole` (Playwright Testing Library) over CSS selectors
- Wait for element stability before interacting
- Use `locator.waitFor({ state: 'stable' })` in Playwright
- Re-query elements after page navigation or re-render

**Example**:
```js
// ❌ Fragile — CSS class selector
await page.click('.submit-button');

// ✅ Stable — data-testid selector
await page.click('[data-testid="submit-button"]');

// ✅ Even better — role selector
await page.getByRole('button', { name: 'Submit' }).click();
```

## 5. Environment Differences

**Signature**: Test passes on developer machines, fails on CI. Or passes on one OS/Node version, fails on another.

**Common causes**:
- Different Node.js versions between environments
- Different operating systems (macOS vs Linux — case-sensitive filesystem!)
- Different timezones or locales affecting date formatting
- Different screen sizes or viewport dimensions (E2E tests)
- Different environment variables
- Different dependency versions (not pinned)
- Different hardware (CPU speed affecting timing)
- CI runner resource constraints (memory, CPU throttling)

**Fix**:
- Use Docker/containerized test environments
- Pin Node.js version in `.nvmrc` / `.node-version` / `engines` in package.json
- Pin all dependencies with lockfiles
- Set timezone/locale explicitly in test setup
- Use consistent viewport/screen size in E2E tests
- Match CI environment locally with `act` (GitHub Actions locally) or Docker
- Add resource checks in CI (enough memory, disk space)

**Example**:
```js
// ✅ Set timezone in test setup (jest.config.js or setup file)
process.env.TZ = 'UTC';

// ✅ Set locale
process.env.LANG = 'en_US.UTF-8';

// ✅ Pin Node version
// .nvmrc
// 18.20.0
```

## 6. Order Dependency

**Signature**: Test A passes when run alone, fails when test B runs before it. Running tests in random order surfaces different failures.

**Common causes**:
- Test B modifies global state that test A depends on
- Test B creates database records that test A queries
- Test B sets environment variables that test A reads
- Test B mocks a module that test A uses (mock leakage)
- Test B leaves a timer/interval running that interferes with test A
- Test B doesn't clean up after itself

**Fix**:
- Make every test hermetic — full setup and teardown in each test
- Use `beforeEach`/`afterEach` (not `beforeAll`/`afterAll`) for state setup
- Run tests in random order (`--order random` in Jest, `--shard` in Vitest)
- Use `jest.resetAllMocks()` / `jest.restoreAllMocks()` in `afterEach`
- Clear database between tests (transaction rollback or truncation)
- Use `--runInBand --listTests` to find order dependencies

**Example**:
```js
// ❌ Flaky — test A leaks a mock
// test-a.test.js
jest.mock('../api');
test('test A', () => { /* ... */ });  // mock leaks to test B

// test-b.test.js
test('test B', () => {
  const api = require('../api');  // still mocked from test A!
});

// ✅ Stable — reset mocks between tests
afterEach(() => {
  jest.resetAllMocks();
  jest.restoreAllMocks();
});
```
