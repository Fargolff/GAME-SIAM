from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

import build_vfx_v80 as base


WORKSPACE = Path(r"C:\Users\ADMIN\Documents\GAME IDLE")
PROJECT = WORKSPACE / "godot" / "game-siam-idle"
ASSET_DIR = PROJECT / "assets" / "vfx" / "generated"
RUN_DIR = WORKSPACE / "run" / "vfx-v104"

HERO_ID = "S01_GARUDA_VAYUDEJ"
ASSET_FILE = "skill_personal_vayudej_garuda_talon_v104.png"
FRAMES = 6
CELL = 64

FRAME_OFFSETS = [(-8, 5), (-5, 2), (0, 0), (5, -1), (8, 1), (10, 3)]
MAX_FRAME_SIZE = [30, 44, 58, 58, 54, 42]


def _cell_crop(source: Image.Image, index: int) -> Image.Image:
    w, h = source.size
    x0 = int(round(index * w / FRAMES))
    x1 = int(round((index + 1) * w / FRAMES))
    return source.crop((x0, 0, x1, h)).convert("RGBA")


def _remove_chroma(image: Image.Image) -> Image.Image:
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if a == 0 or base.is_chroma_residue(r, g, b):
                pixels[x, y] = (0, 0, 0, 0)
            else:
                pixels[x, y] = (r, g, b, 255)
    return image


def _resize_frame(frame: Image.Image, max_size: int) -> Image.Image:
    bbox = frame.getbbox()
    if bbox is None:
        return Image.new("RGBA", (1, 1), (0, 0, 0, 0))
    subject = frame.crop(bbox)
    ratio = min(max_size / max(subject.width, 1), max_size / max(subject.height, 1))
    width = max(1, min(CELL - 10, int(round(subject.width * ratio))))
    height = max(1, min(CELL - 10, int(round(subject.height * ratio))))
    return subject.resize((width, height), Image.Resampling.NEAREST)


def _clean_garuda_palette(image: Image.Image) -> Image.Image:
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            if r > 170 and b > 105 and g < 155:
                # Remove magenta spill/accents from imagegen; S01 should read gold/cyan, not pink.
                brightness = max(r, g, b)
                if brightness > 235:
                    pixels[x, y] = (255, 218, 90, a)
                elif brightness > 200:
                    pixels[x, y] = (237, 159, 54, a)
                else:
                    pixels[x, y] = (159, 91, 36, a)
            elif r > 248 and g > 248 and b > 248:
                pixels[x, y] = (255, 238, 148, a)
    return image


def build(source_path: Path) -> Path:
    RUN_DIR.mkdir(parents=True, exist_ok=True)
    ASSET_DIR.mkdir(parents=True, exist_ok=True)

    reference_copy = RUN_DIR / "imagegen_reference_v104_s01.png"
    shutil.copy2(source_path, reference_copy)

    source = Image.open(source_path).convert("RGBA")
    strip = Image.new("RGBA", (CELL * FRAMES, CELL), (0, 0, 0, 0))
    frame_boxes: list[list[int]] = []

    for frame_index in range(FRAMES):
        frame = _remove_chroma(_cell_crop(source, frame_index))
        if frame_index == FRAMES - 1:
            residue = _remove_chroma(_cell_crop(source, frame_index - 1))
            frame.alpha_composite(residue)
        resized = _resize_frame(frame, MAX_FRAME_SIZE[frame_index])
        ox, oy = FRAME_OFFSETS[frame_index]
        x = (CELL - resized.width) // 2 + ox
        y = (CELL - resized.height) // 2 + oy
        x = max(5, min(CELL - resized.width - 5, x))
        y = max(5, min(CELL - resized.height - 5, y))
        strip.alpha_composite(resized, (frame_index * CELL + x, y))
        frame_boxes.append([x, y, x + resized.width, y + resized.height])

    strip = _clean_garuda_palette(base.quantize_subject(strip, 56))
    out_path = ASSET_DIR / ASSET_FILE
    strip.save(out_path)
    run_copy = RUN_DIR / ASSET_FILE
    shutil.copy2(out_path, run_copy)

    validation = base.validate_png(out_path, FRAMES)
    (RUN_DIR / "personal_vfx_v104_s01_validation.json").write_text(
        json.dumps(validation, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    contact = RUN_DIR / "personal_vfx_v104_s01_contact.png"
    make_contact(run_copy, contact)

    manifest = {
        "version": "v104_s01_pilot",
        "date": "2026-07-01",
        "hero_id": HERO_ID,
        "asset": f"res://assets/vfx/generated/{ASSET_FILE}",
        "source_imagegen_path": str(source_path),
        "reference_copy": str(reference_copy),
        "scope": "Pilot one-character Garuda talon attack/skill VFX. Character sprites are not modified.",
        "method": "Built-in imagegen 6-frame reference strip; each generated frame is chroma-key extracted, resized independently, pixel-snapped, quantized, and packed into native 64x64 frames.",
        "chroma_key": "#ff00ff",
        "cell": CELL,
        "frames": FRAMES,
        "frame_boxes": frame_boxes,
        "validation_pass": bool(validation["pass"]),
    }
    (RUN_DIR / "personal_vfx_v104_s01_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    if not validation["pass"]:
        raise SystemExit("V104 S01 pilot failed validation; see run/vfx-v104/personal_vfx_v104_s01_validation.json")
    return contact


def make_contact(strip_path: Path, out_path: Path) -> None:
    scale = 5
    label_h = 22
    width = CELL * FRAMES * scale + 16
    height = CELL * scale + label_h + 18
    sheet = Image.new("RGB", (width, height), (5, 12, 13))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    draw.text((8, 6), f"{HERO_ID}  V104 pilot Garuda talon  6x64", fill=(255, 210, 86), font=font)
    strip = Image.open(strip_path).convert("RGBA")
    preview = Image.new("RGBA", strip.size, (17, 27, 29, 255))
    preview.alpha_composite(strip)
    preview = preview.resize((strip.width * scale, strip.height * scale), Image.Resampling.NEAREST)
    sheet.paste(preview.convert("RGB"), (8, label_h + 10))
    sheet.save(out_path)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, help="imagegen S01 6-frame reference strip")
    args = parser.parse_args()
    print(build(Path(args.source)))


if __name__ == "__main__":
    main()
