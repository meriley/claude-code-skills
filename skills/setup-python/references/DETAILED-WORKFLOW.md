## Workflow

### Step 1: Verify UV Installation

```bash
uv --version
```

**Expected**: uv 0.4.0 or higher

**If not installed:**

```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or with pip (one-time exception)
pip install uv

# Or with Homebrew
brew install uv
```

**Verify:**

```bash
uv --version
```

### Step 2: Verify Python Installation

```bash
python3 --version
# or let UV manage Python:
uv python list
```

**Expected**: Python 3.9 or higher

**If not installed, UV can install it:**

```bash
uv python install 3.12
```

### Step 3: Create Virtual Environment

**Check if venv exists:**

```bash
ls .venv/ 2>/dev/null
```

**Create with UV:**

```bash
uv venv
```

This creates `.venv/` in the current directory.

**Activate virtual environment:**

```bash
# macOS/Linux
source .venv/bin/activate

# Windows
.venv\Scripts\activate
```

**Verify activation:**

```bash
which python  # Should point to .venv/bin/python
```

**Report:**

```
✅ Virtual environment created with UV

Python location: .venv/bin/python
Python version: 3.12.0
```

### Step 4: Install Project Dependencies

**Check for dependency files:**

```bash
ls pyproject.toml requirements.txt requirements-dev.txt setup.py 2>/dev/null
```

**Install dependencies with UV:**

**If `pyproject.toml` exists (preferred):**

```bash
# Install project with dependencies
uv pip install -e ".[dev]"
# or
uv sync  # If using uv.lock
```

**If `requirements.txt` exists:**

```bash
uv pip install -r requirements.txt
```

**If `requirements-dev.txt` exists:**

```bash
uv pip install -r requirements-dev.txt
```

**Report installed packages:**

```bash
uv pip list
```

### Step 5: Setup Testing (pytest)

**Install pytest if not installed:**

```bash
uv pip install pytest pytest-cov pytest-mock
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

### Step 6: Setup Linting & Formatting (Ruff)

**Ruff replaces flake8, black, isort, and more - all in one fast tool.**

**Install ruff:**

```bash
uv pip install ruff
```

**Add to pyproject.toml:**

```toml
[tool.ruff]
line-length = 88
target-version = "py312"

[tool.ruff.lint]
select = [
    "E",      # pycodestyle errors
    "W",      # pycodestyle warnings
    "F",      # Pyflakes
    "I",      # isort
    "B",      # flake8-bugbear
    "C4",     # flake8-comprehensions
    "UP",     # pyupgrade
    "ARG",    # flake8-unused-arguments
    "SIM",    # flake8-simplify
]
ignore = ["E501"]  # Line too long (handled by formatter)

[tool.ruff.lint.isort]
known-first-party = ["your_package"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

**Run ruff check:**

```bash
ruff check .
```

**Auto-fix issues:**

```bash
ruff check --fix .
```

**Format code:**

```bash
ruff format .
```

**Check formatting:**

```bash
ruff format --check .
```

**Report:**

```
✅ Linting and formatting passed

No style violations found.
Code properly formatted.
```

### Step 7: Setup Type Checking (mypy)

**Install mypy:**

```bash
uv pip install mypy
```

**Add to pyproject.toml:**

```toml
[tool.mypy]
python_version = "3.12"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
strict_equality = true

[[tool.mypy.overrides]]
module = "tests.*"
disallow_untyped_defs = false
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

### Step 8: Create/Verify pyproject.toml

**Modern Python projects should use pyproject.toml:**

```toml
[project]
name = "my-project"
version = "0.1.0"
description = "My Python project"
readme = "README.md"
requires-python = ">=3.10"
dependencies = [
    "requests>=2.31.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "pytest-cov>=4.1.0",
    "ruff>=0.1.0",
    "mypy>=1.8.0",
    "pre-commit>=3.6.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.ruff]
line-length = 88
target-version = "py312"

[tool.ruff.lint]
select = ["E", "W", "F", "I", "B", "C4", "UP"]

[tool.mypy]
python_version = "3.12"
strict = true
```

### Step 9: Create/Verify Makefile

```makefile
.PHONY: install test lint format type-check clean all

install:
	uv pip install -e ".[dev]"

sync:
	uv sync

test:
	pytest -v

coverage:
	pytest --cov=. --cov-report=term-missing --cov-report=html

lint:
	ruff check .

lint-fix:
	ruff check --fix .

format:
	ruff format .

format-check:
	ruff format --check .

type-check:
	mypy .

clean:
	rm -rf build dist *.egg-info
	rm -rf .pytest_cache .mypy_cache .ruff_cache .coverage htmlcov
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name '*.pyc' -delete

all: format lint type-check test
```

**Verify Makefile:**

```bash
make all
```

### Step 10: Setup Pre-commit Hooks

**Install pre-commit:**

```bash
uv pip install pre-commit
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

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.9
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

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

### Step 11: Generate Lock File (Optional)

**For reproducible builds:**

```bash
uv pip compile pyproject.toml -o requirements.lock
```

**Or use UV's native lock:**

```bash
uv lock
```

**Install from lock:**

```bash
uv sync
```

### Step 12: Summary Report

```
✅ Python Development Environment Setup Complete (UV)

Python version: 3.12.0
Virtual environment: .venv/
Package manager: UV

Dependencies:
✅ pyproject.toml - X packages installed
✅ Dev dependencies - Y packages installed

Tooling:
✅ pytest - Tests passing (Z% coverage)
✅ ruff - Linting and formatting configured
✅ mypy - Type checking passed
✅ pre-commit - Git hooks installed
✅ Makefile - Created with common targets

Quick Commands:
- Install: uv pip install -e ".[dev]"
- Test: make test OR pytest
- Coverage: make coverage
- Lint: make lint OR ruff check .
- Format: make format OR ruff format .
- Type check: make type-check OR mypy .
- Run all checks: make all

Ready to start development!

Don't forget to activate venv: source .venv/bin/activate
```

---

## UV Commands Reference

### Virtual Environment

```bash
uv venv                       # Create .venv
uv venv --python 3.12         # Create with specific Python
source .venv/bin/activate     # Activate (macOS/Linux)
.venv\Scripts\activate        # Activate (Windows)
deactivate                    # Deactivate
```

### Package Management

```bash
uv pip install <package>      # Install package
uv pip install -r requirements.txt  # Install from file
uv pip install -e .           # Install in editable mode
uv pip install -e ".[dev]"    # Install with dev extras
uv pip uninstall <package>    # Uninstall package
uv pip list                   # List installed packages
uv pip freeze                 # Generate requirements
uv pip compile pyproject.toml -o requirements.lock  # Lock deps
uv sync                       # Sync from lock file
```

### Python Management

```bash
uv python list                # List available Pythons
uv python install 3.12        # Install Python version
uv python pin 3.12            # Pin Python version for project
```

---

## Ruff Commands Reference

```bash
ruff check .                  # Lint code
ruff check --fix .            # Lint and auto-fix
ruff check --watch .          # Watch mode
ruff format .                 # Format code
ruff format --check .         # Check formatting
ruff rule E501                # Explain a rule
```

---

