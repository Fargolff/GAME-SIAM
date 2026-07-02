#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

from PIL import Image


PROJECT = Path(__file__).resolve().parents[1]
WORKSPACE = Path(__file__).resolve().parents[3]
HERO_CATALOG = PROJECT / "scripts" / "content" / "hero_catalog.gd"
CHARACTER_ASSETS = PROJECT / "assets" / "characters" / "GameSiam"
SPRITEFRAMES = PROJECT / "generated" / "spriteframes"
DEFAULT_OUTPUT = WORKSPACE / "run" / "art-reboot-2026-07-01" / "character_asset_contract_audit_v200.json"
ACTIONS = ["idle", "walk", "attack_01", "skill_01", "hurt", "death"]
EXPECTED_SIZE = (384, 512)


def hero_ids() -> list[str]:
    text = HERO_CATALOG.read_text(encoding="utf-8")
    match = re.search(r"const HERO_IDS := \[(.*?)\]", text, re.S)
    if not match:
        raise SystemExit("Could not find HERO_IDS in hero_catalog.gd")
    return re.findall(r'"([^"]+)"', match.group(1))


def inspect_sheet(path: Path) -> dict:
    if not path.exists():
        return {"exists": False, "size": None, "ok": False}
    with Image.open(path) as image:
        size = image.size
    return {"exists": True, "size": list(size), "ok": size == EXPECTED_SIZE}


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit active GameSiam character asset contract.")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()

    heroes = hero_ids()
    errors: list[str] = []
    hero_reports: list[dict] = []

    for hero_id in heroes:
        hero_dir = CHARACTER_ASSETS / hero_id
        hero_errors: list[str] = []
        action_reports: dict[str, dict] = {}

        if not hero_dir.exists():
            hero_errors.append("missing hero asset directory")

        for action in ACTIONS:
            sheet = hero_dir / f"{action}-sheet-clean.png"
            metadata = hero_dir / f"{action}-metadata.json"
            sheet_import = Path(str(sheet) + ".import")
            sheet_report = inspect_sheet(sheet)
            if not sheet_report["exists"]:
                hero_errors.append(f"missing {sheet.name}")
            elif not sheet_report["ok"]:
                hero_errors.append(f"{sheet.name} size {sheet_report['size']} != {list(EXPECTED_SIZE)}")
            if not metadata.exists():
                hero_errors.append(f"missing {metadata.name}")
            if not sheet_import.exists():
                hero_errors.append(f"missing {sheet.name}.import")
            action_reports[action] = {
                "sheet": str(sheet),
                "sheet_exists": sheet_report["exists"],
                "sheet_size": sheet_report["size"],
                "metadata_exists": metadata.exists(),
                "import_exists": sheet_import.exists(),
                "ok": sheet_report["ok"] and metadata.exists() and sheet_import.exists(),
            }

        spriteframes = SPRITEFRAMES / f"{hero_id}.tres"
        if not spriteframes.exists():
            hero_errors.append(f"missing generated spriteframes {spriteframes.name}")

        if hero_errors:
            errors.extend([f"{hero_id}: {error}" for error in hero_errors])
        hero_reports.append(
            {
                "hero_id": hero_id,
                "asset_dir": str(hero_dir),
                "spriteframes": str(spriteframes),
                "spriteframes_exists": spriteframes.exists(),
                "actions": action_reports,
                "errors": hero_errors,
                "ok": not hero_errors,
            }
        )

    extra_dirs = sorted(path.name for path in CHARACTER_ASSETS.iterdir() if path.is_dir() and path.name not in heroes)
    extra_spriteframes = sorted(
        path.stem for path in SPRITEFRAMES.glob("*.tres") if path.stem not in heroes
    )

    report = {
        "ok": not errors,
        "hero_count": len(heroes),
        "expected_action_count_per_hero": len(ACTIONS),
        "expected_sheet_size": list(EXPECTED_SIZE),
        "hero_asset_dirs": len([path for path in CHARACTER_ASSETS.iterdir() if path.is_dir()]),
        "generated_spriteframes_count": len(list(SPRITEFRAMES.glob("*.tres"))),
        "extra_hero_asset_dirs": extra_dirs,
        "extra_spriteframes": extra_spriteframes,
        "errors": errors,
        "heroes": hero_reports,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps({key: report[key] for key in report if key != "heroes"}, indent=2))
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
