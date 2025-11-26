# Cursor Rules Reference

This file provides detailed technical guidance on advanced Cursor rules topics.

---

## Section 1: Advanced Glob Patterns

### Pattern Syntax Details

**Wildcard Operators:**

| Pattern | Matches | Examples |
|---------|---------|----------|
| `*` | Any characters except `/` | `*.ts` matches `file.ts`, not `dir/file.ts` |
| `**` | Any characters including `/` | `**/*.ts` matches `file.ts`, `dir/file.ts`, `a/b/c/file.ts` |
| `?` | Single character | `file?.ts` matches `file1.ts`, `fileA.ts`, not `file10.ts` |
| `[abc]` | One of a, b, or c | `file[123].ts` matches `file1.ts`, `file2.ts`, `file3.ts` |
| `[a-z]` | Range from a to z | `file[a-z].ts` matches `filea.ts` through `filez.ts` |
| `[!abc]` | NOT a, b, or c | `file[!0-9].ts` matches `filea.ts`, not `file1.ts` |
| `{a,b}` | Pattern a OR pattern b | `*.{js,ts}` matches `file.js` and `file.ts` |

### Complex Pattern Examples

```yaml
# Match TypeScript files in src, excluding tests
globs: ["src/**/*.ts", "src/**/*.tsx", "!src/**/*.test.{ts,tsx}"]

# Match configuration files with multiple extensions
globs: [
  "**/*.config.{js,ts,mjs}",
  "**/.*rc",
  "**/.*rc.{json,yaml,yml}"
]

# Match specific directory structures
globs: [
  "**/components/**/*.tsx",
  "**/hooks/use[A-Z]*.ts",
  "**/pages/**/[a-z]*.tsx"
]

# Match Helm chart files
globs: [
  "**/Chart.yaml",
  "**/values*.yaml",
  "**/templates/**/*.yaml",
  "**/_helpers.tpl",
  "!**/charts/**/*"  # Exclude dependency charts
]
```

### Negation Patterns

**Exclude specific files or directories:**

```yaml
globs: [
  "**/*.ts",           # Include all TypeScript
  "!**/*.test.ts",     # Exclude test files
  "!**/node_modules/**",  # Exclude dependencies
  "!**/dist/**"        # Exclude build output
]
```

**Order matters:**
```yaml
# ✅ Correct - exclusion after inclusion
globs: ["**/*.ts", "!**/*.test.ts"]

# ❌ Incorrect - inclusion after exclusion (test.ts files will match)
globs: ["!**/*.test.ts", "**/*.ts"]
```

### Platform-Specific Patterns

**Case sensitivity:**
- Unix/Linux: Case-sensitive (`File.ts` ≠ `file.ts`)
- macOS: Case-insensitive by default
- Windows: Case-insensitive

**Path separators:**
- Always use forward slashes `/` in patterns
- Cursor normalizes paths internally
- `**/*.ts` works on all platforms

### Testing Glob Patterns

```bash
# Unix/Linux/macOS - test glob patterns
find . -path "**/Chart.yaml"
ls **/*.ts  # (requires globstar: shopt -s globstar)

# Using fd (cross-platform)
fd --glob "**/*.ts"

# Using ripgrep
rg --files --glob "**/*.ts"
```

### Performance Considerations

**Optimize glob patterns for performance:**

```yaml
# ✅ Efficient - specific path prefix
globs: ["src/components/**/*.tsx"]

# ⚠️ Slower - searches entire project
globs: ["**/*.tsx"]

# ✅ More efficient - multiple specific patterns
globs: [
  "src/components/**/*.tsx",
  "src/pages/**/*.tsx",
  "src/layouts/**/*.tsx"
]

# ❌ Inefficient - overlapping broad patterns
globs: ["**/*.tsx", "src/**/*.tsx", "tests/**/*.tsx"]
```

---

## Section 2: Rule Composition Strategies

### Layered Architecture

**Structure rules in layers from general to specific:**

