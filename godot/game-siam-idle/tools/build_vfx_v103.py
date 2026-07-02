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
RUN_DIR = WORKSPACE / "run" / "vfx-v103"

CENTERED = [(0, 6), (0, 3), (0, 0), (0, -1), (0, 1), (0, 4)]
PROJECTILE = [(-10, 2), (-6, 1), (-2, 0), (3, 0), (8, 1), (12, 2)]
CLEAVE = [(-4, 5), (-2, 2), (0, 0), (3, -1), (6, 1), (8, 4)]

EFFECTS = [
    {
        "hero_id": "S01_GARUDA_VAYUDEJ",
        "key": "vayudej_garuda_talon",
        "file": "skill_personal_vayudej_garuda_talon_v103.png",
        "label": "Vayudej garuda talon",
        "max_size": 60,
        "frame_offsets": CLEAVE,
        "frame_scales": [0.44, 0.68, 0.92, 1.0, 0.78, 0.54],
    },
    {
        "hero_id": "A02_TIGER_PLOENGPAYAK",
        "key": "ploengpayak_tiger_flame_cut",
        "file": "skill_personal_ploengpayak_tiger_flame_cut_v103.png",
        "label": "Ploengpayak tiger flame cut",
        "max_size": 60,
        "frame_offsets": CLEAVE,
        "frame_scales": [0.44, 0.68, 0.92, 1.0, 0.78, 0.54],
    },
    {
        "hero_id": "A03_HUMAN_ARUNRAT",
        "key": "arunrat_sun_arrow_spear",
        "file": "skill_personal_arunrat_sun_arrow_spear_v103.png",
        "label": "Arunrat sun arrow spear",
        "max_size": 56,
        "frame_offsets": PROJECTILE,
        "frame_scales": [0.46, 0.68, 0.90, 1.0, 0.78, 0.52],
    },
    {
        "hero_id": "A04_VANARA_KALAVANARA",
        "key": "kalavanara_staff_sweep",
        "file": "skill_personal_kalavanara_staff_sweep_v103.png",
        "label": "Kalavanara staff sweep",
        "max_size": 58,
        "frame_offsets": CLEAVE,
        "frame_scales": [0.46, 0.70, 0.94, 1.0, 0.78, 0.52],
    },
    {
        "hero_id": "B01_GARUDA_MEKHAVI",
        "key": "mekhavi_wind_spear",
        "file": "skill_personal_mekhavi_wind_spear_v103.png",
        "label": "Mekhavi wind spear",
        "max_size": 56,
        "frame_offsets": PROJECTILE,
        "frame_scales": [0.46, 0.68, 0.90, 1.0, 0.78, 0.52],
    },
    {
        "hero_id": "B03_YAKSHA_KHUNPHA",
        "key": "khunpha_yaksha_axe_cleave",
        "file": "skill_personal_khunpha_yaksha_axe_cleave_v103.png",
        "label": "Khunpha yaksha axe cleave",
        "max_size": 60,
        "frame_offsets": CLEAVE,
        "frame_scales": [0.44, 0.68, 0.92, 1.0, 0.78, 0.54],
    },
    {
        "hero_id": "C01_HUMAN_JETSIAM",
        "key": "jetsiam_krabi_thrust",
        "file": "skill_personal_jetsiam_krabi_thrust_v103.png",
        "label": "Jetsiam krabi thrust",
        "max_size": 56,
        "frame_offsets": PROJECTILE,
        "frame_scales": [0.46, 0.68, 0.90, 1.0, 0.78, 0.52],
    },
    {
        "hero_id": "C07_GARUDA_PEEKTHONG",
        "key": "peekthong_peacock_darts",
        "file": "skill_personal_peekthong_peacock_darts_v103.png",
        "label": "Peekthong peacock darts",
        "max_size": 56,
        "frame_offsets": PROJECTILE,
        "frame_scales": [0.46, 0.68, 0.90, 1.0, 0.78, 0.52],
    },
    {
        "hero_id": "D01_HUMAN_PHAIKLA",
        "key": "phaikla_fist_shockwave",
        "file": "skill_personal_phaikla_fist_shockwave_v103.png",
        "label": "Phaikla fist shockwave",
        "max_size": 58,
        "frame_offsets": CENTERED,
        "frame_scales": [0.44, 0.68, 0.92, 1.0, 0.78, 0.54],
    },
    {
        "hero_id": "D03_HUMAN_PRANNOI",
        "key": "prannoi_wood_bow_shot",
        "file": "skill_personal_prannoi_wood_bow_shot_v103.png",
        "label": "Prannoi wood bow shot",
        "max_size": 56,
        "frame_offsets": PROJECTILE,
        "frame_scales": [0.46, 0.68, 0.90, 1.0, 0.78, 0.52],
    },
]


def build(source_path: Path) -> Path:
    RUN_DIR.mkdir(parents=True, exist_ok=True)
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    reference_copy = RUN_DIR / "imagegen_reference_v103a.png"
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
                "generation": "Built-in imagegen concept reference; chroma-key extracted, pixel-snapped, quantized, and converted into native 64x64 6-frame strip by tools/build_vfx_v103.py without modifying character sprites.",
                "validation_pass": bool(result["pass"]),
            }
        )

    contact = RUN_DIR / "personal_vfx_v103a_contact.png"
    base.make_contact(entries, contact)
    (RUN_DIR / "personal_vfx_v103a_validation.json").write_text(
        json.dumps(validation, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    manifest = {
        "version": "v103a",
        "date": "2026-07-01",
        "source_imagegen_path": str(source_path),
        "reference_copy": str(reference_copy),
        "scope": "V103 replacements for the remaining ten V93 baseline personal attack/skill VFX. Character sprites are not modified.",
        "chroma_key": "#ff00ff",
        "cell": base.CELL,
        "frames": base.FRAMES,
        "source_layout": {"columns": 5, "rows": 2},
        "effects": manifest_entries,
    }
    (RUN_DIR / "personal_vfx_v103a_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    if not all(item["pass"] for item in validation):
        raise SystemExit("one or more V103 VFX assets failed validation; see run/vfx-v103/personal_vfx_v103a_validation.json")
    return contact


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, help="imagegen 5x2 reference PNG")
    args = parser.parse_args()
    print(build(Path(args.source)))


if __name__ == "__main__":
    main()
