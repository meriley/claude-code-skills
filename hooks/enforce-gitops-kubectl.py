#!/usr/bin/env python3
"""
Hook: Enforce GitOps workflow for kubectl mutations.
Hard blocks all kubectl mutation commands, requires GitOps workflow.
Exit code 2 = BLOCK (mutation detected)
Exit code 0 = ALLOW (read-only or dry-run)
"""
import json
import sys
import re

# ============================================================================
# KUBECTL MUTATION COMMANDS - BLOCK THESE
# ============================================================================

# Primary mutation verbs that modify cluster state
MUTATION_VERBS = [
    r"\bapply\b",
    r"\bcreate\b",
    r"\bedit\b",
    r"\bpatch\b",
    r"\bdelete\b",
    r"\breplace\b",
    r"\bscale\b",
    r"\bautoscale\b",
    r"\brollout\s+(restart|undo|pause|resume)\b",
    r"\bset\b",  # set image, set resources, set env, etc.
    r"\blabel\b",
    r"\bannotate\b",
    r"\bexpose\b",
    r"\brun\b",
    r"\bdrain\b",
    r"\bcordon\b",
    r"\buncordon\b",
    r"\btaint\b",
    r"\battach\b",
    r"\bexec\b",  # Can modify container state
    r"\bcp\b",  # Can modify files in containers
    r"\bport-forward\b",  # Can be used for state modification
]

# Secondary mutation patterns (imperative operations)
IMPERATIVE_PATTERNS = [
    r"\bkubectl\s+.*--force\b",  # Force operations
    r"\bkubectl\s+.*--grace-period=0\b",  # Immediate deletion
    r"\bkubectl\s+.*--now\b",  # Immediate operations
]

# ============================================================================
# READ-ONLY COMMANDS - ALLOW THESE
# ============================================================================

READ_ONLY_VERBS = [
    r"\bget\b",
    r"\bdescribe\b",
    r"\blogs\b",
    r"\bexplain\b",
    r"\bdiff\b",
    r"\bapi-resources\b",
    r"\bapi-versions\b",
    r"\bversion\b",
    r"\bcluster-info\b",
    r"\btop\b",
    r"\bauth\s+can-i\b",
    r"\bconfig\s+view\b",  # View config only
    r"\brollout\s+status\b",  # Status check only
    r"\brollout\s+history\b",  # History view only
    r"\bwait\b",  # Wait for condition (read-only)
]

# ============================================================================
# DRY-RUN PATTERNS - ALLOW THESE
# ============================================================================

DRY_RUN_PATTERNS = [
    r"--dry-run\b",
    r"--dry-run=client\b",
    r"--dry-run=server\b",
]

# ============================================================================
# VALIDATION LOGIC
# ============================================================================


def is_kubectl_command(command: str) -> bool:
    """Check if command is a kubectl command."""
    # Match kubectl at start of command or after pipe/semicolon
    return bool(re.search(r"(^|[|;&]\s*)kubectl\b", command, re.IGNORECASE))


def is_dry_run(command: str) -> bool:
    """Check if command uses dry-run flag."""
    for pattern in DRY_RUN_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return True
    return False


def is_read_only(command: str) -> bool:
    """Check if command is read-only."""
    # Extract the kubectl verb (first argument after kubectl)
    # Match: kubectl [flags] <verb> [...]
    # Handle both long flags (--flag) and short flags (-f)
    verb_match = re.search(
        r"\bkubectl\s+(?:(?:--?[^\s]+\s+)*)([a-z-]+)", command, re.IGNORECASE
    )
    if not verb_match:
        return False

    verb_context = verb_match.group(0)  # Full match including kubectl

    # Check if any read-only verb matches
    for verb_pattern in READ_ONLY_VERBS:
        if re.search(verb_pattern, verb_context, re.IGNORECASE):
            return True

    return False