```
Layer 1: Universal Context (alwaysApply: true)
├─ project-conventions.mdc (naming, structure, standards)
└─ architecture-core.mdc (system design, patterns)

Layer 2: Technology-Specific (globs by file type)
├─ typescript-patterns.mdc (globs: **/*.ts, **/*.tsx)
├─ python-patterns.mdc (globs: **/*.py)
└─ yaml-patterns.mdc (globs: **/*.{yaml,yml})

Layer 3: Domain-Specific (globs by directory)
├─ api-patterns.mdc (globs: **/api/**/*.ts)
├─ database-patterns.mdc (globs: **/models/**/*.ts)
└─ frontend-patterns.mdc (globs: **/components/**/*.tsx)

Layer 4: Specialized (manual-only)
├─ debugging-guide.mdc (troubleshooting reference)
├─ migration-guide.mdc (upgrade procedures)
└─ performance-tuning.mdc (optimization techniques)
```

### Rule Dependency Graph

**Plan rule relationships before creating:**

```
architecture-core.mdc (always applied)
    ↓ references ↓
├─ api-patterns.mdc (when editing API files)
│   ↓ references ↓
│   ├─ error-handling.mdc (manual reference)
│   └─ authentication.mdc (manual reference)
│
├─ database-patterns.mdc (when editing models)
│   ↓ references ↓
│   ├─ migrations.mdc (when editing migrations)
│   └─ query-optimization.mdc (manual reference)
│
└─ frontend-patterns.mdc (when editing components)
    ↓ references ↓
    ├─ react-hooks.mdc (when editing hooks)
    └─ state-management.mdc (manual reference)
```

### Monorepo Strategies

**For monorepos with multiple projects:**

```yaml
# Root-level universal rules
.cursor/rules/
├── project-conventions.mdc (alwaysApply: true)

# Service-specific rules
apps/api/.cursor/rules/
├── api-patterns.mdc (globs: **/*.ts)

apps/web/.cursor/rules/
├── frontend-patterns.mdc (globs: **/*.tsx)

# Shared library rules
packages/shared/.cursor/rules/
├── library-patterns.mdc (globs: **/*.ts)
```

**Cursor loads rules from:**
1. Workspace root `.cursor/rules/`
2. Nested `.cursor/rules/` in subdirectories
3. Rules cascade based on file location

### Incremental Adoption

**Phase 1: Start with always-apply core**
```yaml
# project-conventions.mdc
---
description: Core project conventions.
alwaysApply: true
---
[200 lines of universal context]
```

**Phase 2: Add file-type rules**
```yaml
# typescript-patterns.mdc
---
description: TypeScript best practices.
globs: ["**/*.ts", "**/*.tsx"]
---
[400 lines of TypeScript guidance]
```

**Phase 3: Add domain-specific rules**
```yaml
# api-patterns.mdc
---
description: API design patterns.
globs: ["**/api/**/*"]
---
[450 lines of API guidance]
```

**Phase 4: Add manual reference rules**
```yaml
# debugging-guide.mdc
---
description: Advanced debugging techniques.
---
[400 lines of troubleshooting]
```

---

## Section 3: Performance Optimization

### Token Budget Management

**Cursor has limited context window - optimize token usage:**

```
Typical token budget breakdown:
├─ System prompt: ~1000 tokens
├─ Conversation history: ~4000 tokens
├─ Current file(s): ~2000-10000 tokens
├─ Rules context: ~2000-5000 tokens (your control)
└─ Response generation: ~2000-4000 tokens
```

**Optimization strategies:**

1. **Keep always-apply rules SHORT (<300 lines ideal)**
   ```yaml
   # ✅ Good - concise universal context
   ---
   description: Core conventions (200 lines).
   alwaysApply: true
   ---
   ```

2. **Use precise globs to avoid unnecessary loading**
   ```yaml
   # ✅ Good - loads only for Helm files
   globs: ["**/Chart.yaml", "**/values*.yaml"]

   # ❌ Bad - loads for all YAML files
   globs: ["**/*.yaml"]
   ```

