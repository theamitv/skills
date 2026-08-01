# Security Review Checklist

## OWASP Top 10 (2021) — PR Review Edition

### A01 Broken Access Control
- [ ] New endpoints missing auth middleware/guards
- [ ] Role/permission checks missing on admin operations
- [ ] IDOR: endpoint uses user-supplied IDs without ownership check
- [ ] Mass assignment: request body maps directly to model fields
- [ ] CORS misconfiguration (wildcard origin with credentials)

### A02 Cryptographic Failures
- [ ] Sensitive data transmitted without TLS
- [ ] Passwords/keys logged in plaintext
- [ ] Weak or custom encryption algorithms
- [ ] Hardcoded secrets, API keys, or tokens
- [ ] Insecure random number generator used

### A03 Injection
- [ ] Raw SQL/NoSQL query construction with string interpolation
- [ ] Command execution with user input
- [ ] Template injection (server-side or client-side)
- [ ] Unsafe `eval()`, `Function()`, or `setTimeout()` with strings
- [ ] Path traversal in file operations

### A04 Insecure Design
- [ ] Missing rate limiting on auth endpoints
- [ ] No request size limits
- [ ] Missing input validation at boundary
- [ ] Trusting client-supplied prices/roles/permissions
- [ ] Missing CSRF tokens on state-changing operations

### A05 Security Misconfiguration
- [ ] Debug/verbose error messages in production
- [ ] Default credentials unchanged
- [ ] Unnecessary open ports or services
- [ ] Missing security headers (CSP, HSTS, X-Frame-Options)
- [ ] Directory listing enabled

### A06 Vulnerable Components
- [ ] New dependency added without version pinning
- [ ] Known vulnerable dependency version introduced
- [ ] Deprecated library or framework version
- [ ] Native/binary dependencies without integrity check

### A07 Auth Failures
- [ ] Weak password policies
- [ ] Missing MFA on sensitive operations
- [ ] Session fixation or predictable tokens
- [ ] Token not revoked on logout
- [ ] JWT without expiration or signature verification

### A08 Data Integrity Failures
- [ ] Unsafe deserialization (pickle, YAML, eval)
- [ ] Missing signature verification on webhooks
- [ ] CI/CD pipeline without artifact signing
- [ ] Auto-update mechanism without integrity check

### A09 Logging & Monitoring
- [ ] Security-relevant events not logged
- [ ] Sensitive data included in logs
- [ ] No alerting on auth failures
- [ ] Missing audit trail for data changes

### A10 SSRF
- [ ] User-supplied URLs fetched server-side
- [ ] Internal service discovery via user input
- [ ] Cloud metadata endpoint accessible

## Infrastructure Security

- [ ] Dockerfile: no `RUN` as root, no `:latest` tag
- [ ] K8s: no privileged containers, no host network
- [ ] Terraform: no public S3 buckets, no wide IAM policies
- [ ] CI/CD: no secrets in workflow files, no `pull_request_target` without checkout pinning

## Data Security

- [ ] PII/PHI fields logged or exposed in new endpoints
- [ ] Personal data stored without encryption at rest
- [ ] Data export without access control
- [ ] Missing data retention/deletion policy
