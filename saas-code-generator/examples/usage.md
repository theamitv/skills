# Usage Examples

## Basic: Full Application Generation

Generate a complete SaaS application from scratch:

```
/saas-code-generator Generate code for a gym management SaaS
```

Claude will:
1. Ask about tech stack preferences
2. Present a generation plan for approval
3. Generate the full application: database → backend → frontend → tests → deployment

## With Blueprint from saas-product-generator

First generate the blueprint, then build it:

```
/saas-product-generator Create a SaaS for interview prep platform
# ... review and approve the blueprint ...

/saas-code-generator Build the app from my SaaS blueprint
```

Claude will read the blueprint context and generate code matching the spec.

## Specific: Interview Prep Platform (LeetCode-like)

```
/saas-code-generator Generate a Next.js + FastAPI interview prep platform
```

Claude will generate:
- **Database**: Users, problems, submissions, test cases, tags, companies tables
- **Backend**: Problem CRUD, code submission with sandboxed execution, test runner, leaderboard
- **Frontend**: Problem list with filters, code editor (Monaco), submission history, progress tracking
- **Tests**: Problem API tests, submission pipeline tests, auth tests
- **Deployment**: Docker with sandboxed code executor, CI/CD

## Layer-Specific Generation

Generate only what you need:

```
# Frontend only
/saas-code-generator Generate frontend for a CRM with Next.js

# Backend only
/saas-code-generator Generate backend API with FastAPI for a healthcare app

# Database only
/saas-code-generator Generate database schema for an e-commerce platform

# Deployment only
/saas-code-generator Generate Docker config for a Node.js app
```

## Stack-Specific Generation

Specify your preferred tech stack:

```
/saas-code-generator Generate a Vue 3 + Go Gin project management app
/saas-code-generator Generate a React + Express e-commerce platform
/saas-code-generator Generate a Next.js + FastAPI + PostgreSQL analytics dashboard
```

## Incremental Generation

Add features to an existing project:

```
/saas-code-generator Add payment integration with Stripe
/saas-code-generator Add OAuth login with Google and GitHub
/saas-code-generator Add file upload for user avatars
/saas-code-generator Add email notifications with SendGrid
```

## Test Generation

Generate tests for existing code:

```
/saas-code-generator Generate tests for the payment module
/saas-code-generator Generate integration tests for the API
/saas-code-generator Generate e2e tests for the checkout flow
```

## CI/CD Generation

Generate deployment configuration:

```
/saas-code-generator Generate Docker config for deployment
/saas-code-generator Generate CI/CD pipeline with GitHub Actions
/saas-code-generator Generate docker-compose for local development
```