3. **Split large rules into focused units**
   ```
   database-guide.mdc (1500 lines) ❌
   ↓ split into ↓
   database-core.mdc (400 lines) ✅
   database-migrations.mdc (350 lines) ✅
   database-queries.mdc (400 lines) ✅
   database-testing.mdc (350 lines) ✅
   ```

4. **Use manual-only rules for reference material**
   ```yaml
   # Don't auto-load large troubleshooting docs
   ---
   description: Comprehensive debugging guide.
   # No globs, no alwaysApply
   ---
   [800 lines of reference material]
   ```

### Measuring Rule Impact

**Check rule effectiveness:**

```bash
# Count total rules
ls -l .cursor/rules/*.mdc | wc -l

# Check rule sizes
wc -l .cursor/rules/*.mdc | sort -n

# Find rules over 500 lines
find .cursor/rules -name "*.mdc" -exec wc -l {} \; | awk '$1 > 500'

# Estimate token count (rough: 1 line ≈ 3-4 tokens)
wc -l .cursor/rules/*.mdc | awk '{print $2 ": ~" $1 * 3 " tokens"}'
```

### Caching and Lazy Loading

**Cursor optimizations (automatic):**
- Rules are cached after first load
- File-based rules load on file open
- Manual rules load on @-mention
- Changes to rules refresh cache

**Developer optimizations:**
- Keep core rules stable (avoid frequent edits)
- Use git to version rules
- Document rule update process

---

## Section 4: Edge Cases and Troubleshooting

### Issue 1: Rule Not Loading

**Symptoms:**
- Expected context not appearing in chat
- @-mention doesn't work
- Rule seems ignored

**Diagnosis:**

1. **Check file location:**
   ```bash
   # Rules must be in .cursor/rules/
   ls -la .cursor/rules/*.mdc
   ```

2. **Check frontmatter syntax:**
   ```yaml
   # ✅ Correct YAML
   ---
   description: Valid description.
   globs: ["**/*.ts"]
   ---

   # ❌ Incorrect - missing closing ---
   ---
   description: Invalid description.
   globs: ["**/*.ts"]

   # ❌ Incorrect - invalid YAML
   ---
   description: "Missing closing quote
   globs: ["**/*.ts"]
   ---
   ```

3. **Check glob pattern matching:**
   ```bash
   # Test if current file matches glob
   # If editing src/components/Button.tsx
   # Pattern **/*.tsx should match
   echo "src/components/Button.tsx" | grep -E "\.tsx$"
   ```

4. **Check for syntax errors:**
   ```bash
   # Validate YAML frontmatter
   head -n 10 .cursor/rules/my-rule.mdc
   ```

**Solutions:**
- Ensure file is in `.cursor/rules/` directory
- Validate YAML syntax with online validator
- Test glob patterns with `find` or `fd`
- Restart Cursor IDE to refresh rule cache
- Check Cursor logs for errors

### Issue 2: Rules Conflicting

**Symptoms:**
- Contradictory guidance from different rules
- Unexpected context mixing

**Diagnosis:**
```bash
# Find overlapping globs
grep -h "globs:" .cursor/rules/*.mdc

# Check for multiple always-apply rules
grep -l "alwaysApply: true" .cursor/rules/*.mdc
```

**Solutions:**
- Review overlapping globs, make patterns more specific
- Ensure rules have clear separation of concerns
- Use cross-references instead of duplicating content
- Consider rule precedence (later rules override earlier)

### Issue 3: Performance Degradation

**Symptoms:**
- Slow Cursor responses
- High token usage warnings
- Laggy completions

**Diagnosis:**
```bash
# Find large rules
find .cursor/rules -name "*.mdc" -exec wc -l {} \; | sort -n

# Count total lines in all rules
cat .cursor/rules/*.mdc | wc -l

# Count always-apply rules
grep -l "alwaysApply: true" .cursor/rules/*.mdc | wc -l
```

**Solutions:**
- Split rules over 500 lines
- Remove or consolidate always-apply rules
- Use more specific globs to reduce unnecessary loading
- Archive rarely-used rules

### Issue 4: Glob Not Matching Expected Files

