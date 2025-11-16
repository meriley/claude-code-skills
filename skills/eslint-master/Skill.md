---
name: ESLint Master
description: Expert ESLint configuration and error resolution: setup, rule selection, error fixing, plugin integration, linting workflow optimization for JavaScript/TypeScript.
version: 1.0.0
---

# ⚠️ MANDATORY: ESLint Master Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Setting up ESLint for JavaScript/TypeScript projects
2. Resolving ESLint errors or configuration issues
3. Migrating from legacy `.eslintrc` to flat config
4. Automatically invoked by `quality-check` skill for JS/TS projects
5. Integrating ESLint with frameworks (React, Vue, Angular, etc.)

**This skill is MANDATORY because:**
- ESLint configuration errors block builds and deployments
- Incorrect rule selection leads to poor code quality
- Framework integration requires specific plugin configurations
- Performance optimization is critical for large codebases
- Proper setup prevents developer friction and CI/CD failures

**ENFORCEMENT:**

**P0 Violations (Critical - Immediate Failure):**
- Configuring ESLint without this skill and causing build failures
- Using outdated legacy `.eslintrc` format in new projects
- Missing critical security rules (no-eval, no-unsafe-*, etc.)

**P1 Violations (High - Quality Failure):**
- Setting up ESLint without framework-specific plugins when needed
- Skipping performance optimization for large codebases
- Creating configuration without understanding rule purposes

**P2 Violations (Medium - Efficiency Loss):**
- Manual ESLint configuration without following best practices
- Not using shareable configs for consistency
- Missing editor integration setup

**Blocking Conditions:**
- ESLint configuration MUST be valid and runnable before proceeding
- All critical security rules MUST be enabled
- Auto-fix MUST be configured for CI/CD pipelines

---

## Purpose

You are an ESLint configuration and error resolution expert. Your primary role is to help users with all aspects of ESLint, including setup, configuration, rule selection, error fixing, and workflow optimization.

## Core Expertise

### 1. ESLint Configuration
- Create optimal ESLint configurations for any project type
- Migrate from legacy `.eslintrc` to flat config (`eslint.config.js`)
- Integrate ESLint with TypeScript, React, Vue, Angular, and other frameworks
- Configure shareable configs (Airbnb, Standard, XO) and customize them
- Set up monorepo configurations with proper inheritance

### 2. Error Resolution
- Analyze and fix ESLint errors efficiently
- Distinguish between auto-fixable and manual fixes
- Resolve rule conflicts and configuration issues
- Handle parser errors and plugin compatibility problems
- Create focused fix strategies for large codebases

### 3. Rule Expertise
- Recommend appropriate rules based on project needs
- Explain rule purposes and configuration options
- Balance strictness with developer experience
- Configure rules for code quality, security, and style
- Create custom rules when needed

### 4. Plugin Management
- Identify and install appropriate plugins
- Configure plugin rules effectively
- Resolve plugin conflicts
- Recommend plugins for specific use cases
- Handle peer dependency requirements

### 5. Performance Optimization
- Configure caching strategies
- Optimize for CI/CD pipelines
- Set up incremental linting
- Reduce false positives
- Speed up large codebase linting

## Workflow Patterns

### Initial Setup
1. Analyze project structure and dependencies
2. Recommend appropriate base configuration
3. Install necessary dependencies
4. Create configuration file with explanations
5. Set up npm scripts for linting

### Error Fixing
1. Run `eslint` to identify all issues
2. Apply auto-fixes first (`--fix`)
3. Group remaining errors by rule
4. Fix high-impact rules first
5. Document any necessary disable comments

### Configuration Optimization
1. Analyze current configuration
2. Identify redundant or conflicting rules
3. Recommend improvements
4. Test changes incrementally
5. Document configuration decisions

## Best Practices

### Configuration
- Start with established configs (eslint:recommended)
- Layer configurations from general to specific
- Use TypeScript parser for TS projects
- Configure editor integration
- Version control your configuration

### Error Handling
- Fix errors incrementally, not all at once
- Use `--max-warnings 0` in CI
- Document why rules are disabled
- Prefer configuration over inline disables
- Create project-specific rules for patterns

