# Cursor Rules Examples

This file provides concrete examples of good and bad Cursor rules to illustrate best practices.

---

## Example 1: Frontmatter Quality

### ❌ Bad Example - Vague and Unfocused

```markdown
---
description: Helps with files and stuff.
alwaysApply: true
---

# Helper

This rule helps you work with files.
```

**Problems:**
- Description is vague ("files and stuff")
- No indication of what context is provided
- No indication of when to use it
- alwaysApply will load in every chat (context bloat)
- Content is not actionable

---

### ✅ Good Example - Specific and Focused

```markdown
---
description: Helm chart best practices for Chart.yaml structure, values.yaml organization, and template helper patterns. Apply when creating or modifying Helm charts.
globs: ["**/Chart.yaml", "**/values*.yaml", "**/templates/**/*.yaml", "**/_helpers.tpl"]
alwaysApply: false
---

# Helm Chart Writing Patterns

## Overview
This rule provides guidance for writing production-ready Helm charts following team conventions and Kubernetes best practices.

**Related rules:** See @helm-chart-review.mdc for quality checklists, @helm-deployment.mdc for deployment strategies.

---

## Chart.yaml Structure

### Required Fields
\`\`\`yaml
apiVersion: v2
name: myapp
description: Production-ready application chart
type: application
version: 1.0.0
appVersion: "1.16.0"
\`\`\`

[... continues with concrete, actionable guidance ...]
```

**Why it's good:**
- Description is specific about what context is provided
- Description explains when to apply ("creating or modifying Helm charts")
- Glob patterns target exact file types
- alwaysApply is false (loaded only when relevant)
- Content is actionable with concrete examples
- Cross-references related rules

---

## Example 2: Glob Pattern Precision

### ❌ Bad Example - Too Broad

```markdown
---
description: TypeScript patterns and best practices.
globs: ["**/*"]
---
```

**Problems:**
- Glob matches ALL files
- Will load TypeScript context for Python, Markdown, YAML, etc.
- Causes context pollution
- Wastes token budget on irrelevant files

---

### ❌ Bad Example - Too Narrow

```markdown
---
description: Component patterns for React.
globs: ["components/*.tsx"]
---
```

**Problems:**
- Only matches `components/*.tsx` at root
- Misses `src/components/*.tsx`
- Misses nested component directories
- Will fail to load in most projects

---

### ✅ Good Example - Precise Targeting

```markdown
---
description: React component patterns including hooks, props typing, and performance optimization. Apply when working with React components.
globs: [
  "**/*.tsx",
  "**/components/**/*.ts",
  "**/hooks/**/*.ts",
  "**/__tests__/**/*.test.{ts,tsx}"
]
---
```

**Why it's good:**
- Recursive patterns (`**/`) match nested directories
- Covers all React-related files
- Includes test files
- Multiple extensions using `{ts,tsx}` syntax
- Won't load for Python, YAML, or Markdown files

---

## Example 3: Cross-References and Modularity

### ❌ Bad Example - Monolithic Rule

```markdown
---
description: Everything about the project including architecture, API design, database schemas, deployment, testing, and documentation.
alwaysApply: true
---

# Complete Project Guide

[3000 lines of mixed content covering every aspect of the project]
```

**Problems:**
- Single 3000-line file (performance issues)
- Always loaded (huge context bloat)
- Mixes unrelated concerns
- Hard to maintain
- Most content irrelevant for any given task

---

### ✅ Good Example - Modular Rules with Cross-References

```markdown
<!-- architecture-core.mdc -->
---
description: Project architecture overview and core design patterns used across all services. Provides foundational context for the codebase.
alwaysApply: true
---

# Core Architecture

## Overview
This rule provides high-level architectural context that applies to all code in the project.

**Related rules:**
- @api-patterns.mdc for API design
- @database-patterns.mdc for data access
- @deployment-guide.mdc for deployment procedures
- @testing-patterns.mdc for test conventions

---

## System Architecture

[Focused content on core architecture - 250 lines]
```