**Symptoms:**
- Rule doesn't load for files it should match
- Pattern seems correct but doesn't work

**Common mistakes:**

```yaml
# ❌ Missing recursive operator
globs: ["components/*.tsx"]  # Only matches root components/
# ✅ Correct
globs: ["**/components/*.tsx"]  # Matches any components/ directory

# ❌ Wrong file extension
globs: ["**/*.ts"]  # Doesn't match .tsx files
# ✅ Correct
globs: ["**/*.{ts,tsx}"]  # Matches both

# ❌ Case sensitivity issues
globs: ["**/Chart.yaml"]  # May not match chart.yaml on Linux
# ✅ More robust
globs: ["**/{Chart,chart}.yaml"]

# ❌ Incorrect negation order
globs: ["!**/*.test.ts", "**/*.ts"]  # Tests will match
# ✅ Correct order
globs: ["**/*.ts", "!**/*.test.ts"]  # Tests excluded
```

### Issue 5: Cross-References Not Working

**Symptoms:**
- @-mention doesn't load referenced rule
- "Rule not found" error

**Diagnosis:**
```bash
# Check referenced rule exists
ls .cursor/rules/referenced-rule.mdc

# Check cross-reference syntax
grep "@" .cursor/rules/*.mdc
```

**Solutions:**
- Ensure referenced file exists in `.cursor/rules/`
- Use exact filename including `.mdc` extension
- Check for typos in @-mentions
- Verify file permissions (must be readable)

---

## Section 5: Integration with Cursor Features

### Composer Integration

**Rules work with Cursor Composer:**
- Always-apply rules auto-load
- File-based rules load when files in composer
- Can manually @-mention rules in composer prompts

**Best practices for composer:**
```yaml
# ✅ Good - concise always-apply for composer
---
description: Core patterns for multi-file edits.
alwaysApply: true
---
[250 lines of universal patterns]
```

### Chat vs Inline Edit (Cmd+K)

**Important:** User Rules don't apply to Inline Edit (Cmd/Ctrl+K)

```
Cursor features that USE rules:
├─ Chat (Cmd/Ctrl+L) ✅
├─ Composer (Cmd/Ctrl+I) ✅
└─ @-mentions in any chat ✅

Cursor features that DON'T use rules:
└─ Inline Edit (Cmd/Ctrl+K) ❌
```

**Design rules for chat/composer workflows.**

### Nested Rules in Monorepos

**Cursor loads rules from multiple locations:**

```
workspace-root/
├─ .cursor/rules/
│   └─ root-conventions.mdc  # Applied to all files
├─ apps/
│   └─ api/
│       └─ .cursor/rules/
│           └─ api-patterns.mdc  # Applied to api/ files
└─ packages/
    └─ shared/
        └─ .cursor/rules/
            └─ lib-patterns.mdc  # Applied to shared/ files
```

**Rule precedence:**
1. Workspace root rules (broadest)
2. Nested directory rules (more specific)
3. Closer nesting = higher precedence

### AI Context Prioritization

**How Cursor uses rules:**
1. System prompt (hardcoded instructions)
2. Always-apply rules (your universal context)
3. File-based rules (triggered by open files)
4. Manually @-mentioned rules (explicit user request)
5. Conversation history
6. Current file content

**Optimize for this priority order:**
- Put critical context in always-apply rules
- Use file-based for file-type specifics
- Reserve manual rules for reference material

---

## Section 6: Migration and Versioning

### Migrating from .cursorrules (Legacy)

**Old format (.cursorrules):**
```
Single text file in project root
No metadata
No globs
Always applied
```

**New format (.mdc files):**
```yaml
Multiple .mdc files in .cursor/rules/
YAML frontmatter with metadata
Glob patterns for targeting
Flexible triggering options
```

**Migration steps:**

1. **Create rules directory:**
   ```bash
   mkdir -p .cursor/rules
   ```

2. **Split .cursorrules into focused rules:**
   ```bash
   # Old: Single 2000-line .cursorrules file
   # New: Multiple focused .mdc files
   .cursor/rules/
   ├── core-conventions.mdc (250 lines)
   ├── api-patterns.mdc (400 lines)
   ├── frontend-patterns.mdc (450 lines)
   └── database-patterns.mdc (400 lines)
   ```

