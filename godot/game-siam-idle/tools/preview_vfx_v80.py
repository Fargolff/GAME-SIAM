from __future__ import annotations

import argparse
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


WORKSPACE = Path(r"C:\Users\ADMIN\Documents\GAME IDLE")
PROJECT = WORKSPACE / "godot" / "game-siam-idle"
RUN_DIR = WORKSPACE / "run" / "vfx-v92"
CHAR_DIR = PROJECT / "assets" / "characters" / "GameSiam"
VFX_DIR = PROJECT / "assets" / "vfx" / "generated"
OUT_DIR = RUN_DIR / "character_preview_frames"
CELL = 64
FPS = 30
DIRECTIONS = ["south", "south-east", "east", "north-east", "north", "north-west", "west", "south-west"]
HEROES = [
    ("S03_YAKSHA_KRAIASURA", "KRAI AEGIS", "skill_personal_yaksha_stone_aegis_smash_v88.png"),
    ("S01_GARUDA_VAYUDEJ", "VAYU SLASH", "skill_personal_vayudej_beak_slash_dive_v91.png"),
    ("S02_NAGA_SASINAKA", "SASIN STORM", "skill_personal_naga_moon_coil_strike_v88.png"),
    ("A02_TIGER_PLOENGPAYAK", "PAYAK CUT", "skill_personal_tiger_head_bite_gouge_v89.png"),
    ("A03_HUMAN_ARUNRAT", "ARUN ARROW", "skill_personal_arunrat_clean_sun_arrow_v92.png"),
    ("A01_KINNARI_PIMPPRUEKSA", "PIMP GRACE", "skill_personal_kinnari_lotus_feather_hit_v88.png"),
    ("A04_VANARA_KALAVANARA", "KALA SWEEP", "skill_personal_kalavanara_staff_sweep_smash_v91.png"),
    ("A05_MAKARA_MAKORNKRAM", "MAKORN CRASH", "skill_personal_makara_scale_crash_guard_v88.png"),
    ("A06_SPIRIT_RAMPAN_MASK", "RAMPAN SHATTER", "skill_personal_rampan_mask_shatter_v88.png"),
    ("A07_HUMAN_CHANGJAKKAEW", "CHANG SHATTER", "skill_personal_chang_charm_bead_shatter_v88.png"),
    ("B01_GARUDA_MEKHAVI", "MEKHAVI RING", "skill_personal_mekhavi_ringed_wind_spear_v90.png"),
    ("B02_NAGA_KLEDKRAM", "KLEDKRAM BIND", "skill_personal_kledkram_water_snare_hit_v88.png"),
    ("B03_YAKSHA_KHUNPHA", "KHUNPHA CHOP", "skill_personal_khunpha_diagonal_axe_chop_v91.png"),
    ("B04_HUMAN_DARIN", "DARIN SEAL", "skill_personal_darin_dagger_seal_cut_v88.png"),
    ("B05_KINNARA_RAVIKAN", "RAVIKAN SLASH", "skill_personal_ravikan_music_wave_v89.png"),
    ("B06_BEAST_SINGKHON", "SINGKHON ROAR", "skill_personal_singkhon_roar_fang_hit_v88.png"),
    ("B07_DRYAD_BUTSABA", "BUTSABA CALL", "skill_personal_butsaba_thorn_eruption_v88.png"),
    ("B08_HUMAN_MUENMONTRA", "MUEN BREAK", "skill_personal_muen_mantra_tear_v88.png"),
    ("B09_SPIRIT_AMBERNIGHT", "AMBER CLAW", "skill_personal_ambernight_shadow_claw_v88.png"),
    ("B10_MERFOLK_MUKWAREE", "MUK SPLASH", "skill_personal_mukwaree_pearl_splash_v88.png"),
    ("C01_HUMAN_JETSIAM", "JETSIAM THRUST", "skill_personal_jetsiam_krabi_guard_thrust_v90.png"),
    ("C02_KHACHASIH_LOHDIN", "LOHDIN HIT", "skill_personal_lohdin_bulwark_slam_v88.png"),
    ("C03_HUMAN_PANA", "PANA SHOT", "skill_personal_pana_leaf_arrow_hit_v88.png"),
    ("C04_HUMAN_CHABA", "CHABA BURST", "skill_personal_chaba_hibiscus_burst_v88.png"),
    ("C05_VANARA_JORJAN", "JORJAN CUT", "skill_personal_jorjan_blade_slice_v88.png"),
    ("C06_NAGA_NILNATEE", "NILNATEE BIND", "skill_personal_nilnatee_water_rope_snap_v88.png"),
    ("C07_GARUDA_PEEKTHONG", "PEEKTHONG FAN", "skill_personal_peekthong_peacock_dart_cluster_v90.png"),
    ("C08_CROCODILE_KUMPHIL", "KUMPHIL SWEEP", "skill_personal_kumphil_jaw_sweep_v88.png"),
    ("C09_KINNARI_KAEWKANGSADAN", "KAEW CHIME", "skill_personal_kaew_crystal_chime_v88.png"),
    ("C10_SPIRIT_KHOMKHAM", "KHOMKHAM BURST", "skill_personal_khomkham_soul_flame_v88.png"),
    ("D01_HUMAN_PHAIKLA", "PHAIKLA BLOW", "skill_personal_phaikla_fist_blow_v88.png"),
    ("D02_HUMAN_KHAMPAN", "KHAMPAN BASH", "skill_personal_khampan_pot_lid_bash_v89.png"),
    ("D03_HUMAN_PRANNOI", "PRANNOI SNAP", "skill_personal_prannoi_bright_arrow_release_v92.png"),
    ("D04_HUMAN_TAEMTHONG", "TAEM SLASH", "skill_personal_taem_gold_thread_cross_v88.png"),
    ("D05_VANARA_JUKJIK", "JUKJIK CUT", "skill_personal_jukjik_monkey_paw_slap_v89.png"),
    ("D06_NAGA_BUABUCHA", "BUABUCHA BIND", "skill_personal_buabucha_lotus_root_bind_v88.png"),
    ("D07_GARUDA_LOMPEEK", "LOMPEEK DART", "skill_personal_lompeek_tornado_dart_v89.png"),
    ("D08_HUMAN_THIWA", "THIWA SEAL", "skill_personal_thiwa_dusk_talisman_break_v88.png"),
    ("D09_CONSTRUCT_SILADIN", "SILADIN SLAM", "skill_personal_siladin_stone_fist_slam_v88.png"),
    ("D10_SPIRIT_OUNRUEN", "OUNRUEN DASH", "skill_personal_ounruen_wisp_dash_v88.png"),
]


