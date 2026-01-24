#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Skill resolver: determines which skill files to inject based on file path and content.

Usage: uv run resolve.py <file_path>

Reads manifest.json and resolves matching skills based on:
1. File extension
2. Path glob matching
3. Content hints (regex on first 2000 chars if file exists)
"""

import json
import re
import sys
from fnmatch import fnmatch
from pathlib import Path
from typing import Any


def load_manifest(manifest_path: Path) -> dict:
    """Load and parse the manifest.json file."""
    if not manifest_path.exists():
        return {"always": [], "extensions": {}, "paths": {}, "content_hints": {}}

    with manifest_path.open() as f:
        data: dict[str, Any] = json.load(f)
        return data


def resolve_glob_patterns(skills_dir: Path, patterns: list[str]) -> list[Path]:
    """Resolve glob patterns to actual skill files."""
    resolved: list[Path] = []
    for pattern in patterns:
        # Handle both glob patterns and direct file references
        if "*" in pattern:
            resolved.extend(skills_dir.glob(pattern))
        else:
            skill_path = skills_dir / pattern
            if skill_path.exists():
                resolved.append(skill_path)
    return resolved


def get_file_content_sample(file_path: Path, max_chars: int = 2000) -> str:
    """Read first N characters of a file for content hint matching."""
    if not file_path.exists():
        return ""

    try:
        with file_path.open(errors="ignore") as f:
            return f.read(max_chars)
    except OSError:
        return ""


def resolve_skills(file_path: str) -> list[Path]:
    """
    Resolve all applicable skills for the given file path.

    Returns deduplicated list of skill file paths.
    """
    target = Path(file_path)
    skills_dir = Path(__file__).parent
    manifest = load_manifest(skills_dir / "manifest.json")

    matched_skills: set[Path] = set()

    # 1. Always-loaded skills
    for pattern in manifest.get("always", []):
        for skill_file in resolve_glob_patterns(skills_dir, [pattern]):
            if skill_file.suffix == ".md":
                matched_skills.add(skill_file)

    # 2. Extension-based skills
    ext = target.suffix.lower()
    if ext in manifest.get("extensions", {}):
        patterns = manifest["extensions"][ext]
        for skill_file in resolve_glob_patterns(skills_dir, patterns):
            if skill_file.suffix == ".md":
                matched_skills.add(skill_file)

    # 3. Path-based skills
    target_str = str(target)
    for glob_pattern, skill_patterns in manifest.get("paths", {}).items():
        if fnmatch(target_str, glob_pattern):
            for skill_file in resolve_glob_patterns(skills_dir, skill_patterns):
                if skill_file.suffix == ".md":
                    matched_skills.add(skill_file)

    # 4. Content hint skills (only if file exists)
    content = get_file_content_sample(target)
    if content:
        for regex_pattern, skill_patterns in manifest.get("content_hints", {}).items():
            try:
                if re.search(regex_pattern, content, re.IGNORECASE):
                    for skill_file in resolve_glob_patterns(skills_dir, skill_patterns):
                        if skill_file.suffix == ".md":
                            matched_skills.add(skill_file)
            except re.error:
                # Skip invalid regex patterns
                continue

    # Return sorted for consistent output
    return sorted(matched_skills)


def main() -> int:
    if len(sys.argv) < 2:
        print("Usage: resolve.py <file_path>", file=sys.stderr)
        return 1

    file_path = sys.argv[1]
    skills = resolve_skills(file_path)

    for skill in skills:
        print(skill)

    return 0


if __name__ == "__main__":
    sys.exit(main())
