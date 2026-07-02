#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from datetime import date
from pathlib import Path


WORKSPACE = Path(__file__).resolve().parents[3]
DEFAULT_RUN_DIR = WORKSPACE / "run" / "art-reboot-2026-07-01"


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def active_visual_assets(active_assets: list[str]) -> dict[str, list[str]]:
    return {
        "vfx": [path for path in active_assets if path.startswith("res://assets/vfx/")],
        "ui": [path for path in active_assets if path.startswith("res://assets/ui/generated/")],
        "background": [path for path in active_assets if path == "res://assets/ui/battlefield_siam_temple.png"],
    }


def default_entry(lane: str, active_path: str) -> dict:
    return {
        "lane": lane,
        "active_path": active_path,
        "candidate_path": "",
        "review_path": "",
        "runtime_evidence": "",
        "accepted": False,
        "checks": {},
        "notes": "pending inactive _v200 candidate; runtime mapping must stay unchanged until the full visual gate passes",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Sync inactive v200 asset candidate manifest from active visual assets.")
    parser.add_argument("--run-dir", type=Path, default=DEFAULT_RUN_DIR)
    args = parser.parse_args()

    run_dir = args.run_dir.resolve()
    audit_path = run_dir / "asset_audit_v200_baseline.json"
    manifest_path = run_dir / "asset_candidates_v200.json"
    audit = load_json(audit_path)
    visuals = active_visual_assets(audit.get("active_assets", []))

    existing: dict[str, dict] = {}
    if manifest_path.exists():
        current = load_json(manifest_path)
        for entries in current.get("lanes", {}).values():
            for entry in entries:
                existing[entry.get("active_path", "")] = entry

    lanes = {}
    for lane, paths in visuals.items():
        entries = []
        for active_path in paths:
            entry = dict(existing.get(active_path, default_entry(lane, active_path)))
            entry["lane"] = lane
            entry["active_path"] = active_path
            entries.append(entry)
        lanes[lane] = entries

    counts = {
        lane: {
            "required": len(entries),
            "accepted": sum(1 for entry in entries if entry.get("accepted") is True),
            "raw_accepted": sum(1 for entry in entries if entry.get("accepted") is True),
        }
        for lane, entries in lanes.items()
    }
    manifest = {
        "date": date.today().isoformat(),
        "status": "PENDING_INACTIVE_V200_CANDIDATES",
        "source_asset_audit": str(audit_path),
        "runtime_replacement": False,
        "lanes": lanes,
        "counts": counts,
    }
    manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print(json.dumps({"path": str(manifest_path), "counts": counts}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