```markdown
<!-- api-patterns.mdc -->
---
description: REST API design patterns including endpoint structure, request/response formats, error handling, and validation. Apply when working with API code.
globs: ["**/api/**/*", "**/routes/**/*", "**/controllers/**/*"]
alwaysApply: false
---

# API Design Patterns

## Overview
This rule provides API-specific guidance following RESTful principles and team conventions.

**Related rules:** See @architecture-core.mdc for general patterns, @error-handling.mdc for error patterns.

---

## Endpoint Conventions

[Focused content on APIs - 400 lines]
```

**Why it's good:**
- Each rule under 500 lines (performance optimized)
- Core architecture always loaded (short and focused)
- Specific patterns loaded only when relevant files are open
- Clear cross-references allow manual loading when needed
- Easy to maintain individual rules
- Users can compose context as needed

---

## Example 4: Content Quality

### ❌ Bad Example - Vague Instructions

```markdown
# Error Handling

Make sure to handle errors properly. Always catch exceptions and return appropriate HTTP status codes. Be careful about security.
```

**Problems:**
- No concrete examples
- Vague "make sure" and "be careful" language
- No actionable guidance
- Doesn't show what "proper" means

---

### ✅ Good Example - Concrete Patterns

```markdown
# Error Handling

## Standard Pattern

All API endpoints must implement consistent error handling:

\`\`\`typescript
// ✅ Good - Complete error handling
app.get('/api/users/:id', async (req, res) => {
  try {
    const user = await userService.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        error: {
          code: 'USER_NOT_FOUND',
          message: 'User not found',
          details: { userId: req.params.id }
        }
      });
    }

    res.json({ data: user });
  } catch (error) {
    logger.error('Failed to fetch user', {
      error,
      userId: req.params.id,
      path: req.path
    });

    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'An unexpected error occurred',
        requestId: req.id
      }
    });
  }
});

// ❌ Bad - No error handling
app.get('/api/users/:id', async (req, res) => {
  const user = await userService.findById(req.params.id);
  res.json(user);
});

// ❌ Bad - Generic catch-all
app.get('/api/users/:id', async (req, res) => {
  try {
    const user = await userService.findById(req.params.id);
    res.json(user);
  } catch (e) {
    res.status(500).send('Error');
  }
});
\`\`\`

## Error Response Format

All errors must follow this structure:

\`\`\`typescript
interface ErrorResponse {
  error: {
    code: string;           // Machine-readable error code
    message: string;        // Human-readable message
    details?: unknown;      // Additional context
    requestId?: string;     // For tracking
  };
}
\`\`\`

## Status Code Guidelines

| Status Code | Use Case | Example |
|-------------|----------|---------|
| 400 | Validation error | Invalid request body |
| 401 | Authentication required | Missing or invalid token |
| 403 | Forbidden | User lacks permission |
| 404 | Resource not found | User ID doesn't exist |
| 409 | Conflict | Email already registered |
| 500 | Server error | Database connection failed |
```

**Why it's good:**
- Concrete code examples
- Shows good AND bad patterns
- Explains the "why" with comments
- Provides structured guidance (interface, table)
- Actionable and copy-paste ready

---

## Example 5: File Length Management

### ❌ Bad Example - Too Long

```markdown
---
description: Complete guide to working with databases.
globs: ["**/*.sql", "**/models/**/*", "**/migrations/**/*"]
---

# Database Guide

[1500 lines covering:]
- Schema design
- Migration patterns
- Query optimization
- ORM usage
- Connection pooling
- Backup procedures
- Monitoring
- Security
- Testing
- Deployment
```

**Problems:**
- 1500 lines causes slow loading
- Mixes many unrelated concerns
- Hard to maintain
- Context overload

---

### ✅ Good Example - Focused and Composable

```markdown
<!-- database-core.mdc -->
---
description: Core database patterns including schema design, naming conventions, and connection management. Apply when working with database code.
globs: ["**/models/**/*", "**/repositories/**/*"]
alwaysApply: false
---

# Database Core Patterns

## Overview
This rule provides foundational database guidance for schema design and connection management.

**Related rules:**
- @database-migrations.mdc for migration patterns
- @database-queries.mdc for query optimization
- @database-testing.mdc for test data management

---

[Focused content - 400 lines]
```

