.PHONY: help install merge merge-dry sync-to test verify clean

SUBMODULE_PATH ?= $(shell basename $(CURDIR))
REPO_NAME := claude-skills-go

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Install into parent repo (run from parent repo root)
	uv run $(SUBMODULE_PATH)/scripts/merge-settings.py

merge: ## Merge settings into parent repo's .claude/settings.json
	uv run scripts/merge-settings.py

merge-dry: ## Preview merge without writing
	uv run scripts/merge-settings.py --dry-run

sync-to: ## Sync skills to TARGET directory (e.g., make sync-to TARGET=/path/to/project)
	@if [ -z "$(TARGET)" ]; then \
		echo "Error: TARGET not specified"; \
		echo "Usage: make sync-to TARGET=/path/to/project"; \
		echo ""; \
		echo "Examples:"; \
		echo "  make sync-to TARGET=/Users/$$USER/projects/myproject"; \
		echo "  make sync-to TARGET=\$$HOME/projects/myproject"; \
		echo "  make sync-to TARGET=../taskcore"; \
		exit 1; \
	fi
	$(eval TARGET_EXPANDED := $(shell echo $(TARGET)))
	@if [ ! -d "$(TARGET_EXPANDED)" ]; then \
		echo "Error: TARGET directory does not exist: $(TARGET_EXPANDED)"; \
		echo ""; \
		echo "Please provide a valid directory path."; \
		echo "The directory must exist before syncing."; \
		exit 1; \
	fi
	@if [ "$(TARGET_EXPANDED)" = "/" ]; then \
		echo "Error: Cannot sync to system root"; \
		echo ""; \
		echo "Please specify a valid directory with write permissions."; \
		exit 1; \
	fi
	@if [ ! -d "$(TARGET_EXPANDED)/.claude" ]; then \
		echo "Error: .claude/ directory does not exist in $(TARGET_EXPANDED)"; \
		echo ""; \
		echo "Please run Claude Code at least once in this directory to initialize .claude/"; \
		echo ""; \
		echo "Steps:"; \
		echo "  1. cd $(TARGET_EXPANDED)"; \
		echo "  2. Run 'claude' or open the directory in your IDE with Claude Code"; \
		echo "  3. Let Claude initialize the .claude/ directory"; \
		echo "  4. Then run: make sync-to TARGET=$(TARGET)"; \
		exit 1; \
	fi
	@echo "Syncing skills to $(TARGET_EXPANDED)/.claude/"
	@mkdir -p "$(TARGET_EXPANDED)/.claude/hooks/$(REPO_NAME)"
	@mkdir -p "$(TARGET_EXPANDED)/.claude/scripts/$(REPO_NAME)"
	@mkdir -p "$(TARGET_EXPANDED)/.claude/skills/$(REPO_NAME)"
	@echo "Copying hooks..."
	@cp -r hooks/* "$(TARGET_EXPANDED)/.claude/hooks/$(REPO_NAME)/"
	@echo "Copying scripts..."
	@cp -r scripts/* "$(TARGET_EXPANDED)/.claude/scripts/$(REPO_NAME)/"
	@echo "Copying skills..."
	@cp -r skills/* "$(TARGET_EXPANDED)/.claude/skills/$(REPO_NAME)/"
	@echo "Copying metadata..."
	@cp settings.template.json "$(TARGET_EXPANDED)/.claude/skills/$(REPO_NAME)/"
	@cp Makefile "$(TARGET_EXPANDED)/.claude/skills/$(REPO_NAME)/"
	@git describe --tags --abbrev=0 2>/dev/null > "$(TARGET_EXPANDED)/.claude/claude-skills-go-version" || echo "dev" > "$(TARGET_EXPANDED)/.claude/claude-skills-go-version"
	@echo "Merging settings..."
	@cd "$(TARGET_EXPANDED)" && uv run ".claude/scripts/$(REPO_NAME)/merge-settings.py"
	@echo ""
	@echo "✓ Successfully synced to $(TARGET_EXPANDED)/.claude/"
	@echo "  Version: $$(cat $(TARGET_EXPANDED)/.claude/claude-skills-go-version)"

test: ## Run resolver tests
	@echo "Testing resolver with test file..."
	@uv run skills/resolve.py src/test_example.py
	@echo ""
	@echo "Testing resolver with API handler..."
	@uv run skills/resolve.py src/api/handler.py
	@echo ""
	@echo "Testing resolver with Go file..."
	@uv run skills/resolve.py pkg/server/main.go

verify: ## Verify all scripts work correctly
	@echo "=== Checking scripts are executable ==="
	@ls -la hooks/*.sh skills/resolve.py
	@echo ""
	@echo "=== Testing inject-style.sh ==="
	@hooks/inject-style.sh src/main.py
	@echo ""
	@echo "=== Testing ruff availability ==="
	@uvx ruff --version
	@echo ""
	@echo "=== All checks passed ==="

clean: ## Remove generated files
	@find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@echo "Cleaned"
