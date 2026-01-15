---

### Step 4: ASK - Get Explicit Confirmation

**Required response:**

- User MUST type the specific command they want to execute
- OR explicitly say "proceed with [operation]"
- OR choose option B from the menu

**Examples of VALID confirmation:**

- "yes, run git reset --hard"
- "proceed with permanent deletion"
- "I understand, delete the files"
- "B" (from the menu)

**Examples of INVALID confirmation:**

- "ok" (too vague)
- "do it" (unclear what 'it' is)
- "sure" (not explicit enough)

**If confirmation ambiguous:**

```
Please explicitly confirm by typing:
"I want to run git reset --hard"

or select option B from the menu.
```

---

### Step 5: WAIT - Do Not Proceed Until Explicit Approval

**STOP all processing until user responds.**

Do not:

- Assume silence means approval
- Interpret "looks good" as approval
- Proceed after timeout

---

### Step 6: VERIFY - Confirm the Specific Command

Once user responds, verify they understand:

```
Confirming: You want to execute 'git reset --hard'

This will permanently delete:
- All uncommitted changes
- Cannot be recovered

Type 'CONFIRM' to proceed:
```

**Double confirmation for especially dangerous operations.**

---

### Step 7: Execute (Only After Explicit Approval)

If user confirms, execute the command:

```bash
git reset --hard
```

**Report result:**

```
✅ Operation completed

Executed: git reset --hard
HEAD is now at a1b2c3d Last commit message

Working directory has been reset.
All uncommitted changes have been discarded.
```

