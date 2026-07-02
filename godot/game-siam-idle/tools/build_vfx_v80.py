from __future__ import annotations

import argparse
import json
import math
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


WORKSPACE = Path(r"C:\Users\ADMIN\Documents\GAME IDLE")
PROJECT = WORKSPACE / "godot" / "game-siam-idle"
ASSET_DIR = PROJECT / "assets" / "vfx" / "generated"
CELL = 64
FRAMES = 6
KEY = (255, 0, 255)

BATCHES = {
    "v80": {
        "run_dir": WORKSPACE / "run" / "vfx-v80",
        "reference": "imagegen_reference_v80.png",
        "contact": "personal_vfx_v80_contact.png",
        "validation": "personal_vfx_v80_validation.json",
        "manifest": "personal_vfx_v80_manifest.json",
        "scope": "Batch 1: five default-formation personal attack/skill VFX strips. Character sprites are not modified.",
        "effects": [
    {
        "hero_id": "S03_YAKSHA_KRAIASURA",
        "key": "yaksha_aegis",
        "file": "skill_personal_yaksha_aegis_v80.png",
        "label": "Yaksha aegis",
        "max_size": 48,
        "frame_offsets": [(0, 3), (0, 1), (0, 0), (0, 1), (0, 2), (0, 4)],
        "frame_scales": [0.55, 0.78, 1.00, 0.92, 0.72, 0.50],
    },
    {
        "hero_id": "S01_GARUDA_VAYUDEJ",
        "key": "garuda_talon",
        "file": "skill_personal_garuda_talon_v80.png",
        "label": "Garuda talon",
        "max_size": 54,
        "frame_offsets": [(-7, 4), (-3, 2), (0, 0), (3, -1), (5, -2), (7, -3)],
        "frame_scales": [0.50, 0.74, 1.00, 0.95, 0.74, 0.52],
    },
    {
        "hero_id": "S02_NAGA_SASINAKA",
        "key": "naga_moon_coil",
        "file": "skill_personal_naga_moon_coil_v80.png",
        "label": "Naga coil",
        "max_size": 52,
        "frame_offsets": [(0, 3), (0, 1), (0, 0), (0, -1), (0, 1), (0, 3)],
        "frame_scales": [0.48, 0.72, 0.96, 1.00, 0.76, 0.50],
    },
    {
        "hero_id": "A02_TIGER_PLOENGPAYAK",
        "key": "tiger_flame_claw",
        "file": "skill_personal_tiger_flame_claw_v80.png",
        "label": "Tiger claw",
        "max_size": 54,
        "frame_offsets": [(-6, -3), (-3, -1), (0, 0), (3, 1), (5, 2), (7, 3)],
        "frame_scales": [0.45, 0.70, 1.00, 0.94, 0.70, 0.48],
    },
    {
        "hero_id": "A03_HUMAN_ARUNRAT",
        "key": "arun_arrow",
        "file": "skill_personal_arun_arrow_v80.png",
        "label": "Arun arrow",
        "max_size": 56,
        "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (2, 0), (6, 0), (9, 0)],
        "frame_scales": [0.48, 0.70, 0.92, 1.00, 0.78, 0.54],
    },
        ],
    },
    "v81a": {
        "run_dir": WORKSPACE / "run" / "vfx-v81",
        "reference": "imagegen_reference_v81a.png",
        "contact": "personal_vfx_v81a_contact.png",
        "validation": "personal_vfx_v81a_validation.json",
        "manifest": "personal_vfx_v81a_manifest.json",
        "scope": "Batch 2: A01 and A04-A07 personal attack/skill VFX strips. Character sprites are not modified.",
        "effects": [
            {"hero_id": "A01_KINNARI_PIMPPRUEKSA", "key": "kinnari_lotus_grace", "file": "skill_personal_kinnari_lotus_grace_v81.png", "label": "Kinnari lotus grace", "max_size": 42, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.92, 1.0, 0.72, 0.48]},
            {"hero_id": "A04_VANARA_KALAVANARA", "key": "vanara_staff_crash", "file": "skill_personal_vanara_staff_crash_v81.png", "label": "Vanara crash", "max_size": 50, "frame_offsets": [(-3, 4), (-1, 2), (0, 0), (2, 1), (4, 3), (6, 5)], "frame_scales": [0.48, 0.72, 1.0, 0.92, 0.68, 0.46]},
            {"hero_id": "A05_MAKARA_MAKORNKRAM", "key": "makara_scale_guard", "file": "skill_personal_makara_scale_guard_v81.png", "label": "Makara guard", "max_size": 46, "frame_offsets": [(0, 3), (0, 1), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.70, 0.96, 1.0, 0.72, 0.48]},
            {"hero_id": "A06_SPIRIT_RAMPAN_MASK", "key": "spirit_mask_hex", "file": "skill_personal_spirit_mask_hex_v81.png", "label": "Spirit mask hex", "max_size": 42, "frame_offsets": [(0, 2), (0, 1), (0, 0), (0, 1), (0, 2), (0, 4)], "frame_scales": [0.48, 0.70, 0.94, 1.0, 0.72, 0.50]},
            {"hero_id": "A07_HUMAN_CHANGJAKKAEW", "key": "chang_lotus_charm", "file": "skill_personal_chang_lotus_charm_v81.png", "label": "Chang lotus charm", "max_size": 42, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.92, 1.0, 0.72, 0.48]},
        ],
    },
    "v81b": {
        "run_dir": WORKSPACE / "run" / "vfx-v81",
        "reference": "imagegen_reference_v81b.png",
        "contact": "personal_vfx_v81b_contact.png",
        "validation": "personal_vfx_v81b_validation.json",
        "manifest": "personal_vfx_v81b_manifest.json",
        "scope": "Batch 3: B01-B05 personal attack/skill VFX strips. Character sprites are not modified.",
        "effects": [
            {"hero_id": "B01_GARUDA_MEKHAVI", "key": "mekhavi_wind_spear", "file": "skill_personal_mekhavi_wind_spear_v81.png", "label": "Mekhavi spear", "max_size": 54, "frame_offsets": [(-9, 0), (-5, 0), (-1, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.48, 0.70, 0.92, 1.0, 0.76, 0.52]},
            {"hero_id": "B02_NAGA_KLEDKRAM", "key": "kledkram_water_bind", "file": "skill_personal_kledkram_water_bind_v81.png", "label": "Kledkram bind", "max_size": 48, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, -1), (0, 1), (0, 4)], "frame_scales": [0.46, 0.70, 0.94, 1.0, 0.74, 0.50]},
            {"hero_id": "B03_YAKSHA_KHUNPHA", "key": "khunpha_stone_cleave", "file": "skill_personal_khunpha_stone_cleave_v81.png", "label": "Khunpha cleave", "max_size": 52, "frame_offsets": [(-4, 4), (-1, 2), (0, 0), (3, 1), (5, 3), (7, 5)], "frame_scales": [0.48, 0.72, 1.0, 0.92, 0.68, 0.46]},
            {"hero_id": "B04_HUMAN_DARIN", "key": "darin_dagger_seal", "file": "skill_personal_darin_dagger_seal_v81.png", "label": "Darin seal", "max_size": 46, "frame_offsets": [(-4, 2), (-2, 1), (0, 0), (3, 1), (5, 2), (7, 4)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.74, 0.50]},
            {"hero_id": "B05_KINNARA_RAVIKAN", "key": "ravikan_song_burst", "file": "skill_personal_ravikan_song_burst_v81.png", "label": "Ravikan song", "max_size": 42, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.92, 1.0, 0.72, 0.48]},
        ],
    },
    "v82a": {
        "run_dir": WORKSPACE / "run" / "vfx-v82",
        "reference": "imagegen_reference_v82a.png",
        "contact": "personal_vfx_v82a_contact.png",
        "validation": "personal_vfx_v82a_validation.json",
        "manifest": "personal_vfx_v82a_manifest.json",
        "scope": "Batch 4: B06-B10 personal attack/skill VFX strips. Character sprites are not modified.",
        "effects": [
            {"hero_id": "B06_BEAST_SINGKHON", "key": "singkhon_roar_fang", "file": "skill_personal_singkhon_roar_fang_v82.png", "label": "Singkhon roar", "max_size": 42, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.94, 1.0, 0.72, 0.48]},
            {"hero_id": "B07_DRYAD_BUTSABA", "key": "butsaba_thorn_call", "file": "skill_personal_butsaba_thorn_call_v82.png", "label": "Butsaba call", "max_size": 44, "frame_offsets": [(0, 5), (0, 3), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.94, 1.0, 0.72, 0.48]},
            {"hero_id": "B08_HUMAN_MUENMONTRA", "key": "muen_charm_hex", "file": "skill_personal_muen_charm_hex_v82.png", "label": "Muen hex", "max_size": 42, "frame_offsets": [(0, 3), (0, 1), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.48, 0.70, 0.94, 1.0, 0.72, 0.50]},
            {"hero_id": "B09_SPIRIT_AMBERNIGHT", "key": "ambernight_ghost_pulse", "file": "skill_personal_ambernight_ghost_pulse_v82.png", "label": "Amber pulse", "max_size": 44, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.94, 1.0, 0.72, 0.48]},
            {"hero_id": "B10_MERFOLK_MUKWAREE", "key": "mukwaree_pearl_wave", "file": "skill_personal_mukwaree_pearl_wave_v82.png", "label": "Mukwaree grace", "max_size": 44, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.94, 1.0, 0.72, 0.48]},
        ],
    },
    "v82b": {
        "run_dir": WORKSPACE / "run" / "vfx-v82",
        "reference": "imagegen_reference_v82b.png",
        "contact": "personal_vfx_v82b_contact.png",
        "validation": "personal_vfx_v82b_validation.json",
        "manifest": "personal_vfx_v82b_manifest.json",
        "scope": "Batch 5: C01-C05 personal attack/skill VFX strips. Character sprites are not modified.",
        "effects": [
            {"hero_id": "C01_HUMAN_JETSIAM", "key": "jetsiam_krabi_strike", "file": "skill_personal_jetsiam_krabi_strike_v82.png", "label": "Jetsiam strike", "max_size": 52, "frame_offsets": [(-6, 2), (-3, 1), (0, 0), (3, 1), (6, 2), (8, 4)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.74, 0.50]},
            {"hero_id": "C02_KHACHASIH_LOHDIN", "key": "lohdin_bulwark_slam", "file": "skill_personal_lohdin_bulwark_slam_v82.png", "label": "Lohdin bulwark", "max_size": 42, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.94, 1.0, 0.72, 0.48]},
            {"hero_id": "C03_HUMAN_PANA", "key": "pana_leaf_arrow", "file": "skill_personal_pana_leaf_arrow_v82.png", "label": "Pana shot", "max_size": 50, "frame_offsets": [(-9, 0), (-5, 0), (-1, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.48, 0.70, 0.92, 1.0, 0.76, 0.52]},
            {"hero_id": "C04_HUMAN_CHABA", "key": "chaba_hibiscus_bloom", "file": "skill_personal_chaba_hibiscus_bloom_v82.png", "label": "Chaba bloom", "max_size": 42, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.92, 1.0, 0.72, 0.48]},
            {"hero_id": "C05_VANARA_JORJAN", "key": "jorjan_blade_cut", "file": "skill_personal_jorjan_blade_cut_v82.png", "label": "Jorjan cut", "max_size": 52, "frame_offsets": [(-6, 2), (-3, 1), (0, 0), (3, 1), (6, 2), (8, 4)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.74, 0.50]},
        ],
    },
    "v83a": {
        "run_dir": WORKSPACE / "run" / "vfx-v83",
        "reference": "imagegen_reference_v83a.png",
        "contact": "personal_vfx_v83a_contact.png",
        "validation": "personal_vfx_v83a_validation.json",
        "manifest": "personal_vfx_v83a_manifest.json",
        "scope": "Batch 6: C06-C10 personal attack/skill VFX strips. Character sprites are not modified.",
        "effects": [
            {"hero_id": "C06_NAGA_NILNATEE", "key": "nilnatee_water_bind", "file": "skill_personal_nilnatee_water_bind_v83.png", "label": "Nilnatee bind", "max_size": 50, "frame_offsets": [(0, 5), (0, 2), (0, 0), (0, -1), (0, 1), (0, 4)], "frame_scales": [0.46, 0.70, 0.94, 1.0, 0.74, 0.50]},
            {"hero_id": "C07_GARUDA_PEEKTHONG", "key": "peekthong_feather_dart", "file": "skill_personal_peekthong_feather_dart_v83.png", "label": "Peekthong dart", "max_size": 52, "frame_offsets": [(-9, 0), (-5, 0), (-1, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.48, 0.70, 0.92, 1.0, 0.76, 0.52]},
            {"hero_id": "C08_CROCODILE_KUMPHIL", "key": "kumphil_scale_aegis", "file": "skill_personal_kumphil_scale_aegis_v83.png", "label": "Kumphil aegis", "max_size": 46, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.94, 1.0, 0.72, 0.48]},
            {"hero_id": "C09_KINNARI_KAEWKANGSADAN", "key": "kaew_song_crystal", "file": "skill_personal_kaew_song_crystal_v83.png", "label": "Kaew song", "max_size": 44, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.94, 1.0, 0.72, 0.48]},
            {"hero_id": "C10_SPIRIT_KHOMKHAM", "key": "khomkham_lantern_seal", "file": "skill_personal_khomkham_lantern_seal_v83.png", "label": "Khomkham seal", "max_size": 44, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.94, 1.0, 0.72, 0.48]},
        ],
    },
    "v83b": {
        "run_dir": WORKSPACE / "run" / "vfx-v83",
        "reference": "imagegen_reference_v83b.png",
        "contact": "personal_vfx_v83b_contact.png",
        "validation": "personal_vfx_v83b_validation.json",
        "manifest": "personal_vfx_v83b_manifest.json",
        "scope": "Batch 7: D01-D05 personal attack/skill VFX strips. Character sprites are not modified.",
        "effects": [
            {"hero_id": "D01_HUMAN_PHAIKLA", "key": "phaikla_blow", "file": "skill_personal_phaikla_blow_v83.png", "label": "Phaikla blow", "max_size": 52, "frame_offsets": [(-6, 2), (-3, 1), (0, 0), (3, 1), (6, 2), (8, 4)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.74, 0.50]},
            {"hero_id": "D02_HUMAN_KHAMPAN", "key": "khampan_bronze_guard", "file": "skill_personal_khampan_bronze_guard_v83.png", "label": "Khampan guard", "max_size": 46, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.94, 1.0, 0.72, 0.48]},
            {"hero_id": "D03_HUMAN_PRANNOI", "key": "prannoi_wood_arrow", "file": "skill_personal_prannoi_wood_arrow_v83.png", "label": "Prannoi arrow", "max_size": 54, "frame_offsets": [(-9, 0), (-5, 0), (-1, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.48, 0.70, 0.92, 1.0, 0.76, 0.52]},
            {"hero_id": "D04_HUMAN_TAEMTHONG", "key": "taem_gold_thread_grace", "file": "skill_personal_taem_gold_thread_grace_v83.png", "label": "Taem grace", "max_size": 42, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.92, 1.0, 0.72, 0.48]},
            {"hero_id": "D05_VANARA_JUKJIK", "key": "jukjik_claw_cut", "file": "skill_personal_jukjik_claw_cut_v83.png", "label": "Jukjik cut", "max_size": 52, "frame_offsets": [(-6, 2), (-3, 1), (0, 0), (3, 1), (6, 2), (8, 4)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.74, 0.50]},
        ],
    },
    "v84a": {
        "run_dir": WORKSPACE / "run" / "vfx-v84",
        "reference": "imagegen_reference_v84a.png",
        "contact": "personal_vfx_v84a_contact.png",
        "validation": "personal_vfx_v84a_validation.json",
        "manifest": "personal_vfx_v84a_manifest.json",
        "scope": "Batch 8: D06-D10 personal attack/skill VFX strips. Character sprites are not modified.",
        "effects": [
            {"hero_id": "D06_NAGA_BUABUCHA", "key": "buabucha_lotus_bind", "file": "skill_personal_buabucha_lotus_bind_v84.png", "label": "Buabucha bind", "max_size": 48, "frame_offsets": [(0, 5), (0, 2), (0, 0), (0, -1), (0, 1), (0, 4)], "frame_scales": [0.46, 0.70, 0.94, 1.0, 0.74, 0.50]},
            {"hero_id": "D07_GARUDA_LOMPEEK", "key": "lompeek_wind_dart", "file": "skill_personal_lompeek_wind_dart_v84.png", "label": "Lompeek dart", "max_size": 52, "frame_offsets": [(-9, 0), (-5, 0), (-1, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.48, 0.70, 0.92, 1.0, 0.76, 0.52]},
            {"hero_id": "D08_HUMAN_THIWA", "key": "thiwa_dusk_seal", "file": "skill_personal_thiwa_dusk_seal_v84.png", "label": "Thiwa seal", "max_size": 50, "frame_offsets": [(-5, 2), (-2, 1), (0, 0), (3, 1), (6, 2), (8, 4)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.74, 0.50]},
            {"hero_id": "D09_CONSTRUCT_SILADIN", "key": "siladin_rune_call", "file": "skill_personal_siladin_rune_call_v84.png", "label": "Siladin call", "max_size": 48, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.94, 1.0, 0.72, 0.48]},
            {"hero_id": "D10_SPIRIT_OUNRUEN", "key": "ounruen_wisp_grace", "file": "skill_personal_ounruen_wisp_grace_v84.png", "label": "Ounruen grace", "max_size": 44, "frame_offsets": [(0, 4), (0, 2), (0, 0), (0, 1), (0, 3), (0, 5)], "frame_scales": [0.46, 0.68, 0.92, 1.0, 0.72, 0.48]},
        ],
    },
    "v85a": {
        "run_dir": WORKSPACE / "run" / "vfx-v85",
        "reference": "imagegen_reference_v85a.png",
        "contact": "personal_vfx_v85a_contact.png",
        "validation": "personal_vfx_v85a_validation.json",
        "manifest": "personal_vfx_v85a_manifest.json",
        "scope": "Batch 9: action-shaped replacements for six icon-like personal VFX. Character sprites are not modified.",
        "effects": [
            {"hero_id": "C08_CROCODILE_KUMPHIL", "key": "kumphil_lunge_impact", "file": "skill_personal_kumphil_lunge_impact_v85.png", "label": "Kumphil lunge", "max_size": 54, "frame_offsets": [(-6, 4), (-3, 2), (0, 0), (2, 1), (4, 2), (6, 4)], "frame_scales": [0.46, 0.70, 0.96, 1.0, 0.74, 0.50]},
            {"hero_id": "C10_SPIRIT_KHOMKHAM", "key": "khomkham_soul_burst", "file": "skill_personal_khomkham_soul_burst_v85.png", "label": "Khomkham burst", "max_size": 52, "frame_offsets": [(-9, 0), (-5, 0), (-1, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.48, 0.70, 0.92, 1.0, 0.76, 0.52]},
            {"hero_id": "D04_HUMAN_TAEMTHONG", "key": "taem_gold_thread_slash", "file": "skill_personal_taem_gold_thread_slash_v85.png", "label": "Taem slash", "max_size": 54, "frame_offsets": [(-7, 2), (-3, 1), (0, 0), (3, 1), (6, 2), (8, 4)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.74, 0.50]},
            {"hero_id": "D06_NAGA_BUABUCHA", "key": "buabucha_ground_bind", "file": "skill_personal_buabucha_ground_bind_v85.png", "label": "Buabucha bind", "max_size": 52, "frame_offsets": [(0, 5), (0, 2), (0, 0), (0, -1), (0, 1), (0, 4)], "frame_scales": [0.46, 0.70, 0.94, 1.0, 0.74, 0.50]},
            {"hero_id": "D09_CONSTRUCT_SILADIN", "key": "siladin_fist_slam", "file": "skill_personal_siladin_fist_slam_v85.png", "label": "Siladin slam", "max_size": 54, "frame_offsets": [(-2, 5), (-1, 2), (0, 0), (1, 1), (2, 3), (3, 5)], "frame_scales": [0.46, 0.70, 0.96, 1.0, 0.74, 0.50]},
            {"hero_id": "D10_SPIRIT_OUNRUEN", "key": "ounruen_wisp_dash", "file": "skill_personal_ounruen_wisp_dash_v85.png", "label": "Ounruen dash", "max_size": 52, "frame_offsets": [(-9, 1), (-5, 0), (-1, 0), (3, 0), (7, 0), (10, 1)], "frame_scales": [0.48, 0.70, 0.92, 1.0, 0.76, 0.52]},
        ],
    },
    "v85b": {
        "run_dir": WORKSPACE / "run" / "vfx-v85",
        "reference": "imagegen_reference_v85b.png",
        "contact": "personal_vfx_v85b_contact.png",
        "validation": "personal_vfx_v85b_validation.json",
        "manifest": "personal_vfx_v85b_manifest.json",
        "scope": "Batch 10: action-shaped replacement for A07 charm VFX. Character sprites are not modified.",
        "effects": [
            {"hero_id": "A07_HUMAN_CHANGJAKKAEW", "key": "chang_charm_shatter", "file": "skill_personal_chang_charm_shatter_v85.png", "label": "Chang shatter", "max_size": 54, "frame_offsets": [(-8, 0), (-4, 0), (0, 0), (4, 0), (7, 1), (10, 2)], "frame_scales": [0.48, 0.70, 0.94, 1.0, 0.74, 0.50]},
        ],
    },
    "v86a": {
        "run_dir": WORKSPACE / "run" / "vfx-v86",
        "reference": "imagegen_reference_v86a.png",
        "contact": "personal_vfx_v86a_contact.png",
        "validation": "personal_vfx_v86a_validation.json",
        "manifest": "personal_vfx_v86a_manifest.json",
        "scope": "Batch 11: action-shaped replacements for remaining support/magic stamp-like personal VFX. Character sprites are not modified.",
        "effects": [
            {"hero_id": "B08_HUMAN_MUENMONTRA", "key": "muen_mantra_break", "file": "skill_personal_muen_mantra_break_v86.png", "label": "Muen break", "max_size": 54, "frame_offsets": [(-9, 0), (-5, 0), (-1, 0), (3, 0), (7, 0), (10, 1)], "frame_scales": [0.48, 0.70, 0.94, 1.0, 0.76, 0.52]},
            {"hero_id": "B09_SPIRIT_AMBERNIGHT", "key": "ambernight_shadow_claw", "file": "skill_personal_ambernight_shadow_claw_v86.png", "label": "Amber claw", "max_size": 54, "frame_offsets": [(-7, 2), (-3, 1), (0, 0), (3, 1), (6, 2), (8, 4)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.74, 0.50]},
            {"hero_id": "B10_MERFOLK_MUKWAREE", "key": "mukwaree_pearl_splash", "file": "skill_personal_mukwaree_pearl_splash_v86.png", "label": "Muk splash", "max_size": 54, "frame_offsets": [(-9, 2), (-5, 1), (-1, 0), (3, 0), (7, 1), (10, 2)], "frame_scales": [0.48, 0.70, 0.94, 1.0, 0.76, 0.52]},
            {"hero_id": "C04_HUMAN_CHABA", "key": "chaba_petal_burst", "file": "skill_personal_chaba_petal_burst_v86.png", "label": "Chaba burst", "max_size": 52, "frame_offsets": [(-6, 1), (-3, 1), (0, 0), (3, 1), (6, 2), (8, 3)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.74, 0.50]},
            {"hero_id": "C08_CROCODILE_KUMPHIL", "key": "kumphil_jaw_sweep", "file": "skill_personal_kumphil_jaw_sweep_v86.png", "label": "Kumphil sweep", "max_size": 56, "frame_offsets": [(-8, 3), (-4, 2), (0, 0), (3, 1), (6, 2), (9, 3)], "frame_scales": [0.46, 0.70, 0.96, 1.0, 0.74, 0.50]},
        ],
    },
    "v87a": {
        "run_dir": WORKSPACE / "run" / "vfx-v87",
        "reference": "imagegen_reference_v87a.png",
        "contact": "personal_vfx_v87a_contact.png",
        "validation": "personal_vfx_v87a_validation.json",
        "manifest": "personal_vfx_v87a_manifest.json",
        "scope": "Batch 12: replacements for icon-like/status-like personal VFX plus one weak stone impact. Character sprites are not modified.",
        "effects": [
            {"hero_id": "A05_MAKARA_MAKORNKRAM", "key": "makara_scale_crash", "file": "skill_personal_makara_scale_crash_v87.png", "label": "Makara crash", "max_size": 56, "frame_offsets": [(-9, 2), (-5, 1), (-1, 0), (3, 0), (7, 1), (10, 2)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.78, 0.54]},
            {"hero_id": "A06_SPIRIT_RAMPAN_MASK", "key": "rampan_mask_shatter", "file": "skill_personal_rampan_mask_shatter_v87.png", "label": "Rampan shatter", "max_size": 56, "frame_offsets": [(-9, 1), (-5, 0), (-1, 0), (3, 0), (7, 1), (10, 2)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.78, 0.54]},
            {"hero_id": "B05_KINNARA_RAVIKAN", "key": "ravikan_feather_song_slash", "file": "skill_personal_ravikan_feather_song_slash_v87.png", "label": "Ravikan slash", "max_size": 56, "frame_offsets": [(-8, 2), (-4, 1), (0, 0), (4, -1), (8, -1), (10, 0)], "frame_scales": [0.46, 0.70, 0.96, 1.0, 0.76, 0.52]},
            {"hero_id": "C09_KINNARI_KAEWKANGSADAN", "key": "kaew_crystal_chime_hit", "file": "skill_personal_kaew_crystal_chime_hit_v87.png", "label": "Kaew chime", "max_size": 56, "frame_offsets": [(-5, 4), (-3, 2), (0, 0), (2, 1), (4, 2), (6, 4)], "frame_scales": [0.46, 0.72, 1.0, 0.94, 0.72, 0.50]},
            {"hero_id": "D02_HUMAN_KHAMPAN", "key": "khampan_bronze_bash", "file": "skill_personal_khampan_bronze_bash_v87.png", "label": "Khampan bash", "max_size": 56, "frame_offsets": [(-5, 4), (-2, 2), (0, 0), (3, 1), (6, 3), (8, 5)], "frame_scales": [0.46, 0.70, 0.96, 1.0, 0.74, 0.50]},
            {"hero_id": "C02_KHACHASIH_LOHDIN", "key": "lohdin_stone_bulwark_hit", "file": "skill_personal_lohdin_stone_bulwark_hit_v87.png", "label": "Lohdin stone hit", "max_size": 56, "frame_offsets": [(-4, 5), (-2, 2), (0, 0), (2, 1), (4, 3), (6, 5)], "frame_scales": [0.46, 0.72, 1.0, 0.92, 0.68, 0.48]},
        ],
    },
    "v88a": {
        "run_dir": WORKSPACE / "run" / "vfx-v88",
        "reference": "imagegen_reference_v88a.png",
        "contact": "personal_vfx_v88a_contact.png",
        "validation": "personal_vfx_v88a_validation.json",
        "manifest": "personal_vfx_v88a_manifest.json",
        "scope": "Batch 13: first-priority per-character attack/skill VFX replacements from independent QC. Character sprites are not modified.",
        "source_layout": {"columns": 5, "rows": 2},
        "effects": [
            {"hero_id": "S03_YAKSHA_KRAIASURA", "key": "yaksha_stone_aegis_smash", "file": "skill_personal_yaksha_stone_aegis_smash_v88.png", "label": "Yaksha stone aegis smash", "max_size": 60, "frame_offsets": [(-5, 5), (-2, 2), (0, 0), (2, 1), (4, 3), (6, 5)], "frame_scales": [0.50, 0.74, 1.0, 0.94, 0.72, 0.52]},
            {"hero_id": "S01_GARUDA_VAYUDEJ", "key": "garuda_wind_talon", "file": "skill_personal_garuda_wind_talon_v88.png", "label": "Garuda wind talon", "max_size": 60, "frame_offsets": [(-9, 4), (-5, 2), (-1, 0), (3, -1), (7, -2), (10, -3)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.56]},
            {"hero_id": "S02_NAGA_SASINAKA", "key": "naga_moon_coil_strike", "file": "skill_personal_naga_moon_coil_strike_v88.png", "label": "Naga moon coil strike", "max_size": 60, "frame_offsets": [(-4, 5), (-2, 2), (0, 0), (1, -1), (3, 1), (5, 4)], "frame_scales": [0.50, 0.74, 1.0, 0.96, 0.76, 0.54]},
            {"hero_id": "A02_TIGER_PLOENGPAYAK", "key": "tiger_flame_rend", "file": "skill_personal_tiger_flame_rend_v88.png", "label": "Tiger flame rend", "max_size": 60, "frame_offsets": [(-8, 4), (-4, 2), (0, 0), (4, 1), (8, 2), (10, 4)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
            {"hero_id": "A03_HUMAN_ARUNRAT", "key": "arun_sun_arrow_hit", "file": "skill_personal_arun_sun_arrow_hit_v88.png", "label": "Arun sun arrow hit", "max_size": 60, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.50, 0.72, 0.96, 1.0, 0.78, 0.56]},
            {"hero_id": "A01_KINNARI_PIMPPRUEKSA", "key": "kinnari_lotus_feather_hit", "file": "skill_personal_kinnari_lotus_feather_hit_v88.png", "label": "Kinnari lotus feather hit", "max_size": 58, "frame_offsets": [(-8, 5), (-4, 2), (0, 0), (4, -1), (8, 1), (10, 3)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
            {"hero_id": "A04_VANARA_KALAVANARA", "key": "vanara_staff_ground_crash", "file": "skill_personal_vanara_staff_ground_crash_v88.png", "label": "Vanara staff ground crash", "max_size": 60, "frame_offsets": [(-4, 6), (-2, 3), (0, 0), (2, 1), (4, 3), (6, 6)], "frame_scales": [0.50, 0.74, 1.0, 0.94, 0.72, 0.52]},
            {"hero_id": "B01_GARUDA_MEKHAVI", "key": "mekhavi_feather_spear_hit", "file": "skill_personal_mekhavi_feather_spear_hit_v88.png", "label": "Mekhavi feather spear hit", "max_size": 60, "frame_offsets": [(-10, 1), (-6, 0), (-2, 0), (3, 0), (7, 0), (10, 1)], "frame_scales": [0.50, 0.72, 0.96, 1.0, 0.78, 0.56]},
            {"hero_id": "B02_NAGA_KLEDKRAM", "key": "kledkram_water_snare_hit", "file": "skill_personal_kledkram_water_snare_hit_v88.png", "label": "Kledkram water snare hit", "max_size": 58, "frame_offsets": [(-4, 6), (-2, 3), (0, 0), (1, -1), (3, 1), (5, 4)], "frame_scales": [0.50, 0.74, 1.0, 0.96, 0.76, 0.54]},
            {"hero_id": "B03_YAKSHA_KHUNPHA", "key": "khunpha_stone_axe_cleave", "file": "skill_personal_khunpha_stone_axe_cleave_v88.png", "label": "Khunpha stone axe cleave", "max_size": 60, "frame_offsets": [(-7, 5), (-3, 2), (0, 0), (4, 1), (8, 3), (10, 5)], "frame_scales": [0.50, 0.74, 1.0, 0.94, 0.72, 0.52]},
        ],
    },
    "v88b": {
        "run_dir": WORKSPACE / "run" / "vfx-v88",
        "reference": "imagegen_reference_v88b.png",
        "contact": "personal_vfx_v88b_contact.png",
        "validation": "personal_vfx_v88b_validation.json",
        "manifest": "personal_vfx_v88b_manifest.json",
        "scope": "Batch 14: A05-A07 and B04-B10 per-character attack/skill VFX replacements. Character sprites are not modified.",
        "source_layout": {"columns": 5, "rows": 2},
        "effects": [
            {"hero_id": "A05_MAKARA_MAKORNKRAM", "key": "makara_scale_crash_guard", "file": "skill_personal_makara_scale_crash_guard_v88.png", "label": "Makara scale crash guard", "max_size": 60, "frame_offsets": [(-5, 5), (-2, 2), (0, 0), (2, 1), (4, 3), (6, 5)], "frame_scales": [0.50, 0.74, 1.0, 0.94, 0.72, 0.52]},
            {"hero_id": "A06_SPIRIT_RAMPAN_MASK", "key": "rampan_mask_shatter", "file": "skill_personal_rampan_mask_shatter_v88.png", "label": "Rampan mask shatter", "max_size": 58, "frame_offsets": [(-8, 3), (-4, 1), (0, 0), (4, -1), (8, 1), (10, 3)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
            {"hero_id": "A07_HUMAN_CHANGJAKKAEW", "key": "chang_charm_bead_shatter", "file": "skill_personal_chang_charm_bead_shatter_v88.png", "label": "Chang charm bead shatter", "max_size": 56, "frame_offsets": [(-10, 1), (-6, 0), (-2, 0), (3, 0), (7, 1), (10, 2)], "frame_scales": [0.50, 0.72, 0.96, 1.0, 0.78, 0.56]},
            {"hero_id": "B04_HUMAN_DARIN", "key": "darin_dagger_seal_cut", "file": "skill_personal_darin_dagger_seal_cut_v88.png", "label": "Darin dagger seal cut", "max_size": 60, "frame_offsets": [(-8, 3), (-4, 1), (0, 0), (4, 1), (8, 2), (10, 4)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
            {"hero_id": "B05_KINNARA_RAVIKAN", "key": "ravikan_feather_song_hit", "file": "skill_personal_ravikan_feather_song_hit_v88.png", "label": "Ravikan feather song hit", "max_size": 58, "frame_offsets": [(-8, 5), (-4, 2), (0, 0), (4, -1), (8, 1), (10, 3)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
            {"hero_id": "B06_BEAST_SINGKHON", "key": "singkhon_roar_fang_hit", "file": "skill_personal_singkhon_roar_fang_hit_v88.png", "label": "Singkhon roar fang hit", "max_size": 60, "frame_offsets": [(-8, 5), (-4, 2), (0, 0), (3, 1), (7, 3), (10, 5)], "frame_scales": [0.50, 0.74, 1.0, 0.96, 0.76, 0.54]},
            {"hero_id": "B07_DRYAD_BUTSABA", "key": "butsaba_thorn_eruption", "file": "skill_personal_butsaba_thorn_eruption_v88.png", "label": "Butsaba thorn eruption", "max_size": 58, "frame_offsets": [(-4, 6), (-2, 3), (0, 0), (1, -1), (3, 1), (5, 4)], "frame_scales": [0.50, 0.74, 1.0, 0.96, 0.76, 0.54]},
            {"hero_id": "B08_HUMAN_MUENMONTRA", "key": "muen_mantra_tear", "file": "skill_personal_muen_mantra_tear_v88.png", "label": "Muen mantra tear", "max_size": 58, "frame_offsets": [(-8, 4), (-4, 2), (0, 0), (4, 1), (8, 2), (10, 4)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
            {"hero_id": "B09_SPIRIT_AMBERNIGHT", "key": "ambernight_shadow_claw", "file": "skill_personal_ambernight_shadow_claw_v88.png", "label": "Ambernight shadow claw", "max_size": 60, "frame_offsets": [(-8, 4), (-4, 2), (0, 0), (4, 1), (8, 2), (10, 4)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
            {"hero_id": "B10_MERFOLK_MUKWAREE", "key": "mukwaree_pearl_splash", "file": "skill_personal_mukwaree_pearl_splash_v88.png", "label": "Mukwaree pearl splash", "max_size": 58, "frame_offsets": [(-4, 6), (-2, 3), (0, 0), (2, 1), (4, 3), (6, 5)], "frame_scales": [0.50, 0.74, 1.0, 0.96, 0.76, 0.54]},
        ],
    },
    "v88c": {
        "run_dir": WORKSPACE / "run" / "vfx-v88",
        "reference": "imagegen_reference_v88c.png",
        "contact": "personal_vfx_v88c_contact.png",
        "validation": "personal_vfx_v88c_validation.json",
        "manifest": "personal_vfx_v88c_manifest.json",
        "scope": "Batch 15: C01-C10 per-character attack/skill VFX replacements. Character sprites are not modified.",
        "source_layout": {"columns": 5, "rows": 2},
        "effects": [
            {"hero_id": "C01_HUMAN_JETSIAM", "key": "jetsiam_krabi_slash", "file": "skill_personal_jetsiam_krabi_slash_v88.png", "label": "Jetsiam krabi slash", "max_size": 60, "frame_offsets": [(-8, 4), (-4, 2), (0, 0), (4, 1), (8, 2), (10, 4)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
            {"hero_id": "C02_KHACHASIH_LOHDIN", "key": "lohdin_bulwark_slam", "file": "skill_personal_lohdin_bulwark_slam_v88.png", "label": "Lohdin bulwark slam", "max_size": 60, "frame_offsets": [(-4, 6), (-2, 3), (0, 0), (2, 1), (4, 3), (6, 6)], "frame_scales": [0.50, 0.74, 1.0, 0.94, 0.72, 0.52]},
            {"hero_id": "C03_HUMAN_PANA", "key": "pana_leaf_arrow_hit", "file": "skill_personal_pana_leaf_arrow_hit_v88.png", "label": "Pana leaf arrow hit", "max_size": 58, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.50, 0.72, 0.96, 1.0, 0.78, 0.56]},
            {"hero_id": "C04_HUMAN_CHABA", "key": "chaba_hibiscus_burst", "file": "skill_personal_chaba_hibiscus_burst_v88.png", "label": "Chaba hibiscus burst", "max_size": 58, "frame_offsets": [(-7, 5), (-3, 2), (0, 0), (4, 1), (8, 2), (10, 4)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
            {"hero_id": "C05_VANARA_JORJAN", "key": "jorjan_blade_slice", "file": "skill_personal_jorjan_blade_slice_v88.png", "label": "Jorjan blade slice", "max_size": 60, "frame_offsets": [(-8, 3), (-4, 1), (0, 0), (4, 1), (8, 2), (10, 4)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
            {"hero_id": "C06_NAGA_NILNATEE", "key": "nilnatee_water_rope_snap", "file": "skill_personal_nilnatee_water_rope_snap_v88.png", "label": "Nilnatee water rope snap", "max_size": 58, "frame_offsets": [(-4, 6), (-2, 3), (0, 0), (1, -1), (3, 1), (5, 4)], "frame_scales": [0.50, 0.74, 1.0, 0.96, 0.76, 0.54]},
            {"hero_id": "C07_GARUDA_PEEKTHONG", "key": "peekthong_feather_dart", "file": "skill_personal_peekthong_feather_dart_v88.png", "label": "Peekthong feather dart", "max_size": 58, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.50, 0.72, 0.96, 1.0, 0.78, 0.56]},
            {"hero_id": "C08_CROCODILE_KUMPHIL", "key": "kumphil_jaw_sweep", "file": "skill_personal_kumphil_jaw_sweep_v88.png", "label": "Kumphil jaw sweep", "max_size": 60, "frame_offsets": [(-8, 5), (-4, 2), (0, 0), (3, 1), (7, 3), (10, 5)], "frame_scales": [0.50, 0.74, 1.0, 0.96, 0.76, 0.54]},
            {"hero_id": "C09_KINNARI_KAEWKANGSADAN", "key": "kaew_crystal_chime", "file": "skill_personal_kaew_crystal_chime_v88.png", "label": "Kaew crystal chime", "max_size": 58, "frame_offsets": [(-5, 5), (-2, 2), (0, 0), (2, 1), (4, 3), (6, 5)], "frame_scales": [0.50, 0.74, 1.0, 0.94, 0.72, 0.52]},
            {"hero_id": "C10_SPIRIT_KHOMKHAM", "key": "khomkham_soul_flame", "file": "skill_personal_khomkham_soul_flame_v88.png", "label": "Khomkham soul flame", "max_size": 58, "frame_offsets": [(-8, 4), (-4, 2), (0, 0), (4, 1), (8, 2), (10, 4)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
        ],
    },
    "v88d": {
        "run_dir": WORKSPACE / "run" / "vfx-v88",
        "reference": "imagegen_reference_v88d.png",
        "contact": "personal_vfx_v88d_contact.png",
        "validation": "personal_vfx_v88d_validation.json",
        "manifest": "personal_vfx_v88d_manifest.json",
        "scope": "Batch 16: D01-D10 per-character attack/skill VFX replacements. Character sprites are not modified.",
        "source_layout": {"columns": 5, "rows": 2},
        "effects": [
            {"hero_id": "D01_HUMAN_PHAIKLA", "key": "phaikla_fist_blow", "file": "skill_personal_phaikla_fist_blow_v88.png", "label": "Phaikla fist blow", "max_size": 58, "frame_offsets": [(-5, 5), (-2, 2), (0, 0), (2, 1), (4, 3), (6, 5)], "frame_scales": [0.50, 0.74, 1.0, 0.94, 0.72, 0.52]},
            {"hero_id": "D02_HUMAN_KHAMPAN", "key": "khampan_bronze_guard_bash", "file": "skill_personal_khampan_bronze_guard_bash_v88.png", "label": "Khampan bronze guard bash", "max_size": 60, "frame_offsets": [(-5, 5), (-2, 2), (0, 0), (2, 1), (4, 3), (6, 5)], "frame_scales": [0.50, 0.74, 1.0, 0.94, 0.72, 0.52]},
            {"hero_id": "D03_HUMAN_PRANNOI", "key": "prannoi_wood_arrow_splinter", "file": "skill_personal_prannoi_wood_arrow_splinter_v88.png", "label": "Prannoi wood arrow splinter", "max_size": 58, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.50, 0.72, 0.96, 1.0, 0.78, 0.56]},
            {"hero_id": "D04_HUMAN_TAEMTHONG", "key": "taem_gold_thread_cross", "file": "skill_personal_taem_gold_thread_cross_v88.png", "label": "Taem gold thread cross", "max_size": 56, "frame_offsets": [(-6, 3), (-3, 1), (0, 0), (3, 0), (6, 1), (9, 3)], "frame_scales": [0.50, 0.72, 0.96, 1.0, 0.78, 0.56]},
            {"hero_id": "D05_VANARA_JUKJIK", "key": "jukjik_claw_cut", "file": "skill_personal_jukjik_claw_cut_v88.png", "label": "Jukjik claw cut", "max_size": 60, "frame_offsets": [(-8, 4), (-4, 2), (0, 0), (4, 1), (8, 2), (10, 4)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
            {"hero_id": "D06_NAGA_BUABUCHA", "key": "buabucha_lotus_root_bind", "file": "skill_personal_buabucha_lotus_root_bind_v88.png", "label": "Buabucha lotus root bind", "max_size": 58, "frame_offsets": [(-4, 6), (-2, 3), (0, 0), (1, -1), (3, 1), (5, 4)], "frame_scales": [0.50, 0.74, 1.0, 0.96, 0.76, 0.54]},
            {"hero_id": "D07_GARUDA_LOMPEEK", "key": "lompeek_wind_dart", "file": "skill_personal_lompeek_wind_dart_v88.png", "label": "Lompeek wind dart", "max_size": 58, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.50, 0.72, 0.96, 1.0, 0.78, 0.56]},
            {"hero_id": "D08_HUMAN_THIWA", "key": "thiwa_dusk_talisman_break", "file": "skill_personal_thiwa_dusk_talisman_break_v88.png", "label": "Thiwa dusk talisman break", "max_size": 58, "frame_offsets": [(-8, 4), (-4, 2), (0, 0), (4, 1), (8, 2), (10, 4)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
            {"hero_id": "D09_CONSTRUCT_SILADIN", "key": "siladin_stone_fist_slam", "file": "skill_personal_siladin_stone_fist_slam_v88.png", "label": "Siladin stone fist slam", "max_size": 60, "frame_offsets": [(-5, 6), (-2, 3), (0, 0), (2, 1), (4, 3), (6, 6)], "frame_scales": [0.50, 0.74, 1.0, 0.94, 0.72, 0.52]},
            {"hero_id": "D10_SPIRIT_OUNRUEN", "key": "ounruen_wisp_dash", "file": "skill_personal_ounruen_wisp_dash_v88.png", "label": "Ounruen wisp dash", "max_size": 58, "frame_offsets": [(-10, 1), (-6, 0), (-2, 0), (3, 0), (7, 1), (10, 2)], "frame_scales": [0.50, 0.72, 0.96, 1.0, 0.78, 0.56]},
        ],
    },
    "v89a": {
        "run_dir": WORKSPACE / "run" / "vfx-v89",
        "reference": "imagegen_reference_v89a.png",
        "contact": "personal_vfx_v89a_contact.png",
        "validation": "personal_vfx_v89a_validation.json",
        "manifest": "personal_vfx_v89a_manifest.json",
        "scope": "Batch 17: focused V89 replacements for 12 V88 effects with weak per-character uniqueness. Character sprites are not modified.",
        "source_layout": {"columns": 6, "rows": 2},
        "effects": [
            {"hero_id": "A02_TIGER_PLOENGPAYAK", "key": "tiger_head_bite_gouge", "file": "skill_personal_tiger_head_bite_gouge_v89.png", "label": "Tiger head bite gouge", "max_size": 60, "frame_offsets": [(-8, 4), (-4, 2), (0, 0), (4, 1), (8, 2), (10, 4)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
            {"hero_id": "D05_VANARA_JUKJIK", "key": "jukjik_monkey_paw_slap", "file": "skill_personal_jukjik_monkey_paw_slap_v89.png", "label": "Jukjik monkey paw slap", "max_size": 58, "frame_offsets": [(-4, 5), (-2, 2), (0, 0), (2, 1), (4, 3), (6, 5)], "frame_scales": [0.50, 0.74, 1.0, 0.94, 0.72, 0.52]},
            {"hero_id": "S01_GARUDA_VAYUDEJ", "key": "garuda_wing_v_beak", "file": "skill_personal_garuda_wing_v_beak_v89.png", "label": "Garuda wing V beak", "max_size": 60, "frame_offsets": [(0, 5), (0, 2), (0, 0), (0, -1), (0, 1), (0, 4)], "frame_scales": [0.50, 0.74, 1.0, 0.96, 0.76, 0.54]},
            {"hero_id": "B01_GARUDA_MEKHAVI", "key": "mekhavi_wind_spear_lance", "file": "skill_personal_mekhavi_wind_spear_lance_v89.png", "label": "Mekhavi wind spear lance", "max_size": 60, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.50, 0.72, 0.96, 1.0, 0.78, 0.56]},
            {"hero_id": "B05_KINNARA_RAVIKAN", "key": "ravikan_music_wave", "file": "skill_personal_ravikan_music_wave_v89.png", "label": "Ravikan music wave", "max_size": 60, "frame_offsets": [(-8, 4), (-4, 2), (0, 0), (4, -1), (8, 1), (10, 3)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
            {"hero_id": "C07_GARUDA_PEEKTHONG", "key": "peekthong_tri_feather_darts", "file": "skill_personal_peekthong_tri_feather_darts_v89.png", "label": "Peekthong tri feather darts", "max_size": 58, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.50, 0.72, 0.96, 1.0, 0.78, 0.56]},
            {"hero_id": "D07_GARUDA_LOMPEEK", "key": "lompeek_tornado_dart", "file": "skill_personal_lompeek_tornado_dart_v89.png", "label": "Lompeek tornado dart", "max_size": 58, "frame_offsets": [(-5, 5), (-2, 2), (0, 0), (2, 1), (4, 3), (6, 5)], "frame_scales": [0.50, 0.74, 1.0, 0.94, 0.72, 0.52]},
            {"hero_id": "A04_VANARA_KALAVANARA", "key": "kalavanara_staff_pole_crash", "file": "skill_personal_kalavanara_staff_pole_crash_v89.png", "label": "Kalavanara staff pole crash", "max_size": 60, "frame_offsets": [(-4, 6), (-2, 3), (0, 0), (2, 1), (4, 3), (6, 6)], "frame_scales": [0.50, 0.74, 1.0, 0.94, 0.72, 0.52]},
            {"hero_id": "B03_YAKSHA_KHUNPHA", "key": "khunpha_stone_axe_embed", "file": "skill_personal_khunpha_stone_axe_embed_v89.png", "label": "Khunpha stone axe embed", "max_size": 60, "frame_offsets": [(-4, 6), (-2, 3), (0, 0), (2, 1), (4, 3), (6, 6)], "frame_scales": [0.50, 0.74, 1.0, 0.94, 0.72, 0.52]},
            {"hero_id": "D02_HUMAN_KHAMPAN", "key": "khampan_pot_lid_bash", "file": "skill_personal_khampan_pot_lid_bash_v89.png", "label": "Khampan pot lid bash", "max_size": 58, "frame_offsets": [(-8, 4), (-4, 2), (0, 0), (4, 1), (8, 2), (10, 4)], "frame_scales": [0.50, 0.72, 0.98, 1.0, 0.78, 0.54]},
            {"hero_id": "D03_HUMAN_PRANNOI", "key": "prannoi_bow_splinter", "file": "skill_personal_prannoi_bow_splinter_v89.png", "label": "Prannoi bow splinter", "max_size": 58, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.50, 0.72, 0.96, 1.0, 0.78, 0.56]},
            {"hero_id": "C01_HUMAN_JETSIAM", "key": "jetsiam_krabi_thrust", "file": "skill_personal_jetsiam_krabi_thrust_v89.png", "label": "Jetsiam krabi thrust", "max_size": 60, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.50, 0.72, 0.96, 1.0, 0.78, 0.56]},
        ],
    },
    "v90a": {
        "run_dir": WORKSPACE / "run" / "vfx-v90",
        "reference": "imagegen_reference_v90a.png",
        "contact": "personal_vfx_v90a_contact.png",
        "validation": "personal_vfx_v90a_validation.json",
        "manifest": "personal_vfx_v90a_manifest.json",
        "scope": "Batch 18: V90 replacements for eight family-overlap personal attack/skill VFX. Character sprites are not modified.",
        "source_layout": {"columns": 4, "rows": 2},
        "effects": [
            {"hero_id": "C07_GARUDA_PEEKTHONG", "key": "peekthong_peacock_dart_cluster", "file": "skill_personal_peekthong_peacock_dart_cluster_v90.png", "label": "Peekthong peacock dart cluster", "max_size": 58, "frame_offsets": [(-9, 0), (-5, 0), (-1, 0), (3, 0), (7, 1), (10, 2)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.78, 0.54]},
            {"hero_id": "B01_GARUDA_MEKHAVI", "key": "mekhavi_ringed_wind_spear", "file": "skill_personal_mekhavi_ringed_wind_spear_v90.png", "label": "Mekhavi ringed wind spear", "max_size": 60, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 0), (10, 0)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.78, 0.54]},
            {"hero_id": "S01_GARUDA_VAYUDEJ", "key": "vayudej_garuda_beak_dive", "file": "skill_personal_vayudej_garuda_beak_dive_v90.png", "label": "Vayudej garuda beak dive", "max_size": 60, "frame_offsets": [(0, 5), (0, 2), (0, 0), (0, -1), (0, 1), (0, 4)], "frame_scales": [0.48, 0.72, 1.0, 0.96, 0.76, 0.54]},
            {"hero_id": "D03_HUMAN_PRANNOI", "key": "prannoi_bow_arc_snap", "file": "skill_personal_prannoi_bow_arc_snap_v90.png", "label": "Prannoi bow arc snap", "max_size": 58, "frame_offsets": [(-9, 0), (-5, 0), (-1, 0), (3, 1), (7, 2), (10, 3)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.78, 0.54]},
            {"hero_id": "C01_HUMAN_JETSIAM", "key": "jetsiam_krabi_guard_thrust", "file": "skill_personal_jetsiam_krabi_guard_thrust_v90.png", "label": "Jetsiam krabi guard thrust", "max_size": 60, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 0), (10, 1)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.78, 0.54]},
            {"hero_id": "B03_YAKSHA_KHUNPHA", "key": "khunpha_yaksha_axe_stamp", "file": "skill_personal_khunpha_yaksha_axe_stamp_v90.png", "label": "Khunpha yaksha axe stamp", "max_size": 60, "frame_offsets": [(-4, 6), (-2, 3), (0, 0), (2, 1), (4, 3), (6, 6)], "frame_scales": [0.48, 0.72, 1.0, 0.94, 0.72, 0.52]},
            {"hero_id": "A04_VANARA_KALAVANARA", "key": "kalavanara_staff_vault_smash", "file": "skill_personal_kalavanara_staff_vault_smash_v90.png", "label": "Kalavanara staff vault smash", "max_size": 60, "frame_offsets": [(-5, 6), (-2, 3), (0, 0), (2, 1), (4, 3), (6, 6)], "frame_scales": [0.48, 0.72, 1.0, 0.94, 0.72, 0.52]},
            {"hero_id": "A03_HUMAN_ARUNRAT", "key": "arunrat_sun_chakra_arrow", "file": "skill_personal_arunrat_sun_chakra_arrow_v90.png", "label": "Arunrat sun chakra arrow", "max_size": 58, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 0), (10, 1)], "frame_scales": [0.48, 0.70, 0.96, 1.0, 0.78, 0.54]},
        ],
    },
    "v91a": {
        "run_dir": WORKSPACE / "run" / "vfx-v91",
        "reference": "imagegen_reference_v91a.png",
        "contact": "personal_vfx_v91a_contact.png",
        "validation": "personal_vfx_v91a_validation.json",
        "manifest": "personal_vfx_v91a_manifest.json",
        "scope": "Batch 19: V91 replacements for five V90 effects still below final combat readability. Character sprites are not modified.",
        "source_layout": {"columns": 5, "rows": 1},
        "effects": [
            {"hero_id": "S01_GARUDA_VAYUDEJ", "key": "vayudej_beak_slash_dive", "file": "skill_personal_vayudej_beak_slash_dive_v91.png", "label": "Vayudej beak slash dive", "max_size": 54, "frame_offsets": [(-8, 4), (-4, 2), (0, 0), (4, 1), (8, 2), (10, 4)], "frame_scales": [0.46, 0.68, 0.96, 1.0, 0.76, 0.52]},
            {"hero_id": "B03_YAKSHA_KHUNPHA", "key": "khunpha_diagonal_axe_chop", "file": "skill_personal_khunpha_diagonal_axe_chop_v91.png", "label": "Khunpha diagonal axe chop", "max_size": 58, "frame_offsets": [(-5, 6), (-2, 3), (0, 0), (3, 1), (6, 3), (8, 6)], "frame_scales": [0.46, 0.70, 0.98, 1.0, 0.76, 0.52]},
            {"hero_id": "A04_VANARA_KALAVANARA", "key": "kalavanara_staff_sweep_smash", "file": "skill_personal_kalavanara_staff_sweep_smash_v91.png", "label": "Kalavanara staff sweep smash", "max_size": 58, "frame_offsets": [(-7, 5), (-3, 2), (0, 0), (3, 1), (6, 3), (8, 5)], "frame_scales": [0.46, 0.70, 0.98, 1.0, 0.76, 0.52]},
            {"hero_id": "A03_HUMAN_ARUNRAT", "key": "arunrat_slim_sun_arrow", "file": "skill_personal_arunrat_slim_sun_arrow_v91.png", "label": "Arunrat slim sun arrow", "max_size": 54, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 0), (10, 1)], "frame_scales": [0.46, 0.68, 0.94, 1.0, 0.76, 0.52]},
            {"hero_id": "D03_HUMAN_PRANNOI", "key": "prannoi_bowstring_arrow_snap", "file": "skill_personal_prannoi_bowstring_arrow_snap_v91.png", "label": "Prannoi bowstring arrow snap", "max_size": 54, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 1), (10, 2)], "frame_scales": [0.46, 0.68, 0.94, 1.0, 0.76, 0.52]},
        ],
    },
    "v92a": {
        "run_dir": WORKSPACE / "run" / "vfx-v92",
        "reference": "imagegen_reference_v92a.png",
        "contact": "personal_vfx_v92a_contact.png",
        "validation": "personal_vfx_v92a_validation.json",
        "manifest": "personal_vfx_v92a_manifest.json",
        "scope": "Batch 20: V92 readability polish for A03 and D03 arrow effects. Character sprites are not modified.",
        "source_layout": {"columns": 2, "rows": 1},
        "effects": [
            {"hero_id": "A03_HUMAN_ARUNRAT", "key": "arunrat_clean_sun_arrow", "file": "skill_personal_arunrat_clean_sun_arrow_v92.png", "label": "Arunrat clean sun arrow", "max_size": 52, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 0), (10, 1)], "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.74, 0.50]},
            {"hero_id": "D03_HUMAN_PRANNOI", "key": "prannoi_bright_arrow_release", "file": "skill_personal_prannoi_bright_arrow_release_v92.png", "label": "Prannoi bright arrow release", "max_size": 54, "frame_offsets": [(-10, 0), (-6, 0), (-2, 0), (3, 0), (7, 1), (10, 2)], "frame_scales": [0.44, 0.66, 0.92, 1.0, 0.74, 0.50]},
        ],
    },
}


def is_key(r: int, g: int, b: int) -> bool:
    return r > 220 and g < 60 and b > 220


def is_chroma_residue(r: int, g: int, b: int) -> bool:
    if is_key(r, g, b):
        return True
    if r < 130 or b < 125 or g > 125:
        return False
    return (r + b) > (g * 3 + 130) and abs(r - b) < 95


def object_segments(source: Image.Image) -> list[tuple[int, int, int, int]]:
    rgba = source.convert("RGBA")
    w, h = rgba.size
    pixels = rgba.load()
    col_has_subject: list[bool] = []
    for x in range(w):
        found = False
        for y in range(h):
            r, g, b, a = pixels[x, y]
            if a > 0 and not is_key(r, g, b):
                found = True
                break
        col_has_subject.append(found)

    groups: list[tuple[int, int]] = []
    start = -1
    last = -1
    min_gap = max(16, w // 80)
    gap = 0
    for x, has in enumerate(col_has_subject):
        if has:
            if start < 0:
                start = x
            last = x
            gap = 0
        elif start >= 0:
            gap += 1
            if gap >= min_gap:
                groups.append((start, last))
                start = -1
                last = -1
                gap = 0
    if start >= 0:
        groups.append((start, last))

    boxes: list[tuple[int, int, int, int]] = []
    for x0, x1 in groups:
        y0 = h
        y1 = 0
        for x in range(x0, x1 + 1):
            for y in range(h):
                r, g, b, a = pixels[x, y]
                if a > 0 and not is_key(r, g, b):
                    y0 = min(y0, y)
                    y1 = max(y1, y)
        if y0 < y1:
            pad = 6
            boxes.append((max(0, x0 - pad), max(0, y0 - pad), min(w, x1 + pad + 1), min(h, y1 + pad + 1)))
    return boxes


def grid_boxes(source: Image.Image, columns: int, rows: int) -> list[tuple[int, int, int, int]]:
    w, h = source.size
    boxes: list[tuple[int, int, int, int]] = []
    for row in range(rows):
        for column in range(columns):
            x0 = int(round(column * w / columns))
            x1 = int(round((column + 1) * w / columns))
            y0 = int(round(row * h / rows))
            y1 = int(round((row + 1) * h / rows))
            boxes.append((x0, y0, x1, y1))
    return boxes


def crop_to_alpha(source: Image.Image, box: tuple[int, int, int, int]) -> Image.Image:
    crop = source.convert("RGBA").crop(box)
    pixels = crop.load()
    for y in range(crop.height):
        for x in range(crop.width):
            r, g, b, a = pixels[x, y]
            if a == 0 or is_chroma_residue(r, g, b):
                pixels[x, y] = (0, 0, 0, 0)
            else:
                pixels[x, y] = (r, g, b, 255)
    return crop


def quantize_subject(image: Image.Image, colors: int = 56) -> Image.Image:
    rgba = image.convert("RGBA")
    alpha = rgba.getchannel("A")
    rgb = Image.new("RGB", rgba.size, (0, 0, 0))
    rgb.paste(rgba.convert("RGB"), mask=alpha)
    pal = rgb.quantize(colors=colors, method=Image.Quantize.MEDIANCUT)
    out = pal.convert("RGBA")
    out.putalpha(alpha.point(lambda a: 255 if a >= 128 else 0))
    pixels = out.load()
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = pixels[x, y]
            if a > 0 and is_chroma_residue(r, g, b):
                pixels[x, y] = (0, 0, 0, 0)
    return out


def resize_subject(subject: Image.Image, max_size: int, scale: float) -> Image.Image:
    bbox = subject.getbbox()
    if bbox is None:
        return Image.new("RGBA", (1, 1), (0, 0, 0, 0))
    trimmed = subject.crop(bbox)
    ratio = min(max_size / max(trimmed.width, 1), max_size / max(trimmed.height, 1)) * scale
    width = max(1, min(CELL - 8, int(round(trimmed.width * ratio))))
    height = max(1, min(CELL - 8, int(round(trimmed.height * ratio))))
    return trimmed.resize((width, height), Image.Resampling.NEAREST)


def compose_strip(subject: Image.Image, spec: dict[str, object]) -> Image.Image:
    strip = Image.new("RGBA", (CELL * FRAMES, CELL), (0, 0, 0, 0))
    max_size = int(spec["max_size"])
    frame_scales = list(spec["frame_scales"])
    frame_offsets = list(spec["frame_offsets"])
    for frame in range(FRAMES):
        cell = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
        resized = resize_subject(subject, max_size, float(frame_scales[frame]))
        ox, oy = frame_offsets[frame]
        x = (CELL - resized.width) // 2 + int(ox)
        y = (CELL - resized.height) // 2 + int(oy)
        x = max(4, min(CELL - resized.width - 4, x))
        y = max(4, min(CELL - resized.height - 4, y))
        cell.alpha_composite(resized, (x, y))
        strip.alpha_composite(cell, (frame * CELL, 0))
    return quantize_subject(strip, 56)


def validate_png(path: Path, frames: int = FRAMES) -> dict[str, object]:
    image = Image.open(path).convert("RGBA")
    w, h = image.size
    pixels = image.load()
    edge = 0
    chroma = 0
    magenta_residue = 0
    semi = 0
    colors: set[tuple[int, int, int]] = set()
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if a:
                colors.add((r, g, b))
            if a > 0 and (x < 4 or y < 4 or x >= w - 4 or y >= h - 4):
                edge += 1
            if (r, g, b) == KEY and a > 0:
                chroma += 1
            if a > 0 and is_chroma_residue(r, g, b):
                magenta_residue += 1
            if 0 < a < 255:
                semi += 1
    return {
        "path": str(path),
        "dimensions": [w, h],
        "frames": frames,
        "valid_dimensions": w == CELL * frames and h == CELL,
        "edge_visible_4px": edge,
        "chroma_pixels": chroma,
        "magenta_residue_pixels": magenta_residue,
        "semi_alpha_pixels": semi,
        "palette_rgb_colors": len(colors),
        "pass": w == CELL * frames and h == CELL and edge == 0 and chroma == 0 and magenta_residue == 0 and semi == 0 and len(colors) <= 64,
    }


def make_contact(entries: list[tuple[dict[str, object], Path]], out_path: Path) -> None:
    scale = 4
    label_h = 22
    row_h = CELL * scale + label_h + 10
    width = CELL * FRAMES * scale + 18
    height = row_h * len(entries) + 8
    sheet = Image.new("RGB", (width, height), (4, 13, 13))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    for idx, (spec, path) in enumerate(entries):
        y = 8 + idx * row_h
        label = f"{spec['hero_id']}  {spec['label']}  6x64"
        draw.text((8, y), label, fill=(255, 211, 88), font=font)
        strip = Image.open(path).convert("RGBA")
        preview = Image.new("RGBA", strip.size, (18, 28, 30, 255))
        preview.alpha_composite(strip)
        preview = preview.resize((strip.width * scale, strip.height * scale), Image.Resampling.NEAREST)
        sheet.paste(preview.convert("RGB"), (8, y + label_h))
    sheet.save(out_path)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, help="imagegen reference PNG")
    parser.add_argument("--batch", default="v80", choices=sorted(BATCHES.keys()))
    args = parser.parse_args()

    batch = BATCHES[args.batch]
    run_dir = batch["run_dir"]
    effects = batch["effects"]
    source_path = Path(args.source)
    run_dir.mkdir(parents=True, exist_ok=True)
    ASSET_DIR.mkdir(parents=True, exist_ok=True)
    reference_copy = run_dir / str(batch["reference"])
    shutil.copy2(source_path, reference_copy)

    source = Image.open(source_path).convert("RGBA")
    layout = batch.get("source_layout")
    if layout:
        boxes = grid_boxes(source, int(layout["columns"]), int(layout["rows"]))
    else:
        boxes = object_segments(source)
    if len(boxes) < len(effects):
        raise SystemExit(f"expected at least {len(effects)} VFX concepts, found {len(boxes)}")
    boxes = boxes[: len(effects)]

    validation: list[dict[str, object]] = []
    entries: list[tuple[dict[str, object], Path]] = []
    manifest_entries: list[dict[str, object]] = []
    for spec, box in zip(effects, boxes):
        subject = crop_to_alpha(source, box)
        strip = compose_strip(subject, spec)
        out_path = ASSET_DIR / str(spec["file"])
        strip.save(out_path)
        run_copy = run_dir / str(spec["file"])
        shutil.copy2(out_path, run_copy)
        result = validate_png(out_path)
        validation.append(result)
        entries.append((spec, run_copy))
        manifest_entries.append(
            {
                "hero_id": spec["hero_id"],
                "vfx_key": spec["key"],
                "asset": f"res://assets/vfx/generated/{spec['file']}",
                "source_reference": str(reference_copy),
                "source_crop_box": list(box),
                "generation": "Built-in imagegen concept reference, chroma-key extracted and converted into native 64x64 6-frame pixel strip by tools/build_vfx_v80.py.",
                "validation_pass": bool(result["pass"]),
            }
        )

    contact = run_dir / str(batch["contact"])
    make_contact(entries, contact)
    (run_dir / str(batch["validation"])).write_text(json.dumps(validation, ensure_ascii=False, indent=2), encoding="utf-8")
    manifest = {
        "version": args.batch,
        "date": "2026-06-30",
        "source_imagegen_path": str(source_path),
        "reference_copy": str(reference_copy),
        "scope": str(batch["scope"]),
        "chroma_key": "#ff00ff",
        "cell": CELL,
        "frames": FRAMES,
        "effects": manifest_entries,
    }
    (run_dir / str(batch["manifest"])).write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    if not all(item["pass"] for item in validation):
        raise SystemExit(f"one or more VFX assets failed validation; see {batch['validation']}")
    print(contact)


if __name__ == "__main__":
    main()
