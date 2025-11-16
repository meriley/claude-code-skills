---
name: Node.js Development Setup
description: Sets up Node.js/TypeScript development environment with npm/yarn, dependencies, ESLint, Prettier, testing (Jest/Vitest), and TypeScript type checking. Ensures consistent tooling configuration.
version: 1.0.0
---

# ⚠️ MANDATORY: Node.js Development Setup Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Starting work on Node.js/TypeScript project
2. After cloning Node.js repository
3. When setting up CI/CD for Node.js
4. When troubleshooting Node.js environment

**This skill is MANDATORY because:**
- Ensures consistent development environment
- Prevents dependency conflicts
- Sets up proper linting and formatting
- Enables TypeScript type safety
- Reduces environment setup issues

**ENFORCEMENT:**

**P1 Violations (High - Quality Failure):**
- Missing ESLint/Prettier setup
- No TypeScript configuration
- Missing test framework
- No type checking
- Outdated dependencies

**P2 Violations (Medium - Efficiency Loss):**
- Not using package-lock.json or yarn.lock
- Missing git hooks
- No Makefile for common tasks

**Blocking Conditions:**
- Must have ESLint configured
- Must have Prettier configured
- Must have TypeScript if TypeScript project
- Must have test framework

---

## Purpose

Sets up Node.js/TypeScript development environment with npm/yarn, dependencies, ESLint, Prettier, testing, and TypeScript type checking.

## Workflow

### Step 1: Verify Node.js Installation
```bash
node --version  # v16.0.0+
npm --version   # or yarn --version
```

### Step 2: Install Dependencies
```bash
npm install
# or
yarn install
```

### Step 3: Setup ESLint
```bash
# Create .eslintrc.json
{
  "extends": ["eslint:recommended"],
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "rules": {
    "no-console": "warn",
    "@typescript-eslint/no-explicit-any": "error"
  }
}
```

### Step 4: Setup Prettier
```bash
# Create .prettierrc
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "es5",
  "printWidth": 100,
  "tabWidth": 2
}
```

### Step 5: Setup TypeScript (if needed)
```bash
# Verify tsconfig.json exists
cat tsconfig.json

# Must have strict mode enabled
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "noImplicitThis": true,
    "strictNullChecks": true
  }
}
```

### Step 6: Setup Testing
```bash
# Jest
npm install --save-dev jest @types/jest ts-jest

# Vitest
npm install --save-dev vitest
```

### Step 7: Setup package.json Scripts
```json
{
  "scripts": {
    "build": "tsc",
    "dev": "ts-node src/index.ts",
    "test": "jest --coverage",
    "lint": "eslint src/",
    "format": "prettier --write src/",
    "type-check": "tsc --noEmit"
  }
}
```

### Step 8: Setup Git Hooks
```bash
# Install husky
npm install --save-dev husky
npx husky install

# Create pre-commit hook
cat > .husky/pre-commit << 'EOF'
#!/bin/bash
set -e
echo "Running pre-commit checks..."
npm run lint
npm run type-check
npm run test
echo "✅ Pre-commit checks passed"
EOF
chmod +x .husky/pre-commit
```

## Configuration Files

### package.json
```json
{
  "name": "project-name",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "build": "tsc",
    "dev": "ts-node src/index.ts",
    "test": "jest --coverage",
    "lint": "eslint src/",
    "format": "prettier --write src/",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "devDependencies": {
    "@types/node": "^18.0.0",
    "typescript": "^5.0.0",
    "eslint": "^8.0.0",
    "prettier": "^3.0.0",
    "jest": "^29.0.0",
    "ts-jest": "^29.0.0"
  }
}
```

### tsconfig.json
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["ES2020"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node"
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

### jest.config.js
```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/*.test.ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts'
  ],
  coverageThreshold: {
    global: {
      branches: 90,
      functions: 90,
      lines: 90,
      statements: 90
    }
  }
};
```

## Common Commands

```bash
# Install dependencies
npm install
npm install --save-dev package-name

# Run development server
npm run dev

# Build TypeScript
npm run build

# Run tests
npm test

# Lint code
npm run lint

# Format code
npm run format

# Type check
npm run type-check
```

## Anti-Patterns

### ❌ Anti-Pattern: Committing node_modules

**Wrong:**
```bash
git add node_modules/  # ❌ Never!
```

**Correct:**
```bash
# Add to .gitignore
echo "node_modules/" >> .gitignore
git add package.json package-lock.json
```

---

## References

**Based on:**
- CLAUDE.md Section 3 (Available Skills Reference - setup-node)
- Node.js best practices

**Related skills:**
- `quality-check` - Invokes ESLint/TypeScript
- `run-tests` - Runs Jest tests
