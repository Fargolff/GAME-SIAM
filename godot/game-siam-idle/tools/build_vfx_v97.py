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
RUN_DIR = WORKSPACE / "run" / "vfx-v97"

EFFECTS = [
    {
        "hero_id": "A01_KINNARI_PIMPPRUEKSA",
        "key": "kinnari_lotus_feather_grace",
        "file": "skill_personal_kinnari_lotus_feather_grace_v97.png",
        "label": "Pimp feather lotus grace",
        "max_size": 58,
        "frame_offsets": [(-10, 4), (-6, 2), (-2, 0), (3, -1), (7, 0), (10, 2)],
        "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.76, 0.52],
    },
    {
        "hero_id": "A07_HUMAN_CHANGJAKKAEW",
        "key": "chang_charm_bead_shatter",
        "file": "skill_personal_chang_charm_bead_shatter_v97.png",
        "label": "Chang charm bead shatter",
        "max_size": 58,
        "frame_offsets": [(-8, 2), (-4, 1), (0, 0), (4, 0), (8, 1), (10, 3)],
        "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.76, 0.52],
    },
    {
        "hero_id": "B05_KINNARA_RAVIKAN",
        "key": "ravikan_music_wave_slash",
        "file": "skill_personal_ravikan_music_wave_slash_v97.png",
        "label": "Ravikan wing song wave",
        "max_size": 58,
        "frame_offsets": [(-10, 1), (-6, 0), (-2, 0), (3, 0), (7, 1), (10, 2)],
        "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.76, 0.52],
    },
    {
        "hero_id": "B10_MERFOLK_MUKWAREE",
        "key": "mukwaree_pearl_splash_wave",
        "file": "skill_personal_mukwaree_pearl_splash_wave_v97.png",
        "label": "Mukwaree pearl splash wave",
        "max_size": 58,
        "frame_offsets": [(-9, 4), (-5, 2), (-1, 0), (3, 0), (7, 1), (10, 2)],
        "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.76, 0.52],
    },
    {
        "hero_id": "C04_HUMAN_CHABA",
        "key": "chaba_hibiscus_petal_burst",
        "file": "skill_personal_chaba_hibiscus_petal_burst_v97.png",
        "label": "Chaba hibiscus petal burst",
        "max_size": 58,
        "frame_offsets": [(-8, 3), (-4, 2), (0, 0), (4, 0), (8, 1), (10, 3)],
        "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.76, 0.52],
    },
    {
        "hero_id": "S03_YAKSHA_KRAIASURA",
        "key": "yaksha_stone_shield_smash",
        "file": "skill_personal_yaksha_stone_shield_smash_v97.png",
        "label": "Krai stone shield smash",
        "max_size": 60,
        "frame_offsets": [(-5, 6), (-2, 3), (0, 0), (2, 1), (4, 3), (6, 6)],
        "frame_scales": [0.46, 0.70, 0.98, 1.0, 0.74, 0.50],
    },
    {
        "hero_id": "A05_MAKARA_MAKORNKRAM",
        "key": "makara_scale_guard_crash",
        "file": "skill_personal_makara_scale_guard_crash_v97.png",
        "label": "Makorn scale guard crash",
        "max_size": 60,
        "frame_offsets": [(-8, 4), (-4, 2), (0, 0), (4, 0), (8, 1), (10, 3)],
        "frame_scales": [0.46, 0.70, 0.98, 1.0, 0.76, 0.52],
    },
    {
        "hero_id": "B06_BEAST_SINGKHON",
        "key": "singkhon_fang_roar_hit",
        "file": "skill_personal_singkhon_fang_roar_hit_v97.png",
        "label": "Singkhon fang roar hit",
        "max_size": 60,
        "frame_offsets": [(-8, 4), (-4, 2), (0, 0), (4, 1), (8, 2), (10, 4)],
        "frame_scales": [0.46, 0.70, 0.98, 1.0, 0.76, 0.52],
    },
    {
        "hero_id": "C02_KHACHASIH_LOHDIN",
        "key": "lohdin_stone_bulwark_slam",
        "file": "skill_personal_lohdin_stone_bulwark_slam_v97.png",
        "label": "Lohdin stone bulwark slam",
        "max_size": 60,
        "frame_offsets": [(-4, 6), (-2, 3), (0, 0), (2, 1), (4, 3), (6, 6)],
        "frame_scales": [0.46, 0.70, 0.98, 1.0, 0.74, 0.50],
    },
    {
        "hero_id": "B04_HUMAN_DARIN",
        "key": "darin_dagger_seal_cut",
        "file": "skill_personal_darin_dagger_seal_cut_v97.png",
        "label": "Darin dagger seal cut",
        "max_size": 58,
        "frame_offsets": [(-10, 1), (-6, 0), (-2, 0), (3, 0), (7, 1), (10, 2)],
        "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.76, 0.52],
    },
]


def build(source_path: Path) -> Path:
    RUN_DIR.mkdir(parents=True, exist_ok=True)
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    reference_copy = RUN_DIR / "imagegen_reference_v97a.png"
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
                "generation": "Built-in imagegen concept reference; chroma-key extracted, pixel-snapped, quantized, and converted into native 64x64 6-frame strip by tools/build_vfx_v97.py without modifying character sprites.",
                "validation_pass": bool(result["pass"]),
            }
        )

    contact = RUN_DIR / "personal_vfx_v97a_contact.png"
    base.make_contact(entries, contact)
    (RUN_DIR / "personal_vfx_v97a_validation.json").write_text(
        json.dumps(validation, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    manifest = {
        "version": "v97a",
        "date": "2026-06-30",
        "source_imagegen_path": str(source_path),
        "reference_copy": str(reference_copy),
        "scope": "V97 targeted replacements for support/heal, taunt, and one debuff personal skill VFX that still looked too similar in V96. Character sprites are not modified.",
        "chroma_key": "#ff00ff",
        "cell": base.CELL,
        "frames": base.FRAMES,
        "source_layout": {"columns": 5, "rows": 2},
        "effects": manifest_entries,
    }
    (RUN_DIR / "personal_vfx_v97a_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    if not all(item["pass"] for item in validation):
        raise SystemExit("one or more V97 VFX assets failed validation; see run/vfx-v97/personal_vfx_v97a_validation.json")
    return contact


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, help="imagegen 5x2 reference PNG")
    args = parser.parse_args()
    print(build(Path(args.source)))


if __name__ == "__main__":
    main()
