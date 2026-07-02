#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from collections import defaultdict
from pathlib import Path


PROJECT = Path(__file__).resolve().parents[1]
ASSETS = PROJECT / "assets"
BATTLE = PROJECT / "scripts" / "battle" / "battle.gd"
BATTLE_SCENE = PROJECT / "scenes" / "battle" / "Battle.tscn"


def active_asset_paths() -> list[str]:
    text = "\n".join(path.read_text(encoding="utf-8") for path in (BATTLE, BATTLE_SCENE))
    paths = set(re.findall(r"res://assets/[^\"\)\s]+", text))
    return sorted(paths)


def version_groups(folder: Path) -> dict[str, list[str]]:
    groups: dict[str, list[str]] = defaultdict(list)
    for path in sorted(folder.glob("*.png")):
        base = re.sub(r"_v\d+(?=\.png$)", "", path.name)
        groups[base].append(path.name)
    return {base: names for base, names in groups.items() if len(names) > 1}


def main() -> int:
    active = active_asset_paths()
    active_files = {path.removeprefix("res://assets/") for path in active}
    media = [
        path
        for path in ASSETS.rglob("*")
        if path.is_file() and path.suffix.lower() in {".png", ".wav", ".ogg", ".mp3", ".ttf", ".otf"}
    ]
    missing_import = [
        str(path.relative_to(ASSETS)).replace("\\", "/")
        for path in media
        if path.suffix.lower() in {".png", ".wav", ".ogg", ".mp3", ".ttf", ".otf"} and not Path(str(path) + ".import").exists()
    ]
    orphan_active = [path for path in active_files if not (ASSETS / path).exists()]
    report = {
        "active_asset_count": len(active),
        "active_assets": active,
        "missing_import": missing_import,
        "missing_active_asset_files": orphan_active,
        "vfx_duplicated_version_groups": version_groups(ASSETS / "vfx" / "generated"),
        "ui_duplicated_version_groups": version_groups(ASSETS / "ui" / "generated"),
    }
    print(json.dumps(report, indent=2))
    return 1 if missing_import or orphan_active else 0


if __name__ == "__main__":
    raise SystemExit(main())
