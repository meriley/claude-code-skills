# Cursor Rules Templates

This file contains copy-paste ready templates for creating Cursor rules in .mdc format.

---

## Template 1: Basic Rule (File-Based Triggering)

```markdown
---
description: Brief description of what this rule provides. Include what context it covers and when it applies.
globs: ["**/*.ext", "**/*.pattern"]
alwaysApply: false
---

# Rule Title

## Overview
One paragraph explaining what context this rule provides and when it's useful.

**Related rules:** See @related-rule.mdc for additional context.

---

## Key Concepts

### Concept 1
Explanation with examples.

### Concept 2
More guidance.

---

## Examples

### Example 1: Common Pattern

**Input:**
\`\`\`language
// Code example
\`\`\`

**Output/Pattern:**
\`\`\`language
// Expected pattern
\`\`\`

---

## Resources

- [Link to documentation](https://example.com)
- [Internal wiki](https://wiki.example.com)

---

**This rule is maintained by [TEAM] and should be reviewed [FREQUENCY] for updates.**
```

---

## Template 2: Always-Apply Rule (Universal Context)

```markdown
---
description: Project-wide architecture patterns and conventions that apply to all code. Provides core context for the entire codebase.
alwaysApply: true
---

# Project Architecture

## Overview
This rule provides universal context about project architecture, design patterns, and coding conventions that apply across all files.

**Related rules:** See @specific-pattern.mdc for technology-specific patterns.

---

## Project Structure

\`\`\`
project/
├── src/
│   ├── api/         # API routes and controllers
│   ├── services/    # Business logic
│   ├── models/      # Data models
│   └── utils/       # Utility functions
├── tests/           # Test files
└── docs/            # Documentation
\`\`\`

---

## Core Conventions

### Naming Conventions
- Files: kebab-case (my-component.tsx)
- Classes: PascalCase (MyComponent)
- Functions: camelCase (handleClick)
- Constants: UPPER_SNAKE_CASE (API_BASE_URL)

### Error Handling
All errors must be logged and returned with proper status codes.

---

## Design Patterns

### Pattern 1: Service Layer
All business logic lives in service layer, not controllers.

\`\`\`typescript
// ✅ Good
class UserService {
  async createUser(data: CreateUserDTO) {
    // Business logic here
  }
}

// ❌ Bad
app.post('/users', (req, res) => {
  // Business logic in controller
});
\`\`\`

---

## Resources

- [Architecture Decision Records](./docs/adr/)
- [Coding Standards](./docs/standards.md)

---

**This rule is maintained by the architecture team and should be reviewed quarterly.**
```

---

## Template 3: Manual-Only Rule (Troubleshooting/Reference)

```markdown
---
description: Advanced debugging techniques for [SPECIFIC ISSUE]. Use when diagnosing [PROBLEM TYPE] or troubleshooting [SCENARIO].
---

# Advanced [TOPIC] Debugging

## Overview
This rule provides specialized troubleshooting guidance for [SPECIFIC ISSUE]. Manually invoke with @this-rule.mdc when debugging.

**When to use this rule:**
- Diagnosing [specific problem]
- Performance issues related to [area]
- Investigating [type of bug]

**Related rules:** See @general-patterns.mdc for standard approaches.

---

## Diagnostic Steps

### Step 1: Initial Investigation
\`\`\`bash
# Commands to gather information
\`\`\`

### Step 2: Root Cause Analysis
Check for these common causes:
- [ ] Cause 1
- [ ] Cause 2
- [ ] Cause 3

### Step 3: Resolution
\`\`\`language
// Fix implementation
\`\`\`

---

## Common Issues and Solutions

### Issue 1: [Problem Description]

**Symptoms:**
- Symptom 1
- Symptom 2

**Solution:**
\`\`\`language
// Code fix
\`\`\`

**Prevention:**
Best practices to avoid this issue.

---

## Troubleshooting Checklist

- [ ] Verified [condition]
- [ ] Checked [component]
- [ ] Tested [scenario]
- [ ] Reviewed [logs/metrics]

---

## Resources

- [Debugging Guide](https://example.com/debug)
- [Known Issues](https://github.com/org/repo/issues)

---

**This rule is maintained by [TEAM] and updated as new issues are discovered.**
```

