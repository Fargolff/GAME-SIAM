#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path


WORKSPACE = Path(__file__).resolve().parents[3]
PROJECT = WORKSPACE / "godot" / "game-siam-idle"
DEFAULT_RUN_DIR = WORKSPACE / "run" / "art-reboot-2026-07-01"
ROSTER_SUMMARY = WORKSPACE / "run" / "roster-qc-2026-07-01" / "roster_qc_summary_2026-07-01.json"
REQUIRED_REVIEW_CHECKS = (
    "reference_identity",
    "direction",
    "animation_readable",
    "frame_separation",
    "sheet_geometry",
    "motion_audit",
    "not_procedural",
)
ASSET_REVIEW_CHECKS = ("same_size", "style_lock", "readability", "alpha_edges", "not_legacy", "runtime_evidence")


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def debt_tags(verdict: str) -> list[str]:
    text = verdict.lower()
    tags: list[str] = []
    if "walk" in text or "glide" in text:
        tags.append("walk")
    if "vfx" in text or "icon" in text or "impact" in text or "projectile" in text:
        tags.append("vfx_contact")
    if "identity" in text:
        tags.append("identity")
    if "silhouette" in text or "dense" in text or "oversize" in text or "large" in text:
        tags.append("silhouette")
    if "runtime" in text or "capture" in text or "evidence" in text:
        tags.append("runtime_evidence")
    return tags or ["visual_polish"]


def active_visual_assets(active_assets: list[str]) -> dict[str, list[str]]:
    return {
        "vfx": [path for path in active_assets if path.startswith("res://assets/vfx/")],
        "ui": [path for path in active_assets if path.startswith("res://assets/ui/generated/")],
        "background": [path for path in active_assets if path == "res://assets/ui/battlefield_siam_temple.png"],
    }


def resolve_evidence_path(path_text: str, run_dir: Path) -> Path:
    path = Path(path_text)
    return path if path.is_absolute() else (run_dir / path).resolve()


def resolve_asset_evidence_path(path_text: str, run_dir: Path) -> Path:
    if path_text.startswith("res://"):
        return (PROJECT / path_text.removeprefix("res://")).resolve()
    return resolve_evidence_path(path_text, run_dir)


def candidate_review_gate(run_dir: Path) -> dict:
    summaries: list[dict] = []
    errors: list[str] = []
    pilot_dir = run_dir / "pilot"
    if not pilot_dir.exists():
        return {"summaries": summaries, "errors": ["pilot directory is missing"]}

    for manifest_path in sorted(pilot_dir.glob("*/run-manifest.json")):
        manifest = load_json(manifest_path)
        hero_id = manifest.get("hero_id") or manifest_path.parent.name
        review_path_text = str(manifest.get("visual_review", {}).get("path") or "")
        if not review_path_text:
            errors.append(f"{hero_id}: visual review path missing")
            continue
        review_path = resolve_evidence_path(review_path_text, run_dir)
        if not review_path.exists():
            errors.append(f"{hero_id}: visual review file missing: {review_path}")
            continue

        review = load_json(review_path)
        checks = review.get("checks", {})
        failing_checks = [name for name in REQUIRED_REVIEW_CHECKS if checks.get(name) != "pass"]
        accepted = review.get("accepted") is True
        accepted_candidates = [
            candidate.get("id", "<unknown>")
            for candidate in manifest.get("candidates", [])
            if "accepted" in str(candidate.get("status", "")).lower()
        ]
        accepted_rows = manifest.get("accepted_rows", [])

        if accepted_candidates or accepted_rows:
            if not accepted:
                errors.append(f"{hero_id}: accepted candidate/row without accepted visual review")
            if failing_checks:
                errors.append(f"{hero_id}: accepted candidate/row has failing visual checks: {failing_checks}")

        summaries.append(
            {
                "hero_id": hero_id,
                "visual_review": str(review_path),
                "accepted": accepted,
                "verdict": review.get("verdict", ""),
                "failing_checks": failing_checks,
                "accepted_candidates": accepted_candidates,
                "accepted_rows": accepted_rows,
            }
        )

    return {"summaries": summaries, "errors": errors}