def frame_from_sheet(path: Path, frame: int, direction: str = "east") -> Image.Image:
    sheet = Image.open(path).convert("RGBA")
    row = DIRECTIONS.index(direction)
    return sheet.crop((frame * CELL, row * CELL, frame * CELL + CELL, row * CELL + CELL))


def vfx_frame(path: Path, frame: int) -> Image.Image:
    strip = Image.open(path).convert("RGBA")
    return strip.crop((frame * CELL, 0, frame * CELL + CELL, CELL))


def paste_nearest(canvas: Image.Image, image: Image.Image, center: tuple[int, int], scale: int) -> None:
    scaled = image.resize((image.width * scale, image.height * scale), Image.Resampling.NEAREST)
    x = center[0] - scaled.width // 2
    y = center[1] - scaled.height // 2
    canvas.alpha_composite(scaled, (x, y))


def draw_stage(width: int, height: int, label: str) -> Image.Image:
    canvas = Image.new("RGBA", (width, height), (4, 14, 15, 255))
    draw = ImageDraw.Draw(canvas)
    font = ImageFont.load_default()
    for y in [116, 154, 192, 230, 268]:
        for x in range(80, width - 80, 34):
            draw.line((x, y, x + 14, y), fill=(126, 93, 38, 150), width=1)
    draw.text((22, 18), label, fill=(255, 216, 92), font=font)
    draw.text((22, 34), "offline composite: real character skill_01 + generated V88-V92 personal VFX", fill=(176, 202, 190), font=font)
    return canvas


def build_contact() -> Path:
    width, row_h = 1280, 260
    contact = Image.new("RGBA", (width, row_h * len(HEROES)), (2, 10, 11, 255))
    for idx, (hero_id, skill_name, vfx_file) in enumerate(HEROES):
        y0 = idx * row_h
        row = draw_stage(width, row_h, f"{hero_id}  {skill_name}")
        skill_sheet = CHAR_DIR / hero_id / "skill_01-sheet-clean.png"
        vfx_path = VFX_DIR / vfx_file
        for frame in range(6):
            x = 130 + frame * 195
            char = frame_from_sheet(skill_sheet, frame)
            effect = vfx_frame(vfx_path, frame)
            paste_nearest(row, char, (x, 170), 2)
            paste_nearest(row, effect, (x + 96, 150), 2)
        contact.alpha_composite(row, (0, y0))
    out = RUN_DIR / "personal_vfx_40_character_contact_v92.png"
    contact.convert("RGB").save(out)
    return out


def build_movie() -> Path:
    if OUT_DIR.exists():
        shutil.rmtree(OUT_DIR)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    width, height = 1280, 720
    frame_index = 0
    for hero_id, skill_name, vfx_file in HEROES:
        skill_sheet = CHAR_DIR / hero_id / "skill_01-sheet-clean.png"
        vfx_path = VFX_DIR / vfx_file
        duration_frames = 60
        for local in range(duration_frames):
            t = local / FPS
            canvas = draw_stage(width, height, f"{hero_id}  {skill_name}")
            draw = ImageDraw.Draw(canvas)
            char_frame = min(5, int(t * 8.5))
            effect_frame = -1
            if local >= 16:
                effect_frame = min(5, int((local - 16) / 5))
            char = frame_from_sheet(skill_sheet, char_frame)
            paste_nearest(canvas, char, (360, 410), 4)
            draw.ellipse((585, 370, 725, 505), outline=(158, 40, 28, 170), width=3)
            draw.line((360, 410, 655, 438), fill=(62, 169, 178, 120), width=2)
            if effect_frame >= 0:
                effect = vfx_frame(vfx_path, effect_frame)
                paste_nearest(canvas, effect, (655, 438), 3)
            out = OUT_DIR / f"frame_{frame_index:05d}.png"
            canvas.convert("RGB").save(out)
            frame_index += 1
    out_movie = RUN_DIR / "personal_vfx_40_character_preview_v92.mp4"
    subprocess.run(
        [
            "ffmpeg",
            "-y",
            "-framerate",
            str(FPS),
            "-i",
            str(OUT_DIR / "frame_%05d.png"),
            "-c:v",
            "libx264",
            "-pix_fmt",
            "yuv420p",
            "-crf",
            "18",
            str(out_movie),
        ],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    return out_movie


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contact-only", action="store_true")
    args = parser.parse_args()
    RUN_DIR.mkdir(parents=True, exist_ok=True)
    contact = build_contact()
    print(contact)
    if not args.contact_only:
        print(build_movie())


if __name__ == "__main__":
    main()
