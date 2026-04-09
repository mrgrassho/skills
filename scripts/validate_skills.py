#!/usr/bin/env python3

from __future__ import annotations

import filecmp
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = ROOT / "skills"
EXPORT_TARGETS = {
    "claude": ROOT / "dist" / "claude" / ".claude" / "skills",
    "opencode": ROOT / "dist" / "opencode" / ".opencode" / "skills",
}
FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)
LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
CLAUDE_RESERVED_WORDS = ("anthropic", "claude")


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

    name = metadata.get("name", "")
    if name and name != skill_dir.name:
        errors.append(
            f"{skill_dir.name}: folder name must match frontmatter name '{name}'"
        )
    if name and not NAME_RE.fullmatch(name):
        errors.append(
            f"{skill_dir.name}: name must match ^[a-z0-9]+(-[a-z0-9]+)*$"
        )
    if name and len(name) > 64:
        errors.append(f"{skill_dir.name}: name must be 64 characters or fewer")
    if name and any(word in name for word in CLAUDE_RESERVED_WORDS):
        errors.append(
            f"{skill_dir.name}: name must not contain reserved Claude words"
        )

    description = metadata.get("description", "")
    if description and len(description) > 1024:
        errors.append(f"{skill_dir.name}: description must be 1024 characters or fewer")

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


def compare_trees(source_dir: Path, target_dir: Path, label: str) -> list[str]:
    errors: list[str] = []
    if not target_dir.is_dir():
        return [f"{label}: missing export directory '{target_dir.relative_to(ROOT)}'"]

    source_files = sorted(
        path.relative_to(source_dir)
        for path in source_dir.rglob("*")
        if path.is_file()
    )
    target_files = sorted(
        path.relative_to(target_dir)
        for path in target_dir.rglob("*")
        if path.is_file()
    )

    if source_files != target_files:
        missing = sorted(set(source_files) - set(target_files))
        extra = sorted(set(target_files) - set(source_files))
        if missing:
            errors.append(
                f"{label}: missing exported files for {source_dir.name}: "
                + ", ".join(str(path) for path in missing)
            )
        if extra:
            errors.append(
                f"{label}: unexpected exported files for {source_dir.name}: "
                + ", ".join(str(path) for path in extra)
            )
        return errors

    _, mismatches, comparison_errors = filecmp.cmpfiles(
        source_dir,
        target_dir,
        [str(path) for path in source_files],
        shallow=False,
    )
    for path in mismatches:
        errors.append(f"{label}: exported file differs for {source_dir.name}: {path}")
    for path in comparison_errors:
        errors.append(f"{label}: could not compare exported file for {source_dir.name}: {path}")
    return errors


def validate_exports(skill_dirs: list[Path]) -> list[str]:
    errors: list[str] = []
    for label, export_root in EXPORT_TARGETS.items():
        exported_skill_names = sorted(
            path.name for path in export_root.iterdir()
        ) if export_root.is_dir() else []
        source_skill_names = sorted(path.name for path in skill_dirs)
        if exported_skill_names != source_skill_names:
            missing = sorted(set(source_skill_names) - set(exported_skill_names))
            extra = sorted(set(exported_skill_names) - set(source_skill_names))
            if missing:
                errors.append(
                    f"{label}: missing exported skill directories: {', '.join(missing)}"
                )
            if extra:
                errors.append(
                    f"{label}: unexpected exported skill directories: {', '.join(extra)}"
                )

        for skill_dir in skill_dirs:
            errors.extend(
                compare_trees(skill_dir, export_root / skill_dir.name, label)
            )
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
    errors.extend(validate_exports(skill_dirs))

    if errors:
        print("Skill validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"Validated {len(skill_dirs)} published skills.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