def asset_candidate_gate(run_dir: Path, visuals: dict[str, list[str]]) -> dict:
    manifest_path = run_dir / "asset_candidates_v200.json"
    empty_counts = {lane: {"required": len(paths), "accepted": 0, "raw_accepted": 0} for lane, paths in visuals.items()}
    if not manifest_path.exists():
        return {
            "path": str(manifest_path),
            "counts": empty_counts,
            "summaries": [],
            "errors": ["asset candidate manifest is missing"],
        }

    manifest = load_json(manifest_path)
    errors: list[str] = []
    summaries: list[dict] = []
    counts: dict[str, dict] = {}

    for lane, active_paths in visuals.items():
        entries = manifest.get("lanes", {}).get(lane, [])
        by_active = {entry.get("active_path", ""): entry for entry in entries}
        missing = sorted(set(active_paths) - set(by_active))
        stale = sorted(set(by_active) - set(active_paths))
        if missing:
            errors.append(f"{lane}: missing candidate entries for {len(missing)} active assets")
        if stale:
            errors.append(f"{lane}: stale candidate entries for {len(stale)} inactive assets")

        accepted = 0
        raw_accepted = 0
        for active_path in active_paths:
            entry = by_active.get(active_path, {})
            checks = entry.get("checks", {})
            failing_checks = [name for name in ASSET_REVIEW_CHECKS if checks.get(name) != "pass"]
            is_accepted = entry.get("accepted") is True
            entry_errors: list[str] = []
            if is_accepted:
                raw_accepted += 1
                for field in ("candidate_path", "review_path", "runtime_evidence"):
                    value = str(entry.get(field) or "")
                    if not value:
                        entry_errors.append(f"{lane}: {active_path} accepted without {field}")
                    elif not resolve_asset_evidence_path(value, run_dir).exists():
                        entry_errors.append(f"{lane}: {active_path} {field} missing: {value}")
                if failing_checks:
                    entry_errors.append(f"{lane}: {active_path} accepted with failing checks: {failing_checks}")
                if "_v200" not in str(entry.get("candidate_path", "")):
                    entry_errors.append(f"{lane}: {active_path} accepted candidate is not _v200")
                if entry_errors:
                    errors.extend(entry_errors)
                else:
                    accepted += 1
            summaries.append(
                {
                    "lane": lane,
                    "active_path": active_path,
                    "accepted": is_accepted and not entry_errors,
                    "raw_accepted": is_accepted,
                    "candidate_path": entry.get("candidate_path", ""),
                    "failing_checks": failing_checks,
                }
            )
        counts[lane] = {"required": len(active_paths), "accepted": accepted, "raw_accepted": raw_accepted}

    return {"path": str(manifest_path), "counts": counts, "summaries": summaries, "errors": errors}


