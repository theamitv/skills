# Cloud Cost Optimizer

> FinOps advisor — cloud cost analysis, K8s optimization, rightsizing, governance, forecasting.

Analyze, optimize, and govern cloud infrastructure costs across AWS, GCP, and Azure. Rightsize resources, eliminate waste, and implement FinOps best practices.

## What It Does

- **Cost Analysis** — Spend breakdown by service, region, account, tag. Anomaly detection and trend analysis.
- **Rightsizing** — EC2, RDS, ECS, Lambda memory, K8s resource requests/limits optimization.
- **Storage Optimization** — S3 lifecycle policies, EBS snapshots, Glacier tiering, unused volume detection.
- **Kubernetes** — Cluster rightsizing, node pool optimization, spot instance analysis, resource waste detection.
- **Governance** — Budget alerts, cost allocation tags, reserved instance coverage, FinOps maturity assessment.

## Quick Start

```bash
# Install
npx skills add theamitv/cloud-cost-optimizer

# Use in Claude Code
/cloud-cost-optimizer Analyze AWS costs for the last 30 days
```

## When It Won't Work

- **No cost data access** — Requires cloud provider cost exports (AWS CUR, GCP Billing, Azure Cost Management) or a CSV export. Cannot access live billing APIs directly.
- **Real-time costs** — Cloud billing data has a 24-48 hour delay. Analysis is based on completed billing periods, not real-time spend.
- **Multi-cloud aggregation** — Analyzes each provider separately. Does not auto-merge multi-cloud bills into a single view.
- **Commitment purchases** — Does not purchase reserved instances or savings plans. Provides recommendations only.
- **Custom pricing** — Works with standard on-demand and reserved pricing. Enterprise discount agreements and private offers are not reflected.

## Structure

```
cloud-cost-optimizer/
├── SKILL.md              # Skill metadata and triggers
├── README.md             # This file
├── references/
│   └── savings-strategies.md  # Cost optimization patterns
├── examples/
│   └── usage.md          # Usage examples
└── scripts/
    └── analyze-costs.sh  # Cost data analysis script
```

## License

MIT
