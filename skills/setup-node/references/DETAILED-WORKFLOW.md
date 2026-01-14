## Workflow

### Step 1: Verify Node.js Installation

```bash
node --version
npm --version
```

**Expected**: Node.js 18+ and npm 9+

**If not installed:**

```
❌ Node.js not found

Install Node.js:
- macOS: brew install node
- Linux: https://github.com/nodesource/distributions
- Windows: https://nodejs.org/download
- Or use nvm: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

After installing, verify: node --version
```

### Step 2: Check for Package Manager

**Detect package manager:**

```bash
ls package-lock.json yarn.lock pnpm-lock.yaml
```

**Package manager detection:**

- `package-lock.json` → npm
- `yarn.lock` → yarn
- `pnpm-lock.yaml` → pnpm

**If yarn needed:**

```bash
npm install -g yarn
```

**If pnpm needed:**

```bash
npm install -g pnpm
```

### Step 3: Install Dependencies

**Using npm:**

```bash
npm install
```

**Using yarn:**

```bash
yarn install
```

**Using pnpm:**

```bash
pnpm install
```

**Report:**

```
✅ Dependencies installed

Packages installed: X
Time: Y seconds
Package manager: npm/yarn/pnpm
```

### Step 4: Verify package.json Scripts

**Check for common scripts:**

```bash
cat package.json | jq '.scripts'
```

**Expected scripts:**

- `test` - Run tests
- `lint` - Run ESLint
- `format` - Run Prettier
- `type-check` - TypeScript checking
- `build` - Build for production
- `dev` - Development server

**If missing, add to package.json:**

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "tsc && vite build",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
    "lint:fix": "eslint . --ext .js,.jsx,.ts,.tsx --fix",
    "format": "prettier --write \"**/*.{js,jsx,ts,tsx,json,css,md}\"",
    "format:check": "prettier --check \"**/*.{js,jsx,ts,tsx,json,css,md}\"",
    "type-check": "tsc --noEmit"
  }
}
```

### Step 5: Setup ESLint

**Check if ESLint configured:**

```bash
ls .eslintrc.js .eslintrc.json .eslintrc.yml eslint.config.js
```

**If not configured, initialize:**

```bash
npm init @eslint/config
# or for npm 7+
npm create @eslint/config

# Answer prompts:
# - How would you like to use ESLint? → To check syntax, find problems, and enforce code style
# - What type of modules? → JavaScript modules (import/export)
# - Which framework? → React/Vue/None
# - Does your project use TypeScript? → Yes/No
# - Where does your code run? → Browser/Node
# - How would you like to define a style? → Use a popular style guide
# - Which style guide? → Airbnb/Standard/Google
# - What format? → JavaScript
```

**Example .eslintrc.js for TypeScript + React:**

```javascript
module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended",
    "prettier", // Must be last
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: "latest",
    sourceType: "module",
    project: "./tsconfig.json",
  },
  plugins: ["@typescript-eslint", "react", "react-hooks"],
  rules: {
    "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
    "@typescript-eslint/no-explicit-any": "warn",
    "react/react-in-jsx-scope": "off", // Not needed in React 17+
    "react/prop-types": "off", // Using TypeScript
  },
  settings: {
    react: {
      version: "detect",
    },
  },
};
```

**Run ESLint:**

```bash
npm run lint
```

**Auto-fix:**

```bash
npm run lint:fix
```

### Step 6: Setup Prettier

**Install Prettier:**

```bash
npm install --save-dev prettier eslint-config-prettier
```

**Create .prettierrc.json:**

```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 88,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "always",
  "endOfLine": "lf"
}
```

**Create .prettierignore:**

```
node_modules
dist
build
coverage
.next
.cache
*.min.js
*.min.css
package-lock.json
yarn.lock
pnpm-lock.yaml
```

**Run Prettier:**

```bash
npm run format:check
```

**Auto-format:**

```bash
npm run format
```

### Step 7: Setup TypeScript (if TypeScript project)

**Check for tsconfig.json:**

```bash
ls tsconfig.json
```

**If doesn't exist, initialize:**

```bash
npx tsc --init
```

**Example tsconfig.json:**

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "allowJs": true,
    "checkJs": false,
    "jsx": "react-jsx",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist",
    "removeComments": true,
    "noEmit": false,
    "importHelpers": true,
    "isolatedModules": true,
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "skipLibCheck": true
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist", "build"]
}
```

