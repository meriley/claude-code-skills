### Step 9: PRD Task Auto-Update (Optional)

If the commit message contains a PRD task reference, update the progress tracker.

**Pattern Detection:**
Look for these patterns in the commit message:

- `[PRD Task N]` - e.g., `[PRD Task 2]`
- `[Task N]` - e.g., `[Task 2]`

**If pattern detected:**

1. **Get commit info:**

   ```bash
   git log -1 --format='%H %cs' HEAD
   ```

   Extract: short hash (first 7 chars), date (YYYY-MM-DD)

2. **Find associated PRD file:**
   - Look for PRD files in `docs/`, `specs/`, or project root
   - Search for file containing "Implementation Progress" section

3. **Update progress tracker:**
   - Find task row matching task number
   - Update `Status` to `Done`
   - Fill in `Completed` date
   - Add commit hash (short form, e.g., `abc1234`)
   - Update Progress Summary counts

4. **Report to user:**
   ```
   📋 PRD Task 2 marked as completed
   - Completed: 2024-01-16
   - Commit: abc1234
   - Updated: docs/shipping-feature-prd.md
   ```

**If PRD file not found:**

- Skip silently (task reference may be manual tracking)
- No error needed

**Example:**

```
feat(orders): add createOrder mutation [PRD Task 2]
```

After commit, the PRD progress tracker updates automatically:

```markdown
| 2 | Add createOrder mutation | Done | 2024-01-15 | 2024-01-16 | abc1234 |
```

