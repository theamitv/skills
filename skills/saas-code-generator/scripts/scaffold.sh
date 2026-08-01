#!/usr/bin/env bash
# SaaS Code Generator - Project Scaffold Script
# Usage: ./scaffold.sh <project-name> [stack]
#   stack: nextjs | react-vite | vue-vite | fastapi | express | gin
# Creates a complete project directory structure for the chosen tech stack.
#
# Security: input validation, path traversal prevention, safe defaults.

set -euo pipefail

PROJECT_NAME="${1:-}"
STACK="${2:-nextjs}"

usage() {
  echo "Usage: $0 <project-name> [stack]"
  echo "Stacks: nextjs, react-vite, vue-vite, fastapi, express, gin"
  echo "Example: $0 gym-management nextjs"
  exit 1
}

# ── Validation ──────────────────────────────────────────────────────────────

[ -z "$PROJECT_NAME" ] && usage

# Validate project name: alphanumeric, hyphens, underscores only
name_re='^[a-z0-9][a-z0-9_-]*$'
[[ "$PROJECT_NAME" =~ $name_re ]] || {
  echo "Error: project name must start with a lowercase letter or number and contain only lowercase letters, numbers, hyphens, and underscores"
  exit 1
}

# Prevent path traversal
case "$PROJECT_NAME" in
  *..*|*/*|*\\*) echo "Error: invalid project name (path separators not allowed)"; exit 1 ;;
esac

# Validate stack
valid_stacks="nextjs react-vite vue-vite fastapi express gin"
found=0
for s in $valid_stacks; do
  [ "$s" = "$STACK" ] && { found=1; break; }
done
[ "$found" -eq 0 ] && {
  echo "Error: unsupported stack '$STACK'. Valid options: $valid_stacks"
  exit 1
}

DIR="./$PROJECT_NAME"

# Check if directory already exists
[ -d "$DIR" ] && {
  echo "Error: directory '$DIR' already exists"
  exit 1
}

# ── Stack Directory Structures ──────────────────────────────────────────────

case "$STACK" in
  nextjs)
    mkdir -p "$DIR"/{app,components/{ui,forms,layout},lib,types,public}
    cat > "$DIR/package.json" <<-EOF
{
  "name": "$PROJECT_NAME",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "test": "vitest run",
    "test:watch": "vitest"
  }
}
EOF
    cat > "$DIR/tsconfig.json" <<-EOF
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF
    cat > "$DIR/next.config.js" <<-EOF
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  images: { domains: [] },
};
module.exports = nextConfig;
EOF
    ;;

  react-vite)
    mkdir -p "$DIR"/{src/{components,pages,hooks,lib,types},public}
    cat > "$DIR/package.json" <<-EOF
{
  "name": "$PROJECT_NAME",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "eslint .",
    "test": "vitest run",
    "test:watch": "vitest"
  }
}
EOF
    cat > "$DIR/tsconfig.json" <<-EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["src"]
}
EOF
    cat > "$DIR/vite.config.ts" <<-EOF
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: { alias: { '@': path.resolve(__dirname, './src') } },
  server: { port: 3000 },
});
EOF
    ;;

  vue-vite)
    mkdir -p "$DIR"/{src/{components,views,stores,composables,lib,router},public}
    cat > "$DIR/package.json" <<-EOF
{
  "name": "$PROJECT_NAME",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vue-tsc && vite build",
    "preview": "vite preview",
    "lint": "eslint .",
    "test": "vitest run",
    "test:watch": "vitest"
  }
}
EOF
    cat > "$DIR/tsconfig.json" <<-EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "module": "ESNext",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "preserve",
    "strict": true,
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["src/**/*.ts", "src/**/*.d.ts", "src/**/*.vue"]
}
EOF
    cat > "$DIR/vite.config.ts" <<-EOF
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import path from 'path';