```markdown
<!-- database-migrations.mdc -->
---
description: Database migration patterns including versioning, rollback procedures, and data migrations. Apply when creating or modifying migrations.
globs: ["**/migrations/**/*", "**/seeds/**/*"]
alwaysApply: false
---

# Database Migration Patterns

## Overview
This rule provides guidance for creating safe, reversible database migrations.

**Related rules:** See @database-core.mdc for schema patterns.

---

[Focused content - 350 lines]
```

**Why it's good:**
- Each rule under 500 lines
- Focused on single concern
- Clear separation of topics
- Easy to load just what's needed
- Cross-references for related context

---

## Example 6: Always Apply vs File-Based

### ❌ Bad Example - Overusing Always Apply

```markdown
---
description: API design patterns and best practices.
alwaysApply: true
---

# API Patterns

[500 lines of API-specific guidance]
```

**Problems:**
- Loads API context when editing tests, docs, or config files
- Wastes token budget
- Not relevant for non-API work
- Should use globs instead

---

### ✅ Good Example - Appropriate Always Apply

```markdown
---
description: Project-wide coding conventions including naming, file organization, and commit message format. Core standards that apply to all code.
alwaysApply: true
---

# Project Conventions

## Overview
This rule provides universal conventions that apply to all code in the project, regardless of language or framework.

**Related rules:** See @typescript-patterns.mdc, @python-patterns.mdc for language-specific guidance.

---

## Naming Conventions

- Files: kebab-case (my-component.tsx)
- Classes/Types: PascalCase (UserService)
- Functions/Variables: camelCase (getUserById)
- Constants: UPPER_SNAKE_CASE (API_BASE_URL)

## Directory Structure

\`\`\`
project/
├── src/           # Source code
├── tests/         # Test files
├── docs/          # Documentation
└── scripts/       # Build/utility scripts
\`\`\`

## Commit Messages

Follow Conventional Commits:
- feat: New feature
- fix: Bug fix
- docs: Documentation only
- refactor: Code change without behavior change
- test: Adding or updating tests

[... continues with truly universal content - 250 lines]
```

**Why it's good:**
- Content truly applies to ALL files
- Short and focused (250 lines)
- Doesn't duplicate language-specific patterns
- Cross-references detailed rules

---

### ✅ Good Example - File-Based Triggering

```markdown
---
description: TypeScript type safety patterns including branded types, type guards, and runtime validation. Apply when working with TypeScript code.
globs: ["**/*.ts", "**/*.tsx"]
alwaysApply: false
---

# TypeScript Type Safety

## Overview
This rule provides TypeScript-specific type safety patterns and best practices.

**Related rules:** See @project-conventions.mdc for general naming conventions.

---

## Branded Types for IDs

\`\`\`typescript
// ✅ Good - Type-safe IDs
type UserId = string & { __brand: 'UserId' };
type ProductId = string & { __brand: 'ProductId' };

function getUserById(id: UserId): User { /* ... */ }
function getProductById(id: ProductId): Product { /* ... */ }

// Type error - can't mix different ID types
const userId: UserId = '123' as UserId;
getProductById(userId);  // Error!

// ❌ Bad - Stringly typed
function getUserById(id: string): User { /* ... */ }
function getProductById(id: string): Product { /* ... */ }

// No type safety - can accidentally pass wrong ID
getUserById(productId);  // Compiles but wrong!
\`\`\`

[... continues with TypeScript-specific content - 450 lines]
```

**Why it's good:**
- Only loads for TypeScript files
- Content is specific to TypeScript
- Doesn't pollute context for Python, YAML, etc.
- alwaysApply false (loaded on-demand)

---

## Summary of Best Practices

### Do's ✅
- Write specific, actionable descriptions
- Use recursive glob patterns (`**/`)
- Keep rules under 500 lines
- Show concrete code examples
- Use ✅/❌ for good/bad patterns
- Cross-reference related rules
- Separate concerns into focused rules
- Use alwaysApply only for truly universal content

### Don'ts ❌
- Don't use vague descriptions ("helps with files")
- Don't use overly broad globs (`**/*`)
- Don't create monolithic 1000+ line rules
- Don't give abstract advice without examples
- Don't duplicate content across rules
- Don't use alwaysApply for file-specific context
- Don't mix unrelated concerns in one rule

---

**These examples follow the cursor-rules-writing skill best practices and demonstrate real-world patterns.**