---

## Template 4: Technology-Specific Rule

```markdown
---
description: [FRAMEWORK/LIBRARY] best practices including [KEY AREAS]. Apply when working with [TECHNOLOGY] code.
globs: ["**/*.[ext]", "**/[pattern]/**/*"]
alwaysApply: false
---

# [Technology] Best Practices

## Overview
This rule provides guidance for working with [TECHNOLOGY] in this project, including [KEY TOPICS].

**Related rules:** See @general-architecture.mdc for project-wide patterns, @testing.mdc for test guidance.

---

## Setup and Configuration

### Installation
\`\`\`bash
# Installation commands
\`\`\`

### Configuration
\`\`\`language
// Configuration example
\`\`\`

---

## Core Patterns

### Pattern 1: [Pattern Name]

**When to use:**
Description of when this pattern applies.

**Implementation:**
\`\`\`language
// ✅ Good - Proper implementation
\`\`\`

**Anti-patterns:**
\`\`\`language
// ❌ Bad - Common mistakes
\`\`\`

### Pattern 2: [Pattern Name]

Similar structure...

---

## Common Scenarios

### Scenario 1: [Use Case]

**Requirements:**
- Requirement 1
- Requirement 2

**Implementation:**
\`\`\`language
// Complete working example
\`\`\`

---

## Testing

### Unit Testing
\`\`\`language
// Test example
\`\`\`

### Integration Testing
\`\`\`language
// Integration test example
\`\`\`

---

## Performance Considerations

- Optimization tip 1
- Optimization tip 2
- Common performance pitfalls

---

## Resources

- [Official Documentation](https://example.com)
- [Project-Specific Guidelines](./docs/tech-guide.md)
- [API Reference](https://api.example.com)

---

**This rule is maintained by the [TEAM] team and should be reviewed [FREQUENCY].**
```

---

## Template 5: Configuration Files Rule

```markdown
---
description: Configuration file patterns and schemas for [CONFIG TYPE]. Apply when creating or modifying [CONFIG FILES].
globs: ["**/*.config.{js,ts}", "**/.*rc", "**/.*rc.{json,yaml}"]
alwaysApply: false
---

# Configuration Files Guide

## Overview
This rule provides guidance for working with project configuration files, including schemas, validation, and best practices.

**Related rules:** See @project-architecture.mdc for overall structure, @deployment.mdc for environment-specific configs.

---

## Configuration Schema

### Base Configuration
\`\`\`typescript
interface ProjectConfig {
  environment: 'development' | 'staging' | 'production';
  api: {
    baseUrl: string;
    timeout: number;
  };
  features: {
    [key: string]: boolean;
  };
}
\`\`\`

---

## Configuration Files

### Development (config.dev.ts)
\`\`\`typescript
export const config: ProjectConfig = {
  environment: 'development',
  api: {
    baseUrl: 'http://localhost:3000',
    timeout: 5000,
  },
  features: {
    debugMode: true,
  },
};
\`\`\`

### Production (config.prod.ts)
\`\`\`typescript
export const config: ProjectConfig = {
  environment: 'production',
  api: {
    baseUrl: process.env.API_BASE_URL!,
    timeout: 10000,
  },
  features: {
    debugMode: false,
  },
};
\`\`\`

---

## Best Practices

### Security
- ✅ Never commit secrets (use environment variables)
- ✅ Validate all configuration at startup
- ✅ Use TypeScript for type safety
- ❌ Don't hardcode API keys or passwords
- ❌ Don't expose internal URLs in client configs

### Environment Variables
\`\`\`typescript
// ✅ Good - Validated at startup
const config = {
  apiKey: requireEnv('API_KEY'),
  dbUrl: requireEnv('DATABASE_URL'),
};

function requireEnv(key: string): string {
  const value = process.env[key];
  if (!value) {
    throw new Error(\`Missing required environment variable: \${key}\`);
  }
  return value;
}
\`\`\`

---

## Validation

### Runtime Validation
\`\`\`typescript
import { z } from 'zod';

const configSchema = z.object({
  environment: z.enum(['development', 'staging', 'production']),
  api: z.object({
    baseUrl: z.string().url(),
    timeout: z.number().positive(),
  }),
});

// Validate on startup
configSchema.parse(config);
\`\`\`

---

## Resources

- [Configuration Guidelines](./docs/config.md)
- [Environment Setup](./docs/env-setup.md)

---

**This rule is maintained by the platform team and should be reviewed quarterly.**
```