export default defineConfig({
  plugins: [vue()],
  resolve: { alias: { '@': path.resolve(__dirname, './src') } },
  server: { port: 3000 },
});
EOF
    ;;

  fastapi)
    mkdir -p "$DIR"/{app/{api/v1,core,models,schemas,services},tests,migrations/versions}
    cat > "$DIR/requirements.txt" <<-EOF
fastapi>=0.110.0
uvicorn[standard]>=0.27.0
sqlalchemy>=2.0.0
alembic>=1.13.0
pydantic>=2.0.0
pydantic-settings>=2.0.0
python-jose[cryptography]>=3.3.0
passlib[bcrypt]>=1.7.4
httpx>=0.27.0
pytest>=8.0.0
pytest-asyncio>=0.23.0
EOF
    cat > "$DIR/app/__init__.py" <<-EOF
EOF
    cat > "$DIR/app/core/__init__.py" <<-EOF
EOF
    cat > "$DIR/app/models/__init__.py" <<-EOF
EOF
    cat > "$DIR/app/schemas/__init__.py" <<-EOF
EOF
    cat > "$DIR/app/services/__init__.py" <<-EOF
EOF
    cat > "$DIR/app/api/__init__.py" <<-EOF
EOF
    cat > "$DIR/app/api/v1/__init__.py" <<-EOF
EOF
    cat > "$DIR/tests/__init__.py" <<-EOF
EOF
    ;;

  express)
    mkdir -p "$DIR"/{src/{config,models,routes,middleware,services,types},tests}
    cat > "$DIR/package.json" <<-EOF
{
  "name": "$PROJECT_NAME",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "lint": "eslint .",
    "test": "jest --forceExit --detectOpenHandles",
    "test:watch": "jest --watch"
  }
}
EOF
    cat > "$DIR/tsconfig.json" <<-EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist", "tests"]
}
EOF
    ;;

  gin)
    mkdir -p "$DIR"/{cmd/server,internal/{config,database,models,handlers,middleware,services,repository},migrations}
    cat > "$DIR/go.mod" <<-EOF
module github.com/yourorg/$PROJECT_NAME

go 1.22

require (
	github.com/gin-gonic/gin v1.9.1
	gorm.io/gorm v1.25.7
	gorm.io/driver/postgres v1.5.6
	github.com/golang-jwt/jwt/v5 v5.2.0
	golang.org/x/crypto v0.21.0
	github.com/joho/godotenv v1.5.1
	github.com/stretchr/testify v1.9.0
)
EOF
    ;;
esac

# ── Common Files ───────────────────────────────────────────────────────────

# .gitignore
cat > "$DIR/.gitignore" <<-EOF
node_modules/
dist/
.next/
.env
.env.local
*.log
.DS_Store
__pycache__/
*.pyc
.venv/
venv/
*.db
*.sqlite
coverage/
.turbo/
EOF

# .env.example
cat > "$DIR/.env.example" <<-EOF
# App
APP_NAME=$PROJECT_NAME
APP_ENV=development
APP_URL=http://localhost:3000
LOG_LEVEL=info

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/${PROJECT_NAME//-/_}

# Auth
JWT_SECRET=change-me-to-a-random-secret
JWT_EXPIRES_MINUTES=15
JWT_REFRESH_EXPIRES_DAYS=7

# Optional: OAuth
# GOOGLE_CLIENT_ID=
# GOOGLE_CLIENT_SECRET=
# GITHUB_CLIENT_ID=
# GITHUB_CLIENT_SECRET=
EOF

# ── Summary ────────────────────────────────────────────────────────────────

echo "📁 Scaffolded project: $PROJECT_NAME (stack: $STACK)"
echo ""
echo "  Directory structure:"
find "$DIR" -type d | sort | while read -r d; do
  echo "    └── ${d#./}"
done
echo ""
echo "✅ Project scaffold created at $DIR"
echo "Run the skill in Claude Code to generate the full application."
