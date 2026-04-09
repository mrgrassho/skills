#!/usr/bin/env python3

from __future__ import annotations

import shutil
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
SOURCE_ROOT = ROOT / "skills"
TARGETS = {
    "claude": ROOT / "dist" / "claude" / ".claude" / "skills",
    "opencode": ROOT / "dist" / "opencode" / ".opencode" / "skills",
}


def reset_directory(path: Path) -> None:
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True, exist_ok=True)


def export_target(target_root: Path) -> None:
    reset_directory(target_root)
    for skill_dir in sorted(path for path in SOURCE_ROOT.iterdir() if path.is_dir()):
        shutil.copytree(skill_dir, target_root / skill_dir.name)


def main() -> int:
    if not SOURCE_ROOT.is_dir():
        raise SystemExit("skills/ directory not found")

    for target_root in TARGETS.values():
        export_target(target_root)

    print(
        "Exported "
        f"{len([path for path in SOURCE_ROOT.iterdir() if path.is_dir()])} skills "
        "to Claude and OpenCode targets."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
