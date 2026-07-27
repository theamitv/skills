#!/usr/bin/env bash
# Cloud Cost Optimizer - Cost Analysis Script
# Usage: ./analyze-costs.sh <cloud-provider>
# Securely collects cost data from cloud providers.

set -euo pipefail

CLOUD="${1:-}"

usage() {
  echo "Usage: $0 <cloud-provider>"
  echo "Example: $0 aws"
  echo "Example: $0 azure"
  echo "Example: $0 gcp"
  exit 1
}

[ -z "$CLOUD" ] && usage

# Validate cloud provider
case "$CLOUD" in
  aws|azure|gcp|gcloud) ;;
  *) echo "Error: unsupported cloud provider '$CLOUD'. Supported: aws, azure, gcp"; exit 1 ;;
esac

echo "💰 Cloud Cost Analysis: $CLOUD"
echo "============================="
echo ""

case "$CLOUD" in
  aws)
    echo "=== AWS Cost Explorer ==="
    if command -v aws &>/dev/null; then
      aws ce get-cost-and-usage \
        --time-period Start="$(date -d '-30 days' +%Y-%m-%d)",End="$(date +%Y-%m-%d)" \
        --granularity DAILY \
        --metrics BlendedCost \
        --group-by Type=DIMENSION,Key=SERVICE 2>/dev/null | head -30 || echo "Cost Explorer not accessible (check AWS credentials and permissions)"
    else
      echo "AWS CLI not installed. Install: brew install awscli"
    fi
    echo ""
    echo "=== Idle Resources ==="
    aws ec2 describe-instances \
      --filters Name=instance-state-name,Values=running \
      --query 'Reservations[].Instances[?LaunchTime<`2024-01-01`].[InstanceId,InstanceType,LaunchTime]' \
      2>/dev/null | head -10 || echo "EC2 not accessible"
    ;;
  azure)
    echo "=== Azure Cost Management ==="
    if command -v az &>/dev/null; then
      subscription_id=$(az account show --query id -o tsv 2>/dev/null || echo "")
      if [ -n "$subscription_id" ]; then
        az costmanagement query \
          --scope "/subscriptions/${subscription_id}" \
          --timeframe MonthToDate \
          --type ActualCost 2>/dev/null | head -20 || echo "Cost Management not accessible"
      else
        echo "Azure not logged in. Run: az login"
      fi
    else
      echo "Azure CLI not installed. Install: brew install azure-cli"
    fi
    ;;
  gcp|gcloud)
    echo "=== GCP Billing ==="
    if command -v gcloud &>/dev/null; then
      gcloud billing accounts list 2>/dev/null || echo "Billing not accessible (check gcloud auth)"
      echo ""
      echo "=== Compute Instances ==="
      gcloud compute instances list 2>/dev/null | head -20 || echo "Compute not accessible"
    else
      echo "gcloud CLI not installed. Install: https://cloud.google.com/sdk/docs/install"
    fi
    ;;
esac

echo ""
echo "✅ Cost data collected. Feed into the skill for optimization analysis."
