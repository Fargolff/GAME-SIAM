from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path

from PIL import Image


SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

import build_vfx_v80 as base


WORKSPACE = Path(r"C:\Users\ADMIN\Documents\GAME IDLE")
PROJECT = WORKSPACE / "godot" / "game-siam-idle"
ASSET_DIR = PROJECT / "assets" / "vfx" / "generated"
RUN_DIR = WORKSPACE / "run" / "vfx-v93"
FRAMES = 6


STYLE_MOTION = {
    "smash": {
        "max_size": 62,
        "frame_offsets": [(-5, 7), (-2, 3), (0, 0), (2, 1), (5, 4), (7, 7)],
        "frame_scales": [0.50, 0.74, 1.0, 0.96, 0.76, 0.54],
    },
    "slash": {
        "max_size": 62,
        "frame_offsets": [(-11, 5), (-6, 2), (-1, 0), (4, 1), (9, 3), (12, 5)],
        "frame_scales": [0.46, 0.70, 0.98, 1.0, 0.76, 0.52],
    },
    "projectile": {
        "max_size": 61,
        "frame_offsets": [(-13, 0), (-8, 0), (-3, 0), (3, 0), (8, 1), (12, 2)],
        "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.76, 0.52],
    },
    "burst": {
        "max_size": 60,
        "frame_offsets": [(-4, 5), (-2, 2), (0, 0), (2, 1), (4, 3), (6, 5)],
        "frame_scales": [0.48, 0.72, 1.0, 0.96, 0.74, 0.52],
    },
    "bind": {
        "max_size": 60,
        "frame_offsets": [(-5, 6), (-2, 2), (0, 0), (1, -1), (3, 1), (5, 4)],
        "frame_scales": [0.48, 0.72, 1.0, 0.96, 0.76, 0.54],
    },
    "guard": {
        "max_size": 60,
        "frame_offsets": [(0, 6), (0, 2), (0, 0), (0, 1), (0, 3), (0, 6)],
        "frame_scales": [0.48, 0.72, 1.0, 0.94, 0.72, 0.52],
    },
}


HEROES = [
    ("S03_YAKSHA_KRAIASURA", "yaksha_stone_shield_smash", "skill_personal_yaksha_stone_shield_smash_v93.png", "smash"),
    ("S01_GARUDA_VAYUDEJ", "garuda_beak_wing_v_slash", "skill_personal_garuda_beak_wing_v_slash_v93.png", "slash"),
    ("S02_NAGA_SASINAKA", "naga_crescent_coil_strike", "skill_personal_naga_crescent_coil_strike_v93.png", "bind"),
    ("A02_TIGER_PLOENGPAYAK", "tiger_flaming_jaw_claw", "skill_personal_tiger_flaming_jaw_claw_v93.png", "slash"),
    ("A03_HUMAN_ARUNRAT", "arun_sun_arrow_spear", "skill_personal_arun_sun_arrow_spear_v93.png", "projectile"),
    ("A01_KINNARI_PIMPPRUEKSA", "kinnari_lotus_feather_grace", "skill_personal_kinnari_lotus_feather_grace_v93.png", "burst"),
    ("A04_VANARA_KALAVANARA", "kalavanara_staff_sweep_crescent", "skill_personal_kalavanara_staff_sweep_crescent_v93.png", "slash"),
    ("A05_MAKARA_MAKORNKRAM", "makara_scale_guard_crash", "skill_personal_makara_scale_guard_crash_v93.png", "guard"),
    ("A06_SPIRIT_RAMPAN_MASK", "rampan_spirit_mask_shatter", "skill_personal_rampan_spirit_mask_shatter_v93.png", "burst"),
    ("A07_HUMAN_CHANGJAKKAEW", "chang_charm_bead_shatter", "skill_personal_chang_charm_bead_shatter_v93.png", "burst"),
    ("B01_GARUDA_MEKHAVI", "mekhavi_ringed_wind_spear", "skill_personal_mekhavi_ringed_wind_spear_v93.png", "projectile"),
    ("B02_NAGA_KLEDKRAM", "kledkram_water_snare_coil", "skill_personal_kledkram_water_snare_coil_v93.png", "bind"),
    ("B03_YAKSHA_KHUNPHA", "khunpha_diagonal_yaksha_axe", "skill_personal_khunpha_diagonal_yaksha_axe_v93.png", "smash"),
    ("B04_HUMAN_DARIN", "darin_dagger_seal_cut", "skill_personal_darin_dagger_seal_cut_v93.png", "slash"),
    ("B05_KINNARA_RAVIKAN", "ravikan_music_wave_slash", "skill_personal_ravikan_music_wave_slash_v93.png", "slash"),
    ("B06_BEAST_SINGKHON", "singkhon_fang_roar_hit", "skill_personal_singkhon_fang_roar_hit_v93.png", "slash"),
    ("B07_DRYAD_BUTSABA", "butsaba_thorn_eruption", "skill_personal_butsaba_thorn_eruption_v93.png", "bind"),
    ("B08_HUMAN_MUENMONTRA", "muen_mantra_paper_tear", "skill_personal_muen_mantra_paper_tear_v93.png", "slash"),
    ("B09_SPIRIT_AMBERNIGHT", "ambernight_shadow_claw", "skill_personal_ambernight_shadow_claw_v93.png", "slash"),
    ("B10_MERFOLK_MUKWAREE", "mukwaree_pearl_splash_wave", "skill_personal_mukwaree_pearl_splash_wave_v93.png", "burst"),
    ("C01_HUMAN_JETSIAM", "jetsiam_krabi_guard_thrust", "skill_personal_jetsiam_krabi_guard_thrust_v93.png", "projectile"),
    ("C02_KHACHASIH_LOHDIN", "lohdin_stone_bulwark_slam", "skill_personal_lohdin_stone_bulwark_slam_v93.png", "guard"),
    ("C03_HUMAN_PANA", "pana_green_leaf_arrow", "skill_personal_pana_green_leaf_arrow_v93.png", "projectile"),
    ("C04_HUMAN_CHABA", "chaba_hibiscus_petal_burst", "skill_personal_chaba_hibiscus_petal_burst_v93.png", "burst"),
    ("C05_VANARA_JORJAN", "jorjan_small_blade_slice", "skill_personal_jorjan_small_blade_slice_v93.png", "slash"),
    ("C06_NAGA_NILNATEE", "nilnatee_water_rope_snap", "skill_personal_nilnatee_water_rope_snap_v93.png", "bind"),
    ("C07_GARUDA_PEEKTHONG", "peekthong_triple_peacock_darts", "skill_personal_peekthong_triple_peacock_darts_v93.png", "projectile"),
    ("C08_CROCODILE_KUMPHIL", "kumphil_crocodile_jaw_sweep", "skill_personal_kumphil_crocodile_jaw_sweep_v93.png", "slash"),
    ("C09_KINNARI_KAEWKANGSADAN", "kaew_crystal_chime_shards", "skill_personal_kaew_crystal_chime_shards_v93.png", "burst"),
    ("C10_SPIRIT_KHOMKHAM", "khomkham_soul_flame_seal", "skill_personal_khomkham_soul_flame_seal_v93.png", "burst"),
    ("D01_HUMAN_PHAIKLA", "phaikla_fist_shockwave", "skill_personal_phaikla_fist_shockwave_v93.png", "smash"),
    ("D02_HUMAN_KHAMPAN", "khampan_bronze_pot_lid_bash", "skill_personal_khampan_bronze_pot_lid_bash_v93.png", "guard"),
    ("D03_HUMAN_PRANNOI", "prannoi_wood_bowstring_snap", "skill_personal_prannoi_wood_bowstring_snap_v93.png", "projectile"),
    ("D04_HUMAN_TAEMTHONG", "taem_gold_thread_cross_cut", "skill_personal_taem_gold_thread_cross_cut_v93.png", "slash"),
    ("D05_VANARA_JUKJIK", "jukjik_monkey_paw_slap", "skill_personal_jukjik_monkey_paw_slap_v93.png", "smash"),
    ("D06_NAGA_BUABUCHA", "buabucha_lotus_root_bind", "skill_personal_buabucha_lotus_root_bind_v93.png", "bind"),
    ("D07_GARUDA_LOMPEEK", "lompeek_tiny_tornado_dart", "skill_personal_lompeek_tiny_tornado_dart_v93.png", "projectile"),
    ("D08_HUMAN_THIWA", "thiwa_dusk_talisman_break", "skill_personal_thiwa_dusk_talisman_break_v93.png", "burst"),
    ("D09_CONSTRUCT_SILADIN", "siladin_stone_fist_ground_slam", "skill_personal_siladin_stone_fist_ground_slam_v93.png", "smash"),
    ("D10_SPIRIT_OUNRUEN", "ounruen_wispy_dash_strike", "skill_personal_ounruen_wispy_dash_strike_v93.png", "projectile"),
]


