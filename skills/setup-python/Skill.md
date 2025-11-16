---
name: Python Development Setup
description: Sets up Python development environment: virtual environment, dependencies, pytest, linting (flake8, black), type checking (mypy). Ensures consistent setup.
version: 1.0.0
---

# ⚠️ MANDATORY: Python Development Setup Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Starting work on Python project
2. After cloning Python repository
3. When setting up CI/CD for Python
4. When troubleshooting Python environment

**This skill is MANDATORY because:**
- Ensures consistent development environment
- Prevents dependency conflicts
- Sets up proper testing and linting
- Enforces code quality standards
- Reduces "works on my machine" issues

**ENFORCEMENT:**

**P1 Violations (High - Quality Failure):**
- Not using virtual environment
- Missing linting/formatting tools
- No type checking setup
- Missing test framework
- Outdated dependencies

**P2 Violations (Medium - Efficiency Loss):**
- Not using Makefile for common tasks
- Missing git hooks
- Unclear setup documentation

**Blocking Conditions:**
- Must use virtual environment
- Must have linting configured
- Must have testing framework
- Must have type checking

---

## Purpose

Sets up Python development environment with virtual environment, dependencies, testing framework, linting, and type checking.

## Workflow

### Step 1: Verify Python Installation
```bash
python --version  # Python 3.9+
```

### Step 2: Create Virtual Environment
```bash
python -m venv venv
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate  # Windows
```

### Step 3: Install Dependencies
```bash
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

### Step 4: Setup Linting & Formatting
```bash
# Install tools
pip install black flake8 isort mypy

# Create .flake8 config
pip install -c constraints.txt flake8 black mypy
```

### Step 5: Setup Testing
```bash
pip install pytest pytest-cov pytest-mock

# Run tests
pytest --cov=. --cov-report=html
```

### Step 6: Setup Type Checking
```bash
mypy .
```

### Step 7: Create Makefile
```makefile
.PHONY: test lint format type-check clean all

test:
	pytest --cov=. --cov-report=term-missing

lint:
	flake8 .

format:
	black .
	isort .

type-check:
	mypy .

clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	rm -rf .pytest_cache .mypy_cache

all: format lint type-check test
```

### Step 8: Setup Git Hooks
```bash
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
set -e
echo "Running pre-commit checks..."
black . --check
flake8 .
mypy .
pytest
echo "✅ Pre-commit checks passed"
EOF
chmod +x .git/hooks/pre-commit
```

## Configuration Files

### requirements.txt
```
flask==2.3.0
sqlalchemy==2.0.0
python-dotenv==1.0.0
```

### requirements-dev.txt
```
-r requirements.txt
pytest==7.0.0
pytest-cov==4.0.0
black==23.0.0
flake8==6.0.0
mypy==1.0.0
```

### pyproject.toml
```toml
[tool.black]
line-length = 88

[tool.isort]
profile = "black"

[tool.mypy]
python_version = "3.9"
strict = true
```

### .flake8
```
[flake8]
max-line-length = 88
extend-ignore = E203, W503
```

## Testing Framework

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=. --cov-report=html

# Run specific test
pytest tests/test_models.py::test_user_creation
```

## Common Commands

```bash
# Activate environment
source venv/bin/activate

# Install packages
pip install package_name

# Freeze dependencies
pip freeze > requirements.txt

# Format code
black .
isort .

# Lint code
flake8 .

# Type check
mypy .

# Run tests
pytest

# Generate coverage
pytest --cov=. --cov-report=html
```

## Anti-Patterns

### ❌ Anti-Pattern: Installing Globally

**Wrong:**
```bash
pip install package_name  # Global installation
```

**Correct:**
```bash
source venv/bin/activate  # Activate venv first
pip install package_name  # Install in venv
```

---

## References

**Based on:**
- CLAUDE.md Section 3 (Available Skills Reference - setup-python)
- Python best practices

**Related skills:**
- `quality-check` - Invokes linting/type-checking
- `run-tests` - Runs pytest tests