def is_mutation(command: str) -> bool:
    """Check if command is a mutation operation."""
    # Extract the kubectl verb area
    # Handle both long flags (--flag) and short flags (-f)
    verb_match = re.search(
        r"\bkubectl\s+(?:(?:--?[^\s]+\s+)*)([a-z-]+(?:\s+[a-z-]+)?)",
        command,
        re.IGNORECASE,
    )
    if not verb_match:
        return False

    verb_context = verb_match.group(0)

    # Check mutation verbs
    for verb_pattern in MUTATION_VERBS:
        if re.search(verb_pattern, verb_context, re.IGNORECASE):
            return True

    # Check imperative patterns on full command
    for pattern in IMPERATIVE_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return True

    return False


def extract_verb(command: str) -> str:
    """Extract the kubectl verb for error messages."""
    # Handle both long flags (--flag) and short flags (-f)
    match = re.search(
        r"\bkubectl\s+(?:(?:--?[^\s]+\s+)*)([a-z-]+(?:\s+[a-z-]+)?)",
        command,
        re.IGNORECASE,
    )
    if match:
        return match.group(1)
    return "unknown"


# ============================================================================
# MAIN LOGIC
# ============================================================================

try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError as e:
    print(f"Error parsing JSON input: {e}", file=sys.stderr)
    sys.exit(1)

tool_name = input_data.get("tool_name", "")
command = input_data.get("tool_input", {}).get("command", "")

# Only check Bash commands
if tool_name != "Bash" or not command:
    sys.exit(0)

# Only check kubectl commands
if not is_kubectl_command(command):
    sys.exit(0)

# Allow dry-run operations (planning/validation)
if is_dry_run(command):
    sys.exit(0)

# Allow read-only operations
if is_read_only(command):
    sys.exit(0)

# Block mutations
if is_mutation(command):
    verb = extract_verb(command)

    print("", file=sys.stderr)
    print("=" * 70, file=sys.stderr)
    print("🚫 KUBECTL MUTATION BLOCKED - GITOPS REQUIRED", file=sys.stderr)
    print("=" * 70, file=sys.stderr)
    print("", file=sys.stderr)
    print(f"Command: kubectl {verb}", file=sys.stderr)
    print("", file=sys.stderr)
    print(
        "Direct kubectl mutations are FORBIDDEN in this environment.", file=sys.stderr
    )
    print("All cluster changes MUST go through GitOps workflow.", file=sys.stderr)
    print("", file=sys.stderr)
    print("WHY: GitOps ensures:", file=sys.stderr)
    print("  - Auditable change history (git log)", file=sys.stderr)
    print("  - Peer review (pull requests)", file=sys.stderr)
    print("  - Rollback capability (git revert)", file=sys.stderr)
    print("  - Disaster recovery (git clone)", file=sys.stderr)
    print("  - Infrastructure as Code (declarative manifests)", file=sys.stderr)
    print("", file=sys.stderr)
    print("PROPER WORKFLOW:", file=sys.stderr)
    print("  1. Use the gitops-apply skill", file=sys.stderr)
    print("  2. Update manifest in git repository", file=sys.stderr)
    print("  3. Commit changes with conventional format", file=sys.stderr)
    print("  4. ArgoCD/Flux will sync to cluster", file=sys.stderr)
    print("", file=sys.stderr)
    print("To proceed with GitOps workflow, say:", file=sys.stderr)
    print("  'Use gitops-apply skill to make this change'", file=sys.stderr)
    print("", file=sys.stderr)
    print("READ-ONLY OPERATIONS (allowed):", file=sys.stderr)
    print("  kubectl get, describe, logs, explain, diff, top, etc.", file=sys.stderr)
    print("", file=sys.stderr)
    print("DRY-RUN OPERATIONS (allowed):", file=sys.stderr)
    print("  kubectl apply --dry-run=client", file=sys.stderr)
    print("  kubectl create --dry-run=server", file=sys.stderr)
    print("", file=sys.stderr)
    print("=" * 70, file=sys.stderr)
    print("", file=sys.stderr)

    sys.exit(2)  # EXIT CODE 2 = BLOCK

# Default: allow (conservative - only block known mutations)
sys.exit(0)
