# Cloud Cost Optimizer

> FinOps advisor — cloud cost analysis, K8s optimization, rightsizing, governance, forecasting.

Analyze cloud infrastructure spend across AWS, Azure, GCP, and K8s. Identify waste, recommend optimizations, and build cost governance.

## What It Does

- **Compute Optimization** — EC2, ECS, EKS, Lambda, spot, reserved instances, rightsizing
- **K8s Optimization** — Requests/limits, pod density, HPA/VPA, node pools, cluster fragmentation
- **Storage** — S3/Blob/Cloud Storage tiers, lifecycle, EBS, snapshots, unused volumes
- **Database** — RDS, Aurora, DynamoDB, Cloud SQL — instance size, replicas, reserved capacity
- **Network** — Data transfer, NAT gateway, LB, CDN, inter-region traffic
- **AI/ML** — GPU utilization, inference endpoints, vector DB, idle GPUs
- **Governance** — Tagging, budgets, chargeback, automation

## Quick Start

```bash
# Install
npx skills add theamitv/cloud-cost-optimizer

# Use in Claude Code
/cloud-cost-optimizer Analyze AWS costs
```

## Structure

```
cloud-cost-optimizer/
├── SKILL.md          # Skill metadata and triggers
├── README.md         # This file
├── references/
│   └── savings-strategies.md  # Quick wins and strategic savings
├── examples/
│   └── usage.md      # Usage examples
└── scripts/
    └── analyze-costs.sh  # Cloud cost data collection
```

## License

MIT
