from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ASSET_DIR = ROOT / "godot/game-siam-idle/assets/characters/GameSiam/S02_NAGA_SASINAKA"
UNITY_ASSET_DIR = ROOT / "Assets/Art/Characters/GameSiam/S02_NAGA_SASINAKA"
RUN_DIR = ROOT / "run/visual100-s02-2026-07-02/S02_NAGA_SASINAKA"
FINAL_DIR = RUN_DIR / "final_v10"
QA_DIR = RUN_DIR / "qa"
BACKUP_DIR = RUN_DIR / "backup/pre_v10_east_tail_reference_fix"

CELL = 64
COLUMNS = 6
DIRECTIONS = ["south", "south-east", "east", "north-east", "north", "north-west", "west", "south-west"]
ACTIONS = ["idle", "walk", "attack_01", "skill_01", "hurt", "death"]
EAST_ROW = DIRECTIONS.index("east")


def crop_frame(sheet: Image.Image, row: int, col: int) -> Image.Image:
    return sheet.crop((col * CELL, row * CELL, (col + 1) * CELL, (row + 1) * CELL)).convert("RGBA")


def paste_frame(sheet: Image.Image, row: int, col: int, frame: Image.Image) -> None:
    sheet.paste((0, 0, 0, 0), (col * CELL, row * CELL, (col + 1) * CELL, (row + 1) * CELL))
    sheet.alpha_composite(frame, (col * CELL, row * CELL))


def is_cyan_magic(r: int, g: int, b: int, a: int) -> bool:
    return a > 0 and r <= 110 and g >= 115 and b >= 120 and abs(g - b) <= 110


def is_skin(r: int, g: int, b: int, a: int) -> bool:
    return a > 0 and r >= 150 and g >= 75 and b <= 145 and r >= b + 25


def is_tail_material(r: int, g: int, b: int, a: int) -> bool:
    if a == 0 or is_cyan_magic(r, g, b, a) or is_skin(r, g, b, a):
        return False
    blueish = b >= r + 8 and b >= g - 20
    dark = r <= 95 and g <= 110 and b <= 165
    silver = r >= 145 and g >= 145 and b >= 150
    return blueish or dark or silver


def in_tail_zone(x: int, y: int) -> bool:
    return y >= 42 and (x <= 40 or (x <= 46 and y >= 50))


def replace_tail_zone(target: Image.Image, reference: Image.Image) -> int:
    target_px = target.load()
    ref_px = reference.load()
    changed = 0
    for y in range(CELL):
        for x in range(CELL):
            if not in_tail_zone(x, y):
                continue
            r, g, b, a = target_px[x, y]
            if is_tail_material(r, g, b, a):
                target_px[x, y] = (0, 0, 0, 0)
                changed += 1
    for y in range(CELL):
        for x in range(CELL):
            if not in_tail_zone(x, y):
                continue
            r, g, b, a = ref_px[x, y]
            if is_tail_material(r, g, b, a):
                target_px[x, y] = (r, g, b, a)
                changed += 1
    return changed


def copy_active_to_final() -> None:
    FINAL_DIR.mkdir(parents=True, exist_ok=True)
    for action in ACTIONS:
        for suffix in ("sheet-clean.png", "metadata.json"):
            src = ASSET_DIR / f"{action}-{suffix}"
            if src.exists():
                shutil.copy2(src, FINAL_DIR / src.name)


def backup_active() -> None:
    for base in (ASSET_DIR, UNITY_ASSET_DIR):
        if not base.exists():
            continue
        backup_subdir = BACKUP_DIR / base.relative_to(ROOT)
        backup_subdir.mkdir(parents=True, exist_ok=True)
        for action in ACTIONS:
            for suffix in ("sheet-clean.png", "metadata.json"):
                src = base / f"{action}-{suffix}"
                if src.exists():
                    shutil.copy2(src, backup_subdir / src.name)


def install_final() -> None:
    for base in (ASSET_DIR, UNITY_ASSET_DIR):
        if not base.exists():
            continue
        for action in ACTIONS:
            for suffix in ("sheet-clean.png", "metadata.json"):
                src = FINAL_DIR / f"{action}-{suffix}"
                dst = base / f"{action}-{suffix}"
                if src.exists() and dst.exists():
                    shutil.copy2(src, dst)


def make_checker() -> Image.Image:
    checker = Image.new("RGBA", (CELL, CELL), (246, 244, 238, 255))
    pixels = checker.load()
    for y in range(CELL):
        for x in range(CELL):
            if ((x // 8 + y // 8) & 1) == 0:
                pixels[x, y] = (232, 228, 218, 255)
    return checker


def make_east_qc(out_path: Path) -> None:
    try:
        font = ImageFont.truetype("arial.ttf", 16)
        small = ImageFont.truetype("arial.ttf", 12)
    except OSError:
        font = ImageFont.load_default()
        small = ImageFont.load_default()
    scale = 5
    label_w = 108
    top = 42
    row_h = CELL * scale + 34
    img = Image.new("RGBA", (label_w + COLUMNS * CELL * scale, top + len(ACTIONS) * row_h), (24, 25, 29, 255))
    draw = ImageDraw.Draw(img)
    draw.text((8, 8), "S02 v10 east all frames x5", fill=(255, 255, 255), font=font)
    for col in range(COLUMNS):
        draw.text((label_w + col * CELL * scale + 6, 26), f"f{col}", fill=(210, 220, 230), font=small)
    checker = make_checker()
    for action_idx, action in enumerate(ACTIONS):
        sheet = Image.open(FINAL_DIR / f"{action}-sheet-clean.png").convert("RGBA")
        y0 = top + action_idx * row_h
        draw.rectangle((0, y0, img.width, y0 + row_h), fill=(36, 37, 42, 255) if action_idx % 2 else (31, 32, 37, 255))
        draw.text((6, y0 + 14), action, fill=(255, 235, 180), font=font)
        for col in range(COLUMNS):
            tile = checker.copy()
            tile.alpha_composite(crop_frame(sheet, EAST_ROW, col))
            img.alpha_composite(tile.resize((CELL * scale, CELL * scale), Image.Resampling.NEAREST), (label_w + col * CELL * scale, y0 + 28))
    img.save(out_path)


def main() -> None:
    QA_DIR.mkdir(parents=True, exist_ok=True)
    backup_active()
    copy_active_to_final()
    stats: dict[str, int] = {}
    for action in ("walk", "attack_01"):
        sheet_path = FINAL_DIR / f"{action}-sheet-clean.png"
        sheet = Image.open(sheet_path).convert("RGBA")
        reference = crop_frame(sheet, EAST_ROW, 0)
        for col in (2, 5):
            frame = crop_frame(sheet, EAST_ROW, col)
            stats[f"{action}/east/f{col}"] = replace_tail_zone(frame, reference)
            paste_frame(sheet, EAST_ROW, col, frame)
        sheet.save(sheet_path)
    install_final()
    east_qc = QA_DIR / "S02_v10_east_all_frames_x5.png"
    make_east_qc(east_qc)
    manifest = {
        "hero_id": "S02_NAGA_SASINAKA",
        "version": "v10_east_tail_reference_fix",
        "status": "installed_active_pending_visual_qc",
        "final_dir": str(FINAL_DIR),
        "backup_dir": str(BACKUP_DIR),
        "changes": {
            "east_tail_reference": "Replaced walk/attack_01 east f2/f5 lower-left tail with the same action's clean f0 tail zone; removed v9 stray pixels.",
        },
        "stats": stats,
        "qc": {"east_all_frames_x5": str(east_qc)},
    }
    (RUN_DIR / "run-manifest-v10.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
