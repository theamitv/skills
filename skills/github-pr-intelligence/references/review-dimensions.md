# Review Dimensions Reference

## Severity Levels

| Level | Description |
|-------|-------------|
| Critical | Must fix before merge. Data loss, security breach, or complete feature breakage. |
| High | Significant risk. Should fix before merge. Performance degradation, partial feature breakage. |
| Medium | Notable issue. Fix in current sprint. Code smell, minor security concern. |
| Low | Minor issue. Fix when convenient. Style inconsistency, minor optimization. |
| Suggestion | Improvement opportunity. Not blocking. |
| Informational | Observation without action required. |

## Security Checklist (OWASP Top 10)

- [ ] Broken Access Control
- [ ] Cryptographic Failures
- [ ] Injection (SQL, NoSQL, Command, Template)
- [ ] Insecure Design
- [ ] Security Misconfiguration
- [ ] Vulnerable and Outdated Components
- [ ] Identification and Authentication Failures
- [ ] Software and Data Integrity Failures
- [ ] Security Logging and Monitoring Failures
- [ ] Server-Side Request Forgery (SSRF)

## Performance Checklist

- [ ] N+1 database queries
- [ ] Missing or inefficient indexes
- [ ] Unbounded list growth
- [ ] Blocking calls in async paths
- [ ] Large object allocations in hot paths
- [ ] Missing connection pooling
- [ ] Inefficient caching strategy
- [ ] Missing pagination on list endpoints

## Architecture Checklist

- [ ] Single Responsibility Principle
- [ ] Dependency Inversion Principle
- [ ] No circular dependencies
- [ ] Clear layer separation
- [ ] Appropriate use of design patterns
- [ ] API backward compatibility
- [ ] Error handling strategy
- [ ] Logging and observability
