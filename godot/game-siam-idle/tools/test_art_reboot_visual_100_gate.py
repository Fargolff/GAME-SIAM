#!/usr/bin/env python3
from __future__ import annotations

import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


WORKSPACE = Path(__file__).resolve().parents[3]
SOURCE_RUN_DIR = WORKSPACE / "run" / "art-reboot-2026-07-01"
GATE_TOOL = WORKSPACE / "godot" / "game-siam-idle" / "tools" / "art_reboot_visual_100_gate.py"


def main() -> int:
    with tempfile.TemporaryDirectory(prefix="visual-gate-asset-test-") as tmp:
        run_dir = Path(tmp) / "art-reboot-2026-07-01"
        shutil.copytree(SOURCE_RUN_DIR, run_dir)

        manifest_path = run_dir / "asset_candidates_v200.json"
        manifest = json.loads(manifest_path.read_text(encoding="utf-8-sig"))
        entry = manifest["lanes"]["vfx"][0]
        entry["accepted"] = True
        entry["candidate_path"] = "run/art-reboot-2026-07-01/vfx/generated/fake_v200.png"
        entry["review_path"] = "run/art-reboot-2026-07-01/vfx/reviews/fake.json"
        entry["runtime_evidence"] = "run/art-reboot-2026-07-01/vfx/runtime/fake.mp4"
        entry["checks"] = {
            "same_size": "pass",
            "style_lock": "pass",
            "readability": "pass",
            "alpha_edges": "fail",
            "not_legacy": "pass",
            "runtime_evidence": "pass",
        }
        manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")

        result = subprocess.run(
            [sys.executable, str(GATE_TOOL), "--run-dir", str(run_dir)],
            capture_output=True,
            text=True,
        )
        report = json.loads((run_dir / "visual_100_gate_report.json").read_text(encoding="utf-8"))
        counts = report["asset_candidate_counts"]["vfx"]
        errors = report["asset_candidate_errors"]

        assert result.returncode == 1, result.stdout + result.stderr
        assert counts["raw_accepted"] == 1, counts
        assert counts["accepted"] == 0, counts
        assert any("candidate_path missing" in error for error in errors), errors
        assert any("review_path missing" in error for error in errors), errors
        assert any("runtime_evidence missing" in error for error in errors), errors
        assert any("accepted with failing checks" in error for error in errors), errors

    print("PASS: invalid asset candidate does not count as accepted")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
