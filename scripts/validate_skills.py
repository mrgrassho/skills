#!/usr/bin/env python3

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = ROOT / "skills"
FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)
LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")


def parse_frontmatter(text: str) -> dict[str, str] | None:
    match = FRONTMATTER_RE.match(text)
    if not match:
        return None

    metadata: dict[str, str] = {}
    for raw_line in match.group(1).splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or ":" not in line:
            continue
        key, value = line.split(":", 1)
        metadata[key.strip()] = value.strip().strip("\"'")
    return metadata


def validate_skill(skill_dir: Path) -> list[str]:
    errors: list[str] = []
    skill_file = skill_dir / "SKILL.md"

    if not skill_file.is_file():
        return [f"{skill_dir.name}: missing SKILL.md"]

    text = skill_file.read_text(encoding="utf-8")
    metadata = parse_frontmatter(text)
    if metadata is None:
        errors.append(f"{skill_dir.name}: missing or invalid YAML frontmatter")
        return errors

    for field in ("name", "description"):
        if not metadata.get(field):
            errors.append(f"{skill_dir.name}: missing frontmatter field '{field}'")

    if metadata.get("name") and metadata["name"] != skill_dir.name:
        errors.append(
            f"{skill_dir.name}: folder name must match frontmatter name '{metadata['name']}'"
        )

    supporting_files = [
        path
        for path in skill_dir.rglob("*")
        if path.is_file() and path.name != "SKILL.md"
    ]
    if not supporting_files:
        errors.append(
            f"{skill_dir.name}: needs at least one supporting artifact outside SKILL.md"
        )

    for target in LINK_RE.findall(text):
        if target.startswith(("http://", "https://", "#", "mailto:")):
            continue
        linked_path = (skill_dir / target).resolve()
        if not linked_path.exists():
            errors.append(f"{skill_dir.name}: missing linked file '{target}'")

    return errors


def main() -> int:
    if not SKILLS_DIR.is_dir():
        print("skills/ directory not found", file=sys.stderr)
        return 1

    skill_dirs = sorted(path for path in SKILLS_DIR.iterdir() if path.is_dir())
    if not skill_dirs:
        print("No published skills found.", file=sys.stderr)
        return 1

    errors: list[str] = []
    for skill_dir in skill_dirs:
        errors.extend(validate_skill(skill_dir))

    if errors:
        print("Skill validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"Validated {len(skill_dirs)} published skills.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
