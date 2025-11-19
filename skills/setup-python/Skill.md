---
name: Python Development Setup
description: Sets up Python development environment with virtual environment, dependencies, testing framework (pytest), linting (flake8, black), and type checking (mypy). Ensures consistent development environment.
version: 1.0.0
---

# Python Development Setup Skill

## Purpose
Quickly set up and verify a Python development environment with all necessary tooling.

## When to Use
- Starting work on a Python project
- After cloning a Python repository
- When setting up CI/CD for Python
- When troubleshooting Python environment issues

## Workflow

### Step 1: Verify Python Installation

```bash
python3 --version
```

**Expected**: Python 3.9 or higher

**If not installed:**
```
❌ Python3 not found

Install Python:
- macOS: brew install python@3.11
- Linux: sudo apt install python3.11 python3.11-venv
- Windows: https://python.org/downloads

After installing, verify: python3 --version
```

### Step 2: Create Virtual Environment

**Check if venv exists:**
```bash
ls venv/ .venv/ 2>/dev/null
```

**If doesn't exist, create:**
```bash
python3 -m venv venv
```

**Activate virtual environment:**
```bash
# macOS/Linux
source venv/bin/activate

# Windows
venv\Scripts\activate
```

**Verify activation:**
```bash
which python  # Should point to venv/bin/python
```

**Report:**
```
✅ Virtual environment activated

Python location: venv/bin/python
Python version: 3.11.5
```

### Step 3: Upgrade pip

```bash
pip install --upgrade pip setuptools wheel
```

### Step 4: Install Project Dependencies

**Check for requirements file:**
```bash
ls requirements.txt requirements-dev.txt setup.py pyproject.toml
```

**Install dependencies:**

**If `requirements.txt` exists:**
```bash
pip install -r requirements.txt
```

**If `requirements-dev.txt` exists:**
```bash
pip install -r requirements-dev.txt
```

**If `setup.py` exists:**
```bash
pip install -e .
```

**If `pyproject.toml` exists (modern Python projects):**
```bash
pip install -e ".[dev]"
# or
pip install .
```

**Report installed packages:**
```bash
pip list
```

### Step 5: Setup Testing (pytest)

**Install pytest if not installed:**
```bash
pip install pytest pytest-cov pytest-mock
```

**Create pytest.ini if doesn't exist:**

```ini
[pytest]
testpaths = tests
python_files = test_*.py *_test.py
python_classes = Test*
python_functions = test_*
addopts = 
    -v
    --strict-markers
    --tb=short
    --cov=.
    --cov-report=term-missing
    --cov-report=html
```

**Run tests:**
```bash
pytest
```

**Run with coverage:**
```bash
pytest --cov=. --cov-report=term-missing --cov-report=html
```

**Report:**
```
✅ Tests completed

Tests run: X
Tests passed: X
Tests failed: Y
Coverage: Z%

Coverage report: htmlcov/index.html
```

### Step 6: Setup Linting (flake8)

**Install flake8:**
```bash
pip install flake8
```

**Create .flake8 config if doesn't exist:**

```ini
[flake8]
max-line-length = 88
extend-ignore = E203, W503
exclude = 
    .git,
    __pycache__,
    venv,
    .venv,
    build,
    dist,
    *.egg-info
per-file-ignores =
    __init__.py:F401
```

**Run flake8:**
```bash
flake8 .
```

**Report:**
```
✅ Linting passed

No style violations found.
```

**If violations found:**
```
❌ Linting issues found

[Show violations]

Run 'black .' to auto-format code.
```

### Step 7: Setup Code Formatting (black)

**Install black:**
```bash
pip install black
```

