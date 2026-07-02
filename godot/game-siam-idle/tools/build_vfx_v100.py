from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

import build_vfx_v80 as base
from PIL import Image


WORKSPACE = Path(r"C:\Users\ADMIN\Documents\GAME IDLE")
PROJECT = WORKSPACE / "godot" / "game-siam-idle"
ASSET_DIR = PROJECT / "assets" / "vfx" / "generated"
RUN_DIR = WORKSPACE / "run" / "vfx-v100"

EFFECTS = [
    {
        "hero_id": "A01_KINNARI_PIMPPRUEKSA",
        "key": "kinnari_lotus_feather_grace",
        "file": "skill_personal_kinnari_lotus_feather_grace_v100.png",
        "label": "Pimp lotus feather heal cradle",
        "max_size": 58,
        "frame_offsets": [(0, 6), (0, 3), (0, 0), (0, -1), (0, 1), (0, 4)],
        "frame_scales": [0.42, 0.64, 0.90, 1.0, 0.74, 0.50],
    },
    {
        "hero_id": "B05_KINNARA_RAVIKAN",
        "key": "ravikan_music_wave_slash",
        "file": "skill_personal_ravikan_music_wave_slash_v100.png",
        "label": "Ravikan broad song heal aura",
        "max_size": 58,
        "frame_offsets": [(-8, 2), (-4, 1), (0, 0), (3, 0), (6, 1), (8, 2)],
        "frame_scales": [0.42, 0.64, 0.90, 1.0, 0.74, 0.50],
    },
    {
        "hero_id": "C04_HUMAN_CHABA",
        "key": "chaba_hibiscus_petal_burst",
        "file": "skill_personal_chaba_hibiscus_petal_burst_v100.png",
        "label": "Chaba hibiscus healing bloom",
        "max_size": 58,
        "frame_offsets": [(0, 6), (0, 3), (0, 0), (0, -1), (0, 1), (0, 4)],
        "frame_scales": [0.42, 0.64, 0.90, 1.0, 0.74, 0.50],
    },
]


def build(source_path: Path) -> Path:
    RUN_DIR.mkdir(parents=True, exist_ok=True)
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    reference_copy = RUN_DIR / "imagegen_reference_v100a.png"
    shutil.copy2(source_path, reference_copy)

    source = Image.open(source_path).convert("RGBA")
    boxes = base.grid_boxes(source, 3, 1)
    if len(boxes) < len(EFFECTS):
        raise SystemExit(f"expected {len(EFFECTS)} grid cells, found {len(boxes)}")

    validation: list[dict[str, object]] = []
    entries: list[tuple[dict[str, object], Path]] = []
    manifest_entries: list[dict[str, object]] = []
    for spec, box in zip(EFFECTS, boxes[: len(EFFECTS)]):
        subject = base.crop_to_alpha(source, box)
        strip = base.compose_strip(subject, spec)
        out_path = ASSET_DIR / str(spec["file"])
        strip.save(out_path)
        run_copy = RUN_DIR / str(spec["file"])
        shutil.copy2(out_path, run_copy)
        result = base.validate_png(out_path)
        validation.append(result)
        entries.append((spec, run_copy))
        manifest_entries.append(
            {
                "hero_id": spec["hero_id"],
                "vfx_key": spec["key"],
                "asset": f"res://assets/vfx/generated/{spec['file']}",
                "source_reference": str(reference_copy),
                "source_crop_box": list(box),
                "generation": "Built-in imagegen concept reference; chroma-key extracted, pixel-snapped, quantized, and converted into native 64x64 6-frame strip by tools/build_vfx_v100.py without modifying character sprites.",
                "validation_pass": bool(result["pass"]),
            }
        )

    contact = RUN_DIR / "personal_vfx_v100a_contact.png"
    base.make_contact(entries, contact)
    (RUN_DIR / "personal_vfx_v100a_validation.json").write_text(
        json.dumps(validation, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    manifest = {
        "version": "v100a",
        "date": "2026-06-30",
        "source_imagegen_path": str(source_path),
        "reference_copy": str(reference_copy),
        "scope": "V100 replacements for three support/heal effects that read as projectile/song dot trail/damage burst in V98 QC. Character sprites are not modified.",
        "chroma_key": "#ff00ff",
        "cell": base.CELL,
        "frames": base.FRAMES,
        "source_layout": {"columns": 3, "rows": 1},
        "effects": manifest_entries,
    }
    (RUN_DIR / "personal_vfx_v100a_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    if not all(item["pass"] for item in validation):
        raise SystemExit("one or more V100 VFX assets failed validation; see run/vfx-v100/personal_vfx_v100a_validation.json")
    return contact


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, help="imagegen 3x1 reference PNG")
    args = parser.parse_args()
    print(build(Path(args.source)))


if __name__ == "__main__":
    main()