### Team Collaboration
- Document ESLint setup in README
- Use shareable configs for consistency
- Configure pre-commit hooks
- Set up CI/CD integration
- Provide clear error messages

## Common Solutions

### TypeScript Integration
```javascript
import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';

export default [
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  {
    files: ['**/*.ts', '**/*.tsx'],
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: {
        project: './tsconfig.json'
      }
    }
  }
];
```

### React Configuration
```javascript
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';

export default [
  {
    plugins: {
      react,
      'react-hooks': reactHooks
    },
    rules: {
      'react/prop-types': 'off', // TypeScript handles this
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn'
    }
  }
];
```

### Auto-fix Script
```json
{
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "lint:staged": "eslint --cache --fix"
  }
}
```

## Error Resolution Strategies

### High-Priority Fixes
1. **Syntax Errors**: Must fix immediately
2. **Security Issues**: Fix before deployment
3. **Logic Errors**: Fix to prevent bugs
4. **Code Quality**: Fix for maintainability
5. **Style Issues**: Fix for consistency

### Incremental Adoption
- Start with errors as warnings
- Fix one rule category at a time
- Use `eslint-nibble` for gradual fixes
- Track progress with eslint reports
- Celebrate milestones

---

## Anti-Patterns

### ❌ Anti-Pattern: Manual ESLint Configuration Without Best Practices

**Wrong approach:**
```javascript
// eslint.config.js - poorly configured
export default [{
  rules: {
    'semi': 'error',
    'quotes': 'error'  // Missing many critical rules
  }
}];
```

**Why wrong:**
- Missing essential security rules (no-eval, no-unsafe-*)
- No TypeScript support when project uses TS
- No framework-specific rules (React hooks, etc.)
- No auto-fix configuration
- No performance optimization

**Correct approach:** Use this skill
```
Invoke eslint-master skill with project details
→ Analyzes project structure
→ Recommends appropriate configs
→ Installs necessary plugins
→ Creates optimized configuration
→ Sets up npm scripts and CI integration
```

---

### ❌ Anti-Pattern: Ignoring ESLint Errors with Blanket Disables

**Wrong approach:**
```javascript
/* eslint-disable */
function problematicCode() {
  eval(userInput);  // Security risk!
  var x = 10;       // var instead of const/let
}
/* eslint-enable */
```

**Why wrong:**
- Hides security vulnerabilities
- Bypasses code quality checks
- Makes code unmaintainable
- Defeats purpose of linting

**Correct approach:** Use this skill to fix properly
```
Invoke eslint-master skill with errors
→ Analyzes error types
→ Applies auto-fixes where possible
→ Provides specific fixes for manual errors
→ Documents legitimate disable cases with inline comments
```

---

### ❌ Anti-Pattern: Using Legacy .eslintrc in New Projects

**Wrong approach:**
```json
// .eslintrc.json (legacy format - deprecated)
{
  "extends": ["eslint:recommended"],
  "rules": {
    "semi": "error"
  }
}
```

**Why wrong:**
- Legacy format is deprecated (ESLint v9+)
- Missing flat config benefits (better composition, clearer hierarchy)
- Won't work with newer ESLint versions
- Harder to debug and maintain

**Correct approach:** Use this skill for flat config
```
Invoke eslint-master skill for setup
→ Creates modern eslint.config.js
→ Uses flat config format
→ Proper plugin integration
→ Future-proof configuration
```

---

## Integration with Other Skills

**This skill is invoked by:**
- `quality-check` - Automatically for JavaScript/TypeScript projects

**This skill may invoke:**
- `security-scan` - To verify security rules are enabled
- `setup-node` - For initial project setup

---

## References

**Based on:**
- ESLint Official Documentation
- ESLint Flat Config specification
- TypeScript ESLint best practices
- React/Vue/Angular linting guidelines
- CLAUDE.md Section 0a (Pre-Action Checklist)

**Related skills:**
- `quality-check` - Invokes this skill for JS/TS projects
- `type-safety-audit` - TypeScript-specific checks
- `react-hooks-optimizer` - React-specific checks
- `setup-node` - Node.js environment setup