**Create pyproject.toml config (if doesn't exist):**

```toml
[tool.black]
line-length = 88
target-version = ['py39', 'py310', 'py311']
include = '\.pyi?$'
extend-exclude = '''
/(
  # directories
  \.eggs
  | \.git
  | \.venv
  | venv
  | build
  | dist
)/
'''
```

**Check formatting:**
```bash
black --check .
```

**Auto-format:**
```bash
black .
```

**Report:**
```
✅ Code formatted

Formatted X files
Left Y files unchanged
```

### Step 8: Setup Import Sorting (isort)

**Install isort:**
```bash
pip install isort
```

**Add to pyproject.toml:**

```toml
[tool.isort]
profile = "black"
line_length = 88
multi_line_output = 3
include_trailing_comma = true
force_grid_wrap = 0
use_parentheses = true
ensure_newline_before_comments = true
```

**Run isort:**
```bash
isort --check-only .
```

**Auto-fix imports:**
```bash
isort .
```

### Step 9: Setup Type Checking (mypy)

**Install mypy:**
```bash
pip install mypy
```

**Create mypy.ini config:**

```ini
[mypy]
python_version = 3.11
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
disallow_incomplete_defs = True
check_untyped_defs = True
no_implicit_optional = True
warn_redundant_casts = True
warn_unused_ignores = True
warn_no_return = True
strict_equality = True

[mypy-tests.*]
disallow_untyped_defs = False
```

**Run mypy:**
```bash
mypy .
```

**Report:**
```
✅ Type checking passed

Checked X files
No type errors found
```

### Step 10: Create/Verify Makefile

```makefile
.PHONY: install test lint format type-check clean all

install:
	pip install --upgrade pip
	pip install -r requirements-dev.txt
	pip install -e .

test:
	pytest -v

coverage:
	pytest --cov=. --cov-report=term-missing --cov-report=html

lint:
	flake8 .

format:
	black .
	isort .

format-check:
	black --check .
	isort --check-only .

type-check:
	mypy .

clean:
	rm -rf build dist *.egg-info
	rm -rf .pytest_cache .mypy_cache .coverage htmlcov
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name '*.pyc' -delete

all: format lint type-check test
```

**Verify Makefile:**
```bash
make all
```

### Step 11: Setup Pre-commit Hooks

**Install pre-commit:**
```bash
pip install pre-commit
```

**Create .pre-commit-config.yaml:**

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-json
      - id: check-merge-conflict

  - repo: https://github.com/psf/black
    rev: 23.12.1
    hooks:
      - id: black

  - repo: https://github.com/pycqa/isort
    rev: 5.13.2
    hooks:
      - id: isort

  - repo: https://github.com/pycqa/flake8
    rev: 7.0.0
    hooks:
      - id: flake8

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.8.0
    hooks:
      - id: mypy
        additional_dependencies: [types-all]
```

**Install git hooks:**
```bash
pre-commit install
```

**Test hooks:**
```bash
pre-commit run --all-files
```

### Step 12: Create requirements files

**Generate requirements.txt from current environment:**
```bash
pip freeze > requirements.txt
```

**Split into dev and prod:**

**requirements.txt** (production):
```
flask==3.0.0
requests==2.31.0
psycopg2-binary==2.9.9
```

**requirements-dev.txt** (development):
```
-r requirements.txt
pytest==7.4.3
pytest-cov==4.1.0
black==23.12.1
flake8==7.0.0
isort==5.13.2
mypy==1.8.0
pre-commit==3.6.0
```

### Step 13: Summary Report

```
✅ Python Development Environment Setup Complete

Python version: 3.11.5
Virtual environment: venv/

Dependencies:
✅ requirements.txt - X packages installed
✅ requirements-dev.txt - Y packages installed

Tooling:
✅ pytest - Tests passing (Z% coverage)
✅ black - Code formatted
✅ isort - Imports sorted
✅ flake8 - No style violations
✅ mypy - Type checking passed
✅ pre-commit - Git hooks installed
✅ Makefile - Created with common targets

Quick Commands:
- Test: make test OR pytest
- Coverage: make coverage
- Lint: make lint OR flake8 .
- Format: make format OR black . && isort .
- Type check: make type-check OR mypy .
- Run all checks: make all

Ready to start development!

Don't forget to activate venv: source venv/bin/activate
```

---

## Common Python Commands Reference

### Virtual Environment
```bash
python3 -m venv venv          # Create venv
source venv/bin/activate      # Activate (macOS/Linux)
venv\Scripts\activate         # Activate (Windows)
deactivate                    # Deactivate
```

### Package Management
```bash
pip install <package>         # Install package
pip install -r requirements.txt  # Install from file
pip install -e .              # Install in editable mode
pip uninstall <package>       # Uninstall package
pip list                      # List installed packages
pip freeze                    # Generate requirements
pip install --upgrade <package>  # Update package
```

### Testing
```bash
pytest                        # Run all tests
pytest tests/test_file.py     # Run specific file
pytest -v                     # Verbose output
pytest -k "test_name"         # Run tests matching name
pytest --cov=.                # With coverage
pytest --cov-report=html      # HTML coverage report
pytest -x                     # Stop on first failure
pytest --pdb                  # Drop into debugger on failure
```

### Code Quality
```bash
black .                       # Format code
black --check .               # Check formatting
isort .                       # Sort imports
flake8 .                      # Lint code
mypy .                        # Type check
```

---

## Troubleshooting

### Issue: "command not found: python3"
**Solution**: Python not installed or not in PATH
```bash
# macOS
brew install python@3.11

# Ubuntu/Debian
sudo apt install python3.11
```

### Issue: "No module named 'venv'"
**Solution**: venv module not installed
```bash
# Ubuntu/Debian
sudo apt install python3.11-venv
```

### Issue: "pip: command not found" (inside venv)
**Solution**: venv not activated or corrupted
```bash
deactivate
rm -rf venv
python3 -m venv venv
source venv/bin/activate
```

### Issue: "ModuleNotFoundError: No module named 'X'"
**Solution**: Dependency not installed
```bash
pip install -r requirements.txt
# or
pip install <module-name>
```

### Issue: "pytest: command not found"
**Solution**: pytest not installed
```bash
pip install pytest
```

---

## Best Practices

1. **Always use virtual environments** - Never install packages globally
2. **Pin dependency versions** - Use `==` in requirements.txt
3. **Separate dev dependencies** - Use requirements-dev.txt
4. **Run black + isort** - Before committing
5. **Enable mypy** - Catch type errors early
6. **Use pre-commit hooks** - Automate checks
7. **Target 90%+ coverage** - Comprehensive testing
8. **Keep requirements updated** - Regularly check for security updates

---

## Integration with Other Skills

This skill may be invoked by:
- **`quality-check`** - When checking Python code quality
- **`run-tests`** - When running Python tests
