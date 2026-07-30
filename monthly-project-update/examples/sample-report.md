# Acme Platform Project Update — March 2026

_Covering March 1–31, 2026. Generated 2026-04-01._

**Key Milestones:**

**1. Deployments & Fixes**

Checkout page timeout and duplicate-order bug fixed and deployed
Search relevance regression on mobile resolved
Password reset email delay under investigation, in progress

**2. New Features**

Bulk CSV export for the admin dashboard shipped
Multi-currency pricing support in progress on the pricing-service branch

**3. Infrastructure & Upgrades**

API gateway migrated from REST to gRPC for internal service calls, merged
Node runtime upgraded to v22 across all backend services

**4. Security & Compliance**

Two medium-severity dependency vulnerabilities (lodash, axios) remediated
SOC 2 evidence collection for Q1 in progress

**Summary**

- Checkout and search bugs resolved; one email-delay issue still being investigated
- Admin CSV export live; multi-currency pricing still in development
- Backend modernized with gRPC and a Node runtime upgrade
- Known dependency vulnerabilities patched; compliance evidence gathering underway

---

_Note: GitLab MR search returned no results during report generation, so this update is based on commit history and direct MR lookups instead. Linear ticket titles were unavailable (authentication required), so item descriptions are derived from commit/MR content._
