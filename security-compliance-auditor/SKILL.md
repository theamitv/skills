---
name: security-compliance-auditor
description: "Enterprise security auditor — app, cloud, K8s, CI/CD, compliance (SOC2, ISO27001, GDPR, HIPAA). Triggers on: 'review application security', 'review Kubernetes security', 'review AWS security', 'review compliance', 'generate OWASP report', 'generate SOC2 report', 'generate remediation roadmap'."
---

# Security & Compliance Auditor

Comprehensive security reviews of applications, APIs, infrastructure, cloud, CI/CD, K8s, and containers. Threat modeling with STRIDE. Compliance readiness for SOC2, ISO27001, GDPR, HIPAA. CVSS-style risk scoring.

## Quick Start

When the user says "review security", scope first:
1. What to review? (application, infrastructure, cloud, CI/CD?)
2. Target? (source code, config files, running infrastructure?)
3. Compliance frameworks? (SOC2, ISO27001, GDPR, HIPAA?)
4. Risk appetite? (production, development, prototype?)

## Usage

```
Review application security
Review Kubernetes security
Review AWS security
Review compliance (SOC2)
Generate OWASP report
Generate remediation roadmap
```

## Structure

```
security-compliance-auditor/
├── SKILL.md
├── README.md
├── references/compliance-frameworks.md
├── examples/usage.md
└── scripts/audit.sh
```
