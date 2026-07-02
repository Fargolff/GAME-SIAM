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
RUN_DIR = WORKSPACE / "run" / "vfx-v98"

EFFECTS = [
    {
        "hero_id": "D10_SPIRIT_OUNRUEN",
        "key": "ounruen_wispy_dash_strike",
        "file": "skill_personal_ounruen_wispy_dash_strike_v98.png",
        "label": "Ounruen spirit heal",
        "max_size": 56,
        "frame_offsets": [(0, 5), (0, 2), (0, 0), (0, -1), (0, 1), (0, 4)],
        "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.74, 0.50],
    },
    {
        "hero_id": "A06_SPIRIT_RAMPAN_MASK",
        "key": "rampan_spirit_mask_shatter",
        "file": "skill_personal_rampan_spirit_mask_shatter_v98.png",
        "label": "Rampan mask tether",
        "max_size": 56,
        "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)],
        "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.74, 0.50],
    },
    {
        "hero_id": "B02_NAGA_KLEDKRAM",
        "key": "kledkram_water_snare_coil",
        "file": "skill_personal_kledkram_water_snare_coil_v98.png",
        "label": "Kledkram water snare coil",
        "max_size": 58,
        "frame_offsets": [(-4, 6), (-2, 3), (0, 0), (2, 0), (4, 2), (6, 5)],
        "frame_scales": [0.44, 0.68, 0.94, 1.0, 0.76, 0.52],
    },
    {
        "hero_id": "D06_NAGA_BUABUCHA",
        "key": "buabucha_lotus_root_bind",
        "file": "skill_personal_buabucha_lotus_root_bind_v98.png",
        "label": "Buabucha lotus root bind",
        "max_size": 58,
        "frame_offsets": [(-3, 6), (-1, 3), (0, 0), (1, -1), (3, 1), (5, 4)],
        "frame_scales": [0.44, 0.68, 0.94, 1.0, 0.76, 0.52],
    },
    {
        "hero_id": "B08_HUMAN_MUENMONTRA",
        "key": "muen_mantra_paper_tear",
        "file": "skill_personal_muen_mantra_paper_tear_v98.png",
        "label": "Muen torn talisman curse",
        "max_size": 58,
        "frame_offsets": [(-10, 1), (-6, 0), (-2, 0), (3, 0), (7, 1), (10, 2)],
        "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.76, 0.52],
    },
    {
        "hero_id": "C10_SPIRIT_KHOMKHAM",
        "key": "khomkham_soul_flame_seal",
        "file": "skill_personal_khomkham_soul_flame_seal_v98.png",
        "label": "Khomkham soul lock",
        "max_size": 56,
        "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)],
        "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.74, 0.50],
    },
    {
        "hero_id": "B07_DRYAD_BUTSABA",
        "key": "butsaba_thorn_eruption",
        "file": "skill_personal_butsaba_thorn_eruption_v98.png",
        "label": "Butsaba thorn spirit sprout",
        "max_size": 56,
        "frame_offsets": [(0, 6), (0, 3), (0, 0), (0, -1), (0, 1), (0, 4)],
        "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.74, 0.50],
    },
    {
        "hero_id": "D09_CONSTRUCT_SILADIN",
        "key": "siladin_stone_fist_ground_slam",
        "file": "skill_personal_siladin_stone_fist_ground_slam_v98.png",
        "label": "Siladin stone fist rise",
        "max_size": 60,
        "frame_offsets": [(-2, 6), (-1, 3), (0, 0), (1, 1), (2, 3), (3, 6)],
        "frame_scales": [0.44, 0.68, 0.96, 1.0, 0.76, 0.52],
    },
    {
        "hero_id": "C09_KINNARI_KAEWKANGSADAN",
        "key": "kaew_crystal_chime_shards",
        "file": "skill_personal_kaew_crystal_chime_shards_v98.png",
        "label": "Kaew crystal chime heal",
        "max_size": 56,
        "frame_offsets": [(0, 5), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)],
        "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.74, 0.50],
    },
    {
        "hero_id": "D04_HUMAN_TAEMTHONG",
        "key": "taem_gold_thread_cross_cut",
        "file": "skill_personal_taem_gold_thread_cross_cut_v98.png",
        "label": "Taem gold thread mend",
        "max_size": 56,
        "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)],
        "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.74, 0.50],
    },
]


def build(source_path: Path) -> Path:
    RUN_DIR.mkdir(parents=True, exist_ok=True)
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    reference_copy = RUN_DIR / "imagegen_reference_v98a.png"
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
                "generation": "Built-in imagegen concept reference; chroma-key extracted, pixel-snapped, quantized, and converted into native 64x64 6-frame strip by tools/build_vfx_v98.py without modifying character sprites.",
                "validation_pass": bool(result["pass"]),
            }
        )

    contact = RUN_DIR / "personal_vfx_v98a_contact.png"
    base.make_contact(entries, contact)
    (RUN_DIR / "personal_vfx_v98a_validation.json").write_text(
        json.dumps(validation, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    manifest = {
        "version": "v98a",
        "date": "2026-06-30",
        "source_imagegen_path": str(source_path),
        "reference_copy": str(reference_copy),
        "scope": "V98 targeted replacements for remaining root/debuff/summon/heal personal skill VFX flagged by independent QC. Character sprites are not modified.",
        "chroma_key": "#ff00ff",
        "cell": base.CELL,
        "frames": base.FRAMES,
        "source_layout": {"columns": 5, "rows": 2},
        "effects": manifest_entries,
    }
    (RUN_DIR / "personal_vfx_v98a_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    if not all(item["pass"] for item in validation):
        raise SystemExit("one or more V98 VFX assets failed validation; see run/vfx-v98/personal_vfx_v98a_validation.json")
    return contact


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, help="imagegen 5x2 reference PNG")
    args = parser.parse_args()
    print(build(Path(args.source)))


if __name__ == "__main__":
    main()