def spec_for(hero_id: str, key: str, file_name: str, style: str) -> dict[str, object]:
    motion = STYLE_MOTION[style]
    return {
        "hero_id": hero_id,
        "key": key,
        "file": file_name,
        "label": key.replace("_", " "),
        "style": style,
        "max_size": motion["max_size"],
        "frame_offsets": motion["frame_offsets"],
        "frame_scales": motion["frame_scales"],
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, help="Imagegen 8x5 concept sheet with #ff00ff chroma background")
    args = parser.parse_args()

    source_path = Path(args.source)
    RUN_DIR.mkdir(parents=True, exist_ok=True)
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    reference_copy = RUN_DIR / "imagegen_reference_v93a.png"
    shutil.copy2(source_path, reference_copy)

    source = Image.open(source_path).convert("RGBA")
    boxes = base.grid_boxes(source, 8, 5)
    specs = [spec_for(*item) for item in HEROES]

    validation: list[dict[str, object]] = []
    entries: list[tuple[dict[str, object], Path]] = []
    manifest_entries: list[dict[str, object]] = []
    for spec, box in zip(specs, boxes):
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
                "style": spec["style"],
                "asset": f"res://assets/vfx/generated/{spec['file']}",
                "source_reference": str(reference_copy),
                "source_grid_box": list(box),
                "generation": "Built-in imagegen 8x5 concept sheet, chroma-key extracted and converted into native 64x64 6-frame pixel strip by tools/build_vfx_v93.py.",
                "validation_pass": bool(result["pass"]),
            }
        )

    contact = RUN_DIR / "personal_vfx_v93a_contact.png"
    base.make_contact(entries, contact)
    (RUN_DIR / "personal_vfx_v93a_validation.json").write_text(json.dumps(validation, ensure_ascii=False, indent=2), encoding="utf-8")
    manifest = {
        "version": "v93a",
        "date": "2026-06-30",
        "source_imagegen_path": str(source_path),
        "reference_copy": str(reference_copy),
        "scope": "All 40 personal attack/skill VFX regenerated from a single imagegen source sheet; character sprites are not modified.",
        "chroma_key": "#ff00ff",
        "columns": 8,
        "rows": 5,
        "cell": base.CELL,
        "frames": FRAMES,
        "effects": manifest_entries,
    }
    (RUN_DIR / "personal_vfx_v93a_manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    if not all(item["pass"] for item in validation):
        raise SystemExit("one or more V93 VFX assets failed validation; see personal_vfx_v93a_validation.json")
    print(contact)


if __name__ == "__main__":
    main()
