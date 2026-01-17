#!/bin/bash
# UserPromptSubmit hook - minimal skill reminder leveraging native progressive disclosure

cat <<'EOF'
<skill-check>
BEFORE responding, evaluate which skills apply:
1. SCAN skill categories: Git ops, Language setup, Domain (OBS/Vendure/Helm/etc), Testing, Docs
2. For each YES skill → Call Skill(skill-name) IMMEDIATELY
3. Then proceed with implementation

Quick reference: check-history (new tasks), safe-commit (commits), safe-destroy (destructive ops)
Full list: See Skill tool description above.
</skill-check>
EOF