**Run type checking:**

```bash
npm run type-check
```

### Step 8: Setup Testing (Jest or Vitest)

**Detect test framework:**

```bash
grep -E '"(jest|vitest)"' package.json
```

#### If using Jest:

**Install Jest:**

```bash
npm install --save-dev jest @types/jest ts-jest
```

**Create jest.config.js:**

```javascript
module.exports = {
  preset: "ts-jest",
  testEnvironment: "jsdom", // or 'node'
  roots: ["<rootDir>/src", "<rootDir>/tests"],
  testMatch: ["**/__tests__/**/*.ts?(x)", "**/?(*.)+(spec|test).ts?(x)"],
  collectCoverageFrom: [
    "src/**/*.{js,jsx,ts,tsx}",
    "!src/**/*.d.ts",
    "!src/**/*.stories.tsx",
  ],
  coverageThreshold: {
    global: {
      branches: 90,
      functions: 90,
      lines: 90,
      statements: 90,
    },
  },
  setupFilesAfterEnv: ["<rootDir>/jest.setup.js"],
};
```

#### If using Vitest:

**Install Vitest:**

```bash
npm install --save-dev vitest @vitest/ui
```

**Create vitest.config.ts:**

```typescript
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    globals: true,
    environment: "jsdom", // or 'node'
    setupFiles: ["./vitest.setup.ts"],
    coverage: {
      provider: "v8",
      reporter: ["text", "json", "html"],
      exclude: [
        "node_modules/",
        "dist/",
        "**/*.d.ts",
        "**/*.config.{js,ts}",
        "**/tests/**",
      ],
      thresholds: {
        lines: 90,
        functions: 90,
        branches: 90,
        statements: 90,
      },
    },
  },
});
```

**Run tests:**

```bash
npm test
```

**Run with coverage:**

```bash
npm run test:coverage
```

**Report:**

```
✅ Tests completed

Tests run: X
Tests passed: X
Tests failed: Y
Coverage: Z%

Coverage report: coverage/index.html
```

### Step 9: Setup Husky + lint-staged (Git Hooks)

**Install husky and lint-staged:**

```bash
npm install --save-dev husky lint-staged
npx husky install
```

**Add to package.json:**

```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,css,md}": ["prettier --write"]
  }
}
```

**Create pre-commit hook:**

```bash
npx husky add .husky/pre-commit "npx lint-staged"
```

**Create pre-push hook:**

```bash
npx husky add .husky/pre-push "npm run type-check && npm test"
```

### Step 10: Verify Build

**Run build:**

```bash
npm run build
```

**Report:**

```
✅ Build successful

Output: dist/
Size: X MB
Time: Y seconds
```

### Step 11: Create/Update Scripts in package.json

**Ensure all scripts are present:**

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest run --coverage",
    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
    "lint:fix": "eslint . --ext .js,.jsx,.ts,.tsx --fix",
    "format": "prettier --write \"**/*.{js,jsx,ts,tsx,json,css,md}\"",
    "format:check": "prettier --check \"**/*.{js,jsx,ts,tsx,json,css,md}\"",
    "type-check": "tsc --noEmit",
    "prepare": "husky install",
    "clean": "rm -rf dist build coverage .next"
  }
}
```

### Step 12: Summary Report

```
✅ Node.js Development Environment Setup Complete

Node version: v20.10.0
npm version: 10.2.3
Package manager: npm

Dependencies:
✅ node_modules - X packages installed

Tooling:
✅ ESLint - Configured and passing
✅ Prettier - Configured
✅ TypeScript - Type checking passed
✅ Jest/Vitest - Tests passing (Z% coverage)
✅ Husky - Git hooks installed
✅ lint-staged - Pre-commit checks configured

Quick Commands:
- Dev: npm run dev
- Build: npm run build
- Test: npm test OR npm run test:coverage
- Lint: npm run lint OR npm run lint:fix
- Format: npm run format
- Type check: npm run type-check

Ready to start development!
```

---