3. **Add frontmatter to each rule:**
   ```yaml
   ---
   description: [What this rule provides]
   globs: [File patterns]
   alwaysApply: [true/false]
   ---
   ```

4. **Test new rules:**
   - Open files matching globs
   - Verify context loads
   - Test @-mentions

5. **Archive old .cursorrules:**
   ```bash
   mv .cursorrules .cursorrules.deprecated
   ```

### Versioning Rules

**Use git to version rules:**

```bash
# Track rules in version control
git add .cursor/rules/*.mdc
git commit -m "Add Cursor rules for API patterns"

# Create rule changelog
git log --oneline -- .cursor/rules/

# Diff rule changes
git diff HEAD~1 .cursor/rules/api-patterns.mdc
```

**Document rule versions:**
```markdown
---
**This rule is maintained by the API team and should be reviewed quarterly for updates.**

**Version history:**
- v1.0.0 (2024-01-15): Initial version
- v1.1.0 (2024-02-20): Added error handling patterns
- v1.2.0 (2024-03-15): Updated for new API framework
---
```

### Team Collaboration

**Sharing rules across team:**

```bash
# Rules in git repository
# All team members get same rules
git pull

# Review rule changes in PRs
gh pr create --title "Update API patterns rule"

# Discuss rule changes in team meetings
# Document decisions in commit messages
```

**Rule governance:**
- Designate rule maintainers per domain
- Require PR reviews for rule changes
- Test rules before merging
- Communicate rule updates to team

---

## Section 7: Advanced Patterns

### Conditional Content

**Use environment-specific branches:**

```markdown
## Development Environment

### Local Setup
\`\`\`bash
npm run dev
\`\`\`

### Testing
\`\`\`bash
npm test
\`\`\`

---

## Production Environment

### Deployment
\`\`\`bash
npm run build
helm upgrade production ./charts/myapp
\`\`\`

### Monitoring
Check Grafana dashboard: https://grafana.example.com
```

### Dynamic Examples

**Reference actual project files:**

```markdown
## API Route Pattern

See implementation in:
- `src/api/users.ts` - User management endpoints
- `src/api/products.ts` - Product catalog endpoints
- `src/api/orders.ts` - Order processing endpoints

All routes follow this structure:
\`\`\`typescript
// See src/api/users.ts for complete example
app.get('/api/v1/users', authenticate, async (req, res) => {
  // Implementation
});
\`\`\`
```

### Rule Templates

**Create rule templates for common patterns:**

```bash
# Template for new technology rules
.cursor/templates/
└── tech-pattern-template.mdc

# Use template when adding new tech
cp .cursor/templates/tech-pattern-template.mdc \
   .cursor/rules/new-tech-patterns.mdc
```

### Maintenance Automation

**Automate rule maintenance:**

```bash
# Check rule sizes
#!/bin/bash
# scripts/check-rule-sizes.sh
for rule in .cursor/rules/*.mdc; do
  lines=$(wc -l < "$rule")
  if [ $lines -gt 500 ]; then
    echo "⚠️  $(basename "$rule"): $lines lines (over 500)"
  fi
done

# Validate frontmatter
#!/bin/bash
# scripts/validate-rules.sh
for rule in .cursor/rules/*.mdc; do
  if ! head -n 1 "$rule" | grep -q "^---$"; then
    echo "❌ $(basename "$rule"): Missing frontmatter"
  fi
done

# Add to CI/CD pipeline
# .github/workflows/validate-rules.yml
```

---

## Resources

- [Cursor Documentation](https://cursor.com/docs)
- [Glob Pattern Reference](https://en.wikipedia.org/wiki/Glob_(programming))
- [YAML Specification](https://yaml.org/spec/)
- [Markdown Guide](https://www.markdownguide.org/)

---

**This reference document follows the cursor-rules-writing skill best practices and should be updated as Cursor adds new features.**
