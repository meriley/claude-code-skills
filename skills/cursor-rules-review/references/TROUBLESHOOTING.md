## Common Issues & Solutions

### Issue: Rule Not Triggering

**Symptoms:**

- Rule should trigger but doesn't appear
- Glob patterns look correct

**Debug:**

```bash
# Test glob pattern
find . -path "**/*.test.ts"

# Check frontmatter syntax
head -n 10 .cursor/rules/rule-name.mdc

# Verify Cursor settings
cat .cursor/settings.json
```

**Solutions:**

- Fix glob pattern syntax
- Ensure frontmatter is valid YAML
- Check file is in `.cursor/rules/` directory
- Restart Cursor IDE

---

### Issue: Context Bloat

**Symptoms:**

- Too much context loaded
- Slow Cursor performance
- Responses include irrelevant information

**Debug:**

```bash
# Check for overly broad patterns
grep "globs:" .cursor/rules/*.mdc | grep "\*\*/\*"

# Check for too many alwaysApply rules
grep "alwaysApply: true" .cursor/rules/*.mdc
```

**Solutions:**

- Make glob patterns more specific
- Use `alwaysApply: true` sparingly
- Split large rules into smaller, focused rules
- Consider file-based triggering over alwaysApply

---

### Issue: Broken Cross-References

**Symptoms:**

- `@referenced-rule` doesn't load
- Error in Cursor logs

**Debug:**

```bash
# Find all cross-references
grep "@" .cursor/rules/my-rule.mdc

# Check if referenced files exist
ls .cursor/rules/referenced-rule.mdc
```

**Solutions:**

- Fix filename (case-sensitive)
- Ensure referenced rule exists
- Use correct `@filename` syntax (without `.mdc`)