---

## Template 6: API/Service Rule

```markdown
---
description: API design patterns and endpoint conventions for [SERVICE NAME]. Apply when creating or modifying API routes.
globs: ["**/api/**/*", "**/routes/**/*", "**/controllers/**/*"]
alwaysApply: false
---

# API Design Patterns

## Overview
This rule provides guidance for designing and implementing API endpoints following project conventions and RESTful principles.

**Related rules:** See @error-handling.mdc for error patterns, @authentication.mdc for auth guidance.

---

## Endpoint Conventions

### URL Structure
\`\`\`
/api/v1/resource
/api/v1/resource/:id
/api/v1/resource/:id/subresource
\`\`\`

### HTTP Methods
- GET: Retrieve resource(s)
- POST: Create new resource
- PUT: Update entire resource
- PATCH: Partially update resource
- DELETE: Remove resource

---

## Request/Response Patterns

### Successful Response
\`\`\`typescript
{
  "data": { /* resource data */ },
  "meta": {
    "timestamp": "2024-01-15T12:00:00Z",
    "version": "v1"
  }
}
\`\`\`

### Error Response
\`\`\`typescript
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "User not found",
    "details": {}
  }
}
\`\`\`

---

## Implementation Pattern

### Controller Template
\`\`\`typescript
export class ResourceController {
  async list(req: Request, res: Response) {
    try {
      const resources = await this.service.findAll();
      res.json({ data: resources });
    } catch (error) {
      logger.error('Failed to list resources', { error });
      res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to retrieve resources'
        }
      });
    }
  }

  async get(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const resource = await this.service.findById(id);

      if (!resource) {
        return res.status(404).json({
          error: {
            code: 'RESOURCE_NOT_FOUND',
            message: 'Resource not found'
          }
        });
      }

      res.json({ data: resource });
    } catch (error) {
      logger.error('Failed to get resource', { error, id: req.params.id });
      res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to retrieve resource'
        }
      });
    }
  }

  async create(req: Request, res: Response) {
    try {
      const data = req.body;
      const resource = await this.service.create(data);
      res.status(201).json({ data: resource });
    } catch (error) {
      if (error instanceof ValidationError) {
        return res.status(400).json({
          error: {
            code: 'VALIDATION_ERROR',
            message: error.message,
            details: error.fields
          }
        });
      }
      logger.error('Failed to create resource', { error });
      res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to create resource'
        }
      });
    }
  }
}
\`\`\`

---

## Validation

### Input Validation
\`\`\`typescript
import { z } from 'zod';

const createResourceSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().positive(),
});

// In controller
const validated = createResourceSchema.parse(req.body);
\`\`\`

---

## Resources

- [API Documentation](https://api.example.com/docs)
- [REST API Guidelines](./docs/api-guidelines.md)

---

**This rule is maintained by the API team and should be reviewed quarterly.**
```

---

## Quick Usage Guide

### 1. Choose appropriate template based on rule type:
- **Template 1**: Standard file-based rule
- **Template 2**: Universal context (always applied)
- **Template 3**: On-demand troubleshooting
- **Template 4**: Technology-specific guidance
- **Template 5**: Configuration files
- **Template 6**: API/service patterns

### 2. Copy template to .cursor/rules/
\`\`\`bash
cp template.md .cursor/rules/my-rule.mdc
\`\`\`

### 3. Customize:
- Replace placeholders in [BRACKETS]
- Update glob patterns for your file types
- Add project-specific examples
- Update cross-references

### 4. Test:
- Open file matching glob pattern
- Start Cursor chat
- Verify rule loads
- Test @-mention

---

**These templates follow the cursor-rules-writing skill best practices and should be adapted to your project's needs.**
