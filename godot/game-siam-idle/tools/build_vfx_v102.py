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
RUN_DIR = WORKSPACE / "run" / "vfx-v102"

CENTERED = [(0, 6), (0, 3), (0, 0), (0, -1), (0, 1), (0, 4)]
PROJECTILE = [(-10, 2), (-6, 1), (-2, 0), (3, 0), (8, 1), (12, 2)]
CLEAVE = [(-4, 5), (-2, 2), (0, 0), (3, -1), (6, 1), (8, 4)]

EFFECTS = [
    {
        "hero_id": "C06_NAGA_NILNATEE",
        "key": "nilnatee_water_bind",
        "file": "skill_personal_nilnatee_water_bind_v102.png",
        "label": "Nilnatee naga water bind",
        "max_size": 60,
        "frame_offsets": CENTERED,
        "frame_scales": [0.44, 0.66, 0.90, 1.0, 0.78, 0.54],
    },
    {
        "hero_id": "D08_HUMAN_THIWA",
        "key": "thiwa_paper_curse_seal",
        "file": "skill_personal_thiwa_paper_curse_seal_v102.png",
        "label": "Thiwa paper seal debuff",
        "max_size": 58,
        "frame_offsets": CENTERED,
        "frame_scales": [0.46, 0.70, 0.92, 1.0, 0.76, 0.52],
    },
    {
        "hero_id": "B09_SPIRIT_AMBERNIGHT",
        "key": "ambernight_amber_pulse",
        "file": "skill_personal_ambernight_amber_pulse_v102.png",
        "label": "Ambernight amber pulse",
        "max_size": 58,
        "frame_offsets": CENTERED,
        "frame_scales": [0.44, 0.66, 0.90, 1.0, 0.78, 0.54],
    },
    {
        "hero_id": "C08_CROCODILE_KUMPHIL",
        "key": "kumphil_crocodile_aegis",
        "file": "skill_personal_kumphil_crocodile_aegis_v102.png",
        "label": "Kumphil crocodile scale aegis",
        "max_size": 60,
        "frame_offsets": CENTERED,
        "frame_scales": [0.44, 0.68, 0.92, 1.0, 0.78, 0.54],
    },
    {
        "hero_id": "D02_HUMAN_KHAMPAN",
        "key": "khampan_bronze_pot_guard",
        "file": "skill_personal_khampan_bronze_pot_guard_v102.png",
        "label": "Khampan bronze pot guard",
        "max_size": 60,
        "frame_offsets": CENTERED,
        "frame_scales": [0.44, 0.68, 0.92, 1.0, 0.78, 0.54],
    },
    {
        "hero_id": "S02_NAGA_SASINAKA",
        "key": "sasinaka_royal_naga_storm",
        "file": "skill_personal_sasinaka_royal_naga_storm_v102.png",
        "label": "Sasinaka royal naga storm",
        "max_size": 60,
        "frame_offsets": CENTERED,
        "frame_scales": [0.44, 0.68, 0.92, 1.0, 0.78, 0.54],
    },
    {
        "hero_id": "C03_HUMAN_PANA",
        "key": "pana_green_leaf_arrow",
        "file": "skill_personal_pana_green_leaf_arrow_v102.png",
        "label": "Pana green leaf arrow",
        "max_size": 56,
        "frame_offsets": PROJECTILE,
        "frame_scales": [0.46, 0.68, 0.90, 1.0, 0.78, 0.52],
    },
    {
        "hero_id": "D07_GARUDA_LOMPEEK",
        "key": "lompeek_wind_feather_dart",
        "file": "skill_personal_lompeek_wind_feather_dart_v102.png",
        "label": "Lompeek wind feather dart",
        "max_size": 56,
        "frame_offsets": PROJECTILE,
        "frame_scales": [0.46, 0.68, 0.90, 1.0, 0.78, 0.52],
    },
    {
        "hero_id": "C05_VANARA_JORJAN",
        "key": "jorjan_monkey_blade_cleave",
        "file": "skill_personal_jorjan_monkey_blade_cleave_v102.png",
        "label": "Jorjan green monkey blade cleave",
        "max_size": 58,
        "frame_offsets": CLEAVE,
        "frame_scales": [0.46, 0.70, 0.94, 1.0, 0.78, 0.52],
    },
    {
        "hero_id": "D05_VANARA_JUKJIK",
        "key": "jukjik_twin_claw_cut",
        "file": "skill_personal_jukjik_twin_claw_cut_v102.png",
        "label": "Jukjik twin claw cut",
        "max_size": 58,
        "frame_offsets": CLEAVE,
        "frame_scales": [0.46, 0.70, 0.94, 1.0, 0.78, 0.52],
    },
]


def build(source_path: Path) -> Path:
    RUN_DIR.mkdir(parents=True, exist_ok=True)
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    reference_copy = RUN_DIR / "imagegen_reference_v102a.png"
    shutil.copy2(source_path, reference_copy)

    source = Image.open(source_path).convert("RGBA")
    boxes = base.grid_boxes(source, 5, 2)
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
                "generation": "Built-in imagegen concept reference; chroma-key extracted, pixel-snapped, quantized, and converted into native 64x64 6-frame strip by tools/build_vfx_v102.py without modifying character sprites.",
                "validation_pass": bool(result["pass"]),
            }
        )

    contact = RUN_DIR / "personal_vfx_v102a_contact.png"
    base.make_contact(entries, contact)
    (RUN_DIR / "personal_vfx_v102a_validation.json").write_text(
        json.dumps(validation, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    manifest = {
        "version": "v102a",
        "date": "2026-06-30",
        "source_imagegen_path": str(source_path),
        "reference_copy": str(reference_copy),
        "scope": "V102 replacements for ten V93 runtime-readability blockers identified by independent subagent QC. Character sprites are not modified.",
        "chroma_key": "#ff00ff",
        "cell": base.CELL,
        "frames": base.FRAMES,
        "source_layout": {"columns": 5, "rows": 2},
        "effects": manifest_entries,
    }
    (RUN_DIR / "personal_vfx_v102a_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    if not all(item["pass"] for item in validation):
        raise SystemExit("one or more V102 VFX assets failed validation; see run/vfx-v102/personal_vfx_v102a_validation.json")
    return contact


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, help="imagegen 5x2 reference PNG")
    args = parser.parse_args()
    print(build(Path(args.source)))


if __name__ == "__main__":
    main()
