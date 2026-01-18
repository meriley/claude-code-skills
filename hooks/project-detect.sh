#!/bin/bash
# Hook: Detect project type at session start for skill awareness
# Target: < 50ms execution (file existence checks + limited grep)

# Arrays to collect results
declare -a TYPES=()
declare -a SKILLS=()
declare -a KEY_FILES=()

# Helper to add type and skills
add_project() {
    local type="$1"
    shift
    TYPES+=("$type")
    for skill in "$@"; do
        # Avoid duplicates
        if [[ ! " ${SKILLS[*]} " =~ " ${skill} " ]]; then
            SKILLS+=("$skill")
        fi
    done
}

# Go project
if [[ -f "go.mod" ]]; then
    KEY_FILES+=("go.mod")
    add_project "go" "setup-go" "control-flow-check"
fi

# Python project
if [[ -f "pyproject.toml" ]]; then
    KEY_FILES+=("pyproject.toml")
    add_project "python" "setup-python"
elif [[ -f "requirements.txt" ]]; then
    KEY_FILES+=("requirements.txt")
    add_project "python" "setup-python"
fi

# Node.js / TypeScript project
if [[ -f "package.json" ]]; then
    KEY_FILES+=("package.json")
    add_project "nodejs" "setup-node"

    # Check for TypeScript
    if [[ -f "tsconfig.json" ]]; then
        KEY_FILES+=("tsconfig.json")
        add_project "typescript" "type-safety-audit"
    fi

    # Check for specific frameworks (limited grep on small file)
    if grep -q "@vendure" package.json 2>/dev/null; then
        add_project "vendure" "vendure-developing" "vendure-plugin-writing"
    fi

    if grep -q "@playwright/test" package.json 2>/dev/null; then
        add_project "playwright" "playwright-writing" "playwright-reviewing"
    fi

    if grep -q "@mantine" package.json 2>/dev/null; then
        add_project "mantine" "mantine-developing"
    fi
fi

# Rust project
if [[ -f "Cargo.toml" ]]; then
    KEY_FILES+=("Cargo.toml")
    add_project "rust"
fi

# OBS plugin project (CMakeLists.txt + libobs reference)
if [[ -f "CMakeLists.txt" ]]; then
    KEY_FILES+=("CMakeLists.txt")
    if grep -q "libobs\|obs-frontend-api\|OBS_PLUGIN" CMakeLists.txt 2>/dev/null; then
        add_project "obs-plugin" "obs-plugin-developing" "obs-cross-compiling"
    fi
fi

# Helm chart
if [[ -f "Chart.yaml" ]]; then
    KEY_FILES+=("Chart.yaml")
    add_project "helm" "helm-chart-writing" "gitops-apply"
fi

# Kubernetes manifests
if [[ -d "k8s" ]] || [[ -d "manifests" ]] || [[ -d "kubernetes" ]]; then
    if [[ -d "k8s" ]]; then KEY_FILES+=("k8s/"); fi
    if [[ -d "manifests" ]]; then KEY_FILES+=("manifests/"); fi
    if [[ -d "kubernetes" ]]; then KEY_FILES+=("kubernetes/"); fi
    add_project "kubernetes" "gitops-apply" "gitops-audit"
fi

# Output only if we detected something
if [[ ${#TYPES[@]} -gt 0 ]]; then
    # Format arrays as JSON-like strings for output
    TYPES_STR=$(printf ", %s" "${TYPES[@]}")
    TYPES_STR="[${TYPES_STR:2}]"

    SKILLS_STR=$(printf ", %s" "${SKILLS[@]}")
    SKILLS_STR="[${SKILLS_STR:2}]"

    KEY_FILES_STR=$(printf ", %s" "${KEY_FILES[@]}")
    KEY_FILES_STR="[${KEY_FILES_STR:2}]"

    cat << EOF
Project Detection:
- Types: ${TYPES_STR}
- Suggested skills: ${SKILLS_STR}
- Key files: ${KEY_FILES_STR}
EOF
fi

exit 0
