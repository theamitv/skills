# Security & Compliance Auditor

> Enterprise security auditor — app, cloud, K8s, CI/CD, compliance (SOC2, ISO27001, GDPR, HIPAA).

Comprehensive security reviews of applications, APIs, infrastructure, cloud, CI/CD, K8s, and containers. Threat modeling with STRIDE. Compliance readiness assessments.

## What It Does

- **Application Security** — Input validation, injection, XSS, CSRF, SSRF, auth, session, file upload
- **Cloud Security** — AWS/Azure/GCP IAM, VPC, security groups, encryption, monitoring, KMS
- **Container Security** — Dockerfile, base images, root user, capabilities, secrets, supply chain
- **K8s Security** — RBAC, network policies, pod security, admission controllers, secrets
- **CI/CD Security** — Pipeline security, secrets, supply chain, branch protection
- **Threat Modeling** — STRIDE: assets, actors, entry points, trust boundaries, attack surfaces
- **Compliance** — SOC2, ISO27001, GDPR, HIPAA, PCI DSS, NIST CSF, CIS Benchmarks

## Quick Start

```bash
# Install
npx skills add theamitv/security-compliance-auditor

# Use in Claude Code
/security-compliance-auditor Review application security
```

## Structure

```
security-compliance-auditor/
├── SKILL.md          # Skill metadata and triggers
├── README.md         # This file
├── references/
│   └── compliance-frameworks.md  # OWASP, SOC2, ISO27001, GDPR requirements
├── examples/
│   └── usage.md      # Usage examples
└── scripts/
    └── audit.sh      # Initial security scan
```

## License

MIT
