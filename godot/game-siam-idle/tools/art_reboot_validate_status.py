#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path


WORKSPACE = Path(__file__).resolve().parents[3]
DEFAULT_RUN_DIR = WORKSPACE / "run" / "art-reboot-2026-07-01"
HERO_ID = "S01_GARUDA_VAYUDEJ"


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def active_visual_assets(active_assets: list[str]) -> dict[str, list[str]]:
    return {
        "vfx": [path for path in active_assets if path.startswith("res://assets/vfx/")],
        "ui": [path for path in active_assets if path.startswith("res://assets/ui/generated/")],
        "background": [path for path in active_assets if path == "res://assets/ui/battlefield_siam_temple.png"],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate art reboot status evidence after visual identity review.")
    parser.add_argument("--run-dir", type=Path, default=DEFAULT_RUN_DIR)
    args = parser.parse_args()

    run_dir = args.run_dir.resolve()
    manifest = load_json(run_dir / "art_reboot_v200_manifest.json")
    pilot_manifest = load_json(run_dir / "pilot" / HERO_ID / "run-manifest.json")
    visual_review = load_json(run_dir / "pilot" / HERO_ID / "64" / "qa" / "visual-review.json")
    asset_audit = load_json(run_dir / "asset_audit_v200_baseline.json")
    asset_candidates = load_json(run_dir / "asset_candidates_v200.json")
    character_audit = load_json(run_dir / "character_asset_contract_audit_v200.json")

    errors: list[str] = []

    if "IDENTITY_DRIFT" not in str(manifest.get("status", "")):
        errors.append("top manifest status must record identity drift")
    if "IDENTITY_DRIFT" not in str(pilot_manifest.get("status", "")):
        errors.append("pilot manifest status must record identity drift")
    if manifest.get("pilot", {}).get("accepted_rows"):
        errors.append("top manifest must have zero accepted rows while identity gate is blocked")
    if visual_review.get("accepted") is not False:
        errors.append("visual review must reject the current S01 candidate")
    if visual_review.get("checks", {}).get("reference_identity") != "fail":
        errors.append("visual review must mark reference_identity as fail")
    if pilot_manifest.get("visual_review", {}).get("accepted") is not False:
        errors.append("pilot manifest visual_review.accepted must be false")

    accepted_candidates = [
        candidate.get("id", "<unknown>")
        for candidate in pilot_manifest.get("candidates", [])
        if "accepted" in str(candidate.get("status", "")).lower()
    ]
    if accepted_candidates:
        errors.append(f"pilot manifest still has accepted candidates: {accepted_candidates}")

    runtime_changes = manifest.get("runtime_changes", {})
    changed = [key for key, value in runtime_changes.items() if isinstance(value, bool) and value]
    if changed:
        errors.append(f"runtime changes are marked true before pilot gate: {changed}")

    if asset_audit.get("missing_import"):
        errors.append(f"missing imports: {asset_audit['missing_import']}")
    if asset_audit.get("missing_active_asset_files"):
        errors.append(f"missing active asset files: {asset_audit['missing_active_asset_files']}")
    if not character_audit.get("ok"):
        errors.append(f"character contract audit failed: {character_audit.get('errors', [])}")

    visuals = active_visual_assets(asset_audit.get("active_assets", []))
    asset_candidate_counts: dict[str, dict] = {}
    for lane, paths in visuals.items():
        entries = asset_candidates.get("lanes", {}).get(lane, [])
        by_active = {entry.get("active_path", ""): entry for entry in entries}
        missing = sorted(set(paths) - set(by_active))
        stale = sorted(set(by_active) - set(paths))
        if missing:
            errors.append(f"{lane} asset candidate manifest missing {len(missing)} active entries")
        if stale:
            errors.append(f"{lane} asset candidate manifest has {len(stale)} stale entries")
        asset_candidate_counts[lane] = {
            "required": len(paths),
            "entries": len(entries),
            "accepted": sum(1 for entry in entries if entry.get("accepted") is True),
        }

    report = {
        "ok": not errors,
        "run_dir": str(run_dir),
        "status": manifest.get("status"),
        "pilot_status": pilot_manifest.get("status"),
        "accepted_rows": len(manifest.get("pilot", {}).get("accepted_rows", [])),
        "visual_review_accepted": visual_review.get("accepted"),
        "reference_identity": visual_review.get("checks", {}).get("reference_identity"),
        "active_asset_count": asset_audit.get("active_asset_count"),
        "character_hero_count": character_audit.get("hero_count"),
        "character_errors": len(character_audit.get("errors", [])),
        "missing_import_count": len(asset_audit.get("missing_import", [])),
        "missing_active_asset_count": len(asset_audit.get("missing_active_asset_files", [])),
        "vfx_duplicate_groups": len(asset_audit.get("vfx_duplicated_version_groups", {})),
        "asset_candidate_counts": asset_candidate_counts,
        "errors": errors,
    }
    print(json.dumps(report, indent=2))
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
