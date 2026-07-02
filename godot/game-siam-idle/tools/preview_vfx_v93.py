from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from build_vfx_v93 import HEROES


WORKSPACE = Path(r"C:\Users\ADMIN\Documents\GAME IDLE")
PROJECT = WORKSPACE / "godot" / "game-siam-idle"
RUN_DIR = WORKSPACE / "run" / "vfx-v93"
CHAR_DIR = PROJECT / "assets" / "characters" / "GameSiam"
VFX_DIR = PROJECT / "assets" / "vfx" / "generated"
OUT_DIR = RUN_DIR / "character_preview_frames_v93"
CELL = 64
FPS = 30
DIRECTIONS = ["south", "south-east", "east", "north-east", "north", "north-west", "west", "south-west"]


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
    draw.text((22, 34), "offline composite: real character skill_01 + generated V93 personal VFX", fill=(176, 202, 190), font=font)
    return canvas


def build_contact() -> Path:
    width, row_h = 1280, 260
    contact = Image.new("RGBA", (width, row_h * len(HEROES)), (2, 10, 11, 255))
    for idx, (hero_id, key, vfx_file, _style) in enumerate(HEROES):
        y0 = idx * row_h
        row = draw_stage(width, row_h, f"{hero_id}  {key}")
        skill_sheet = CHAR_DIR / hero_id / "skill_01-sheet-clean.png"
        vfx_path = VFX_DIR / vfx_file
        for frame in range(6):
            x = 130 + frame * 195
            char = frame_from_sheet(skill_sheet, frame)
            effect = vfx_frame(vfx_path, frame)
            paste_nearest(row, char, (x, 170), 2)
            paste_nearest(row, effect, (x + 96, 150), 2)
        contact.alpha_composite(row, (0, y0))
    out = RUN_DIR / "personal_vfx_40_character_contact_v93.png"
    contact.convert("RGB").save(out)
    return out


def build_movie() -> Path:
    if OUT_DIR.exists():
        shutil.rmtree(OUT_DIR)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    width, height = 1280, 720
    frame_index = 0
    for hero_id, key, vfx_file, _style in HEROES:
        skill_sheet = CHAR_DIR / hero_id / "skill_01-sheet-clean.png"
        vfx_path = VFX_DIR / vfx_file
        duration_frames = 60
        for local in range(duration_frames):
            t = local / FPS
            canvas = draw_stage(width, height, f"{hero_id}  {key}")
            draw = ImageDraw.Draw(canvas)
            char_frame = min(5, int(t * 8.5))
            effect_frame = -1
            if local >= 14:
                effect_frame = min(5, int((local - 14) / 5))
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
    out_movie = RUN_DIR / "personal_vfx_40_character_preview_v93.mp4"
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
