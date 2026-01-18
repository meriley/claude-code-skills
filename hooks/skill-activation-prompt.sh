#!/bin/bash
# UserPromptSubmit hook - skill reminder with project context awareness

cat <<'EOF'
<skill-check>
BEFORE responding, evaluate which skills apply:
1. SCAN skill categories: Git ops, Language setup, Domain (OBS/Vendure/Helm/etc), Testing, Docs
2. For each YES skill → Call Skill(skill-name) IMMEDIATELY
3. Then proceed with implementation

Quick reference: check-history (new tasks), safe-commit (commits), safe-destroy (destructive ops)
Full list: See Skill tool description above.

PROJECT CONTEXT: Check SessionStart output for "Project Detection" - if present, prioritize suggested skills for detected project types.

OUTPUT REQUIRED: Start response with brief skill acknowledgment:
**Skills:** `skill-name` - invoked | `skill-name` - skipped (reason) | none applicable (reason)
</skill-check>
EOF