def write_markdown(path: Path, report: dict) -> None:
    character_rows = report["character_blockers"]
    lines = [
        "# GAME SIAM IDLE Visual 100 Gate",
        "",
        f"Status: `{report['status']}`",
        f"Blockers: {len(report['blockers'])}",
        "",
        "## Snapshot",
        "",
        f"- Character blockers: {len(character_rows)}/40",
        f"- Active visual assets: {report['active_visual_asset_count']}",
        f"- Missing imports: {report['missing_import_count']}",
        f"- Missing active files: {report['missing_active_asset_count']}",
        f"- Accepted art reboot rows: {report['accepted_art_reboot_rows']}",
        f"- Raw manifest accepted rows: {report['raw_art_reboot_accepted_rows']}",
        f"- Accepted VFX candidates: {report['asset_candidate_counts']['vfx']['accepted']}/{report['asset_candidate_counts']['vfx']['required']}",
        f"- Accepted UI candidates: {report['asset_candidate_counts']['ui']['accepted']}/{report['asset_candidate_counts']['ui']['required']}",
        f"- Accepted background candidates: {report['asset_candidate_counts']['background']['accepted']}/{report['asset_candidate_counts']['background']['required']}",
        "",
        "## Lowest Character Blockers",
        "",
        "| Hero | Score | Tags | Verdict |",
        "|---|---:|---|---|",
    ]
    for row in character_rows[:15]:
        lines.append(
            f"| {row['hero_id']} | {row['score']} | {', '.join(row['tags'])} | {row['verdict']} |"
        )
    lines.extend(
        [
            "",
            "## Required Lanes",
            "",
            "- Character lane: every hero must reach literal 100/100 with identity-locked visual review and runtime proof.",
            "- VFX lane: active personal/shared VFX need accepted `_v200` candidates before mappings change.",
            "- UI/background lane: active battle UI textures and battlefield background need same-size accepted replacements.",
            "- Runtime QA lane: final battle ready/running/victory screenshots and all-40 skill showcase proof are required.",
            "",
            "## Candidate Review Gate",
            "",
        ]
    )
    for row in report["candidate_reviews"]:
        status = "accepted" if row["accepted"] else "rejected"
        failing = ", ".join(row["failing_checks"]) if row["failing_checks"] else "-"
        lines.append(f"- `{row['hero_id']}` visual review is {status}; failing checks: {failing}")
    lines.extend(["", "## Asset Candidate Gate", ""])
    for lane, counts in report["asset_candidate_counts"].items():
        lines.append(f"- `{lane}` accepted candidates: {counts['accepted']}/{counts['required']}")
    if report["asset_candidate_errors"]:
        lines.append("")
        lines.append("Asset candidate errors:")
        for error in report["asset_candidate_errors"]:
            lines.append(f"- {error}")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Strict visual 100/100 gate for GAME SIAM IDLE art reboot.")
    parser.add_argument("--run-dir", type=Path, default=DEFAULT_RUN_DIR)
    args = parser.parse_args()

    run_dir = args.run_dir.resolve()
    art_manifest = load_json(run_dir / "art_reboot_v200_manifest.json")
    asset_audit = load_json(run_dir / "asset_audit_v200_baseline.json")
    character_audit = load_json(run_dir / "character_asset_contract_audit_v200.json")
    roster = load_json(ROSTER_SUMMARY)

    blockers: list[str] = []
    candidate_gate = candidate_review_gate(run_dir)
    validated_accepted_rows = [
        row
        for review in candidate_gate["summaries"]
        if review["accepted"] and not review["failing_checks"]
        for row in review["accepted_rows"]
    ]

    if art_manifest.get("status") != "VISUAL_100_PASS":
        blockers.append("art reboot manifest is not VISUAL_100_PASS")
    raw_accepted_rows = art_manifest.get("pilot", {}).get("accepted_rows", [])
    if not validated_accepted_rows:
        blockers.append("art reboot has zero accepted replacement rows")
    if not character_audit.get("ok"):
        blockers.append("character contract audit has errors")
    if asset_audit.get("missing_import"):
        blockers.append("active assets have missing .import files")
    if asset_audit.get("missing_active_asset_files"):
        blockers.append("active assets reference missing files")

    character_blockers: list[dict] = []
    for row in roster.get("rows", []):
        score = int(row.get("score", 0))
        if score < 100:
            character_blockers.append(
                {
                    "hero_id": row.get("hero_id", ""),
                    "score": score,
                    "subagent_score": row.get("subagent_score"),
                    "tags": debt_tags(str(row.get("verdict", ""))),
                    "verdict": row.get("verdict", ""),
                    "manifest_path": row.get("manifest_path", ""),
                }
            )
    character_blockers.sort(key=lambda row: (row["score"], row["hero_id"]))
    if character_blockers:
        blockers.append(f"{len(character_blockers)} character rows are below literal 100/100")

    hard_limitations = roster.get("hard_limitations", [])
    if hard_limitations:
        blockers.append("roster summary still records hard visual evidence limitations")

    visuals = active_visual_assets(asset_audit.get("active_assets", []))
    asset_gate = asset_candidate_gate(run_dir, visuals)
    old_active_vfx = [path for path in visuals["vfx"] if "_v200" not in path]
    if old_active_vfx:
        blockers.append(f"{len(old_active_vfx)} active VFX assets are not accepted _v200 replacements")
    if asset_gate["counts"]["vfx"]["accepted"] < asset_gate["counts"]["vfx"]["required"]:
        blockers.append("active VFX assets lack accepted _v200 candidate evidence")
    if visuals["ui"] or visuals["background"]:
        blockers.append("active UI/background replacements do not have accepted v200 evidence")
    if (
        asset_gate["counts"]["ui"]["accepted"] < asset_gate["counts"]["ui"]["required"]
        or asset_gate["counts"]["background"]["accepted"] < asset_gate["counts"]["background"]["required"]
    ):
        blockers.append("active UI/background assets lack accepted candidate evidence")

    if candidate_gate["errors"]:
        blockers.append("candidate visual review gate has errors")
    if asset_gate["errors"]:
        blockers.append("asset candidate gate has errors")

    report = {
        "ok": not blockers,
        "status": "VISUAL_100_PASS" if not blockers else "VISUAL_100_BLOCKED",
        "run_dir": str(run_dir),
        "blockers": blockers,
        "hard_limitations": hard_limitations,
        "character_blockers": character_blockers,
        "active_visual_assets": visuals,
        "active_visual_asset_count": sum(len(items) for items in visuals.values()),
        "old_active_vfx_count": len(old_active_vfx),
        "candidate_reviews": candidate_gate["summaries"],
        "candidate_review_errors": candidate_gate["errors"],
        "asset_candidate_manifest": asset_gate["path"],
        "asset_candidate_counts": asset_gate["counts"],
        "asset_candidate_summaries": asset_gate["summaries"],
        "asset_candidate_errors": asset_gate["errors"],
        "missing_import_count": len(asset_audit.get("missing_import", [])),
        "missing_active_asset_count": len(asset_audit.get("missing_active_asset_files", [])),
        "accepted_art_reboot_rows": len(validated_accepted_rows),
        "raw_art_reboot_accepted_rows": len(raw_accepted_rows),
        "validated_accepted_rows": validated_accepted_rows,
        "workstreams": {
            "characters": "Generate or repair only rows with identity-locked evidence until every hero is 100/100.",
            "vfx": "Create inactive _v200 candidates for all active personal/shared VFX before mapping changes.",
            "ui_background": "Create same-size inactive replacements for active battle UI textures and background.",
            "runtime_qa": "Capture battle ready/running/victory and all-40 skill showcase evidence before final pass.",
        },
    }

    json_path = run_dir / "visual_100_gate_report.json"
    md_path = run_dir / "visual_100_gate_report.md"
    json_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
    write_markdown(md_path, report)

    print(
        json.dumps(
            {
                "ok": report["ok"],
                "status": report["status"],
                "blockers": len(blockers),
                "character_blockers": len(character_blockers),
                "active_visual_asset_count": report["active_visual_asset_count"],
                "report": str(json_path),
            },
            indent=2,
        )
    )
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
