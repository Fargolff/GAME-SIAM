from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ASSET_DIR = ROOT / "godot/game-siam-idle/assets/characters/GameSiam/S02_NAGA_SASINAKA"
UNITY_ASSET_DIR = ROOT / "Assets/Art/Characters/GameSiam/S02_NAGA_SASINAKA"
RUN_DIR = ROOT / "run/visual100-s02-2026-07-02/S02_NAGA_SASINAKA"
FINAL_DIR = RUN_DIR / "final_v8"
QA_DIR = RUN_DIR / "qa"
BACKUP_DIR = RUN_DIR / "backup/pre_v8_tail_death_fix"

CELL = 64
COLUMNS = 6
DIRECTIONS = [
    "south",
    "south-east",
    "east",
    "north-east",
    "north",
    "north-west",
    "west",
    "south-west",
]
ACTIONS = ["idle", "walk", "attack_01", "skill_01", "hurt", "death"]
EAST_ROW = DIRECTIONS.index("east")


def crop_frame(sheet: Image.Image, row: int, col: int) -> Image.Image:
    return sheet.crop((col * CELL, row * CELL, (col + 1) * CELL, (row + 1) * CELL)).convert("RGBA")


def paste_frame(sheet: Image.Image, row: int, col: int, frame: Image.Image) -> None:
    sheet.paste((0, 0, 0, 0), (col * CELL, row * CELL, (col + 1) * CELL, (row + 1) * CELL))
    sheet.alpha_composite(frame, (col * CELL, row * CELL))


def frame_bbox(frame: Image.Image) -> tuple[int, int, int, int] | None:
    return frame.getchannel("A").getbbox()


def clamp(value: float, lo: int = 1, hi: int = 62) -> int:
    return max(lo, min(hi, int(round(value))))


def is_cyan_magic(r: int, g: int, b: int, a: int) -> bool:
    return a > 0 and r <= 110 and g >= 115 and b >= 120 and abs(g - b) <= 110


def is_skin(r: int, g: int, b: int, a: int) -> bool:
    return a > 0 and r >= 150 and g >= 75 and b <= 145 and r >= b + 25


def is_tail_material(r: int, g: int, b: int, a: int) -> bool:
    if a == 0 or is_cyan_magic(r, g, b, a) or is_skin(r, g, b, a):
        return False
    blueish = b >= r + 10 and b >= g - 18
    dark_blue = r <= 90 and g <= 105 and b <= 155
    silver_highlight = r >= 150 and g >= 155 and b >= 165
    return blueish or dark_blue or silver_highlight


def in_east_tail_zone(x: int, y: int) -> bool:
    if y < 42 or y > 62:
        return False
    if x <= 40:
        return True
    return x <= 47 and y >= 49


def repair_east_tail_with_idle_reference(target: Image.Image, reference: Image.Image) -> int:
    """Replace the ambiguous lower-left east tail with the clean idle east coil."""
    out = target.copy()
    target_px = out.load()
    reference_px = reference.load()
    changed = 0

    for y in range(CELL):
        for x in range(CELL):
            if not in_east_tail_zone(x, y):
                continue
            r, g, b, a = target_px[x, y]
            if is_tail_material(r, g, b, a):
                target_px[x, y] = (0, 0, 0, 0)
                changed += 1

    for y in range(CELL):
        for x in range(CELL):
            if not in_east_tail_zone(x, y):
                continue
            r, g, b, a = reference_px[x, y]
            if is_tail_material(r, g, b, a):
                target_px[x, y] = (r, g, b, a)
                changed += 1

    # A short dark bridge removes the "two separate tails" read without widening the silhouette.
    draw = ImageDraw.Draw(out, "RGBA")
    bridge = [(23, 46), (24, 46), (25, 47), (26, 48), (27, 49), (28, 50), (29, 51)]
    for x, y in bridge:
        draw.point((x, y), fill=(4, 23, 53, 255))
    for x, y in [(24, 48), (25, 49), (26, 50), (27, 51)]:
        draw.point((x, y), fill=(19, 82, 166, 255))
    return changed + len(bridge) + 4


def draw_magic_ring(draw: ImageDraw.ImageDraw, x: int, y: int, radius: int = 3) -> None:
    cyan = (34, 224, 243, 255)
    pale = (181, 255, 255, 255)
    for px, py in [
        (x - radius, y),
        (x + radius, y),
        (x, y - radius),
        (x, y + radius),
        (x - radius + 1, y - radius + 1),
        (x + radius - 1, y + radius - 1),
    ]:
        draw.point((clamp(px), clamp(py)), fill=cyan)
    draw.point((clamp(x + 1), clamp(y - radius)), fill=pale)


def reinforce_death_identity(frame: Image.Image, direction: str, col: int) -> int:
    bbox = frame_bbox(frame)
    if bbox is None or col < 3:
        return 0
    left, top, right, bottom = bbox
    draw = ImageDraw.Draw(frame, "RGBA")

    if direction in ("east", "south-east"):
        hx, hy = right - 12, top + 8
        face = [(right - 14, top + 12), (right - 13, top + 13), (right - 12, top + 13)]
        orb = (right - 5, bottom - 7)
    elif direction in ("west", "south-west"):
        hx, hy = left + 12, top + 8
        face = [(left + 12, top + 12), (left + 13, top + 13), (left + 14, top + 13)]
        orb = (left + 5, bottom - 7)
    elif direction == "south":
        hx, hy = left + 17, top + 8
        face = [(left + 17, top + 12), (left + 18, top + 13), (left + 19, top + 13)]
        orb = (left + 7, bottom - 8)
    elif direction in ("north", "north-east", "north-west"):
        hx, hy = (left + right) / 2, top + 6
        face = []
        orb = (right - 7 if direction != "north-west" else left + 7, bottom - 7)
    else:
        hx, hy = (left + right) / 2, top + 8
        face = []
        orb = (left + 6, bottom - 8)

    navy = (3, 20, 47, 255)
    white = (233, 249, 255, 255)
    steel = (155, 184, 216, 255)
    skin = (232, 164, 126, 255)
    for dx, dy in [(-2, 0), (-1, -1), (0, -2), (1, -1), (2, 0), (-3, 1), (3, 1)]:
        draw.point((clamp(hx + dx), clamp(hy + dy)), fill=navy)
    for dx, dy in [(-1, 0), (0, -1), (1, 0), (-2, 1), (2, 1)]:
        draw.point((clamp(hx + dx), clamp(hy + dy)), fill=white)
    for dx, dy in [(0, 2), (1, 2), (-1, 2)]:
        draw.point((clamp(hx + dx), clamp(hy + dy)), fill=steel)
    for x, y in face:
        draw.point((clamp(x), clamp(y)), fill=skin)
    draw_magic_ring(draw, clamp(orb[0]), clamp(orb[1]), 3)
    return 18 + len(face)


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
    draw.text((8, 8), "S02 v8 east all frames x5", fill=(255, 255, 255), font=font)
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


def make_checker() -> Image.Image:
    checker = Image.new("RGBA", (CELL, CELL), (246, 244, 238, 255))
    pixels = checker.load()
    for y in range(CELL):
        for x in range(CELL):
            if ((x // 8 + y // 8) & 1) == 0:
                pixels[x, y] = (232, 228, 218, 255)
    return checker


def make_death_qc(out_path: Path) -> None:
    try:
        font = ImageFont.truetype("arial.ttf", 18)
    except OSError:
        font = ImageFont.load_default()
    scale = 4
    label_w = 145
    top = 28
    row_h = CELL * scale + 32
    img = Image.new("RGBA", (label_w + COLUMNS * CELL * scale, top + len(DIRECTIONS) * row_h), (26, 27, 31, 255))
    draw = ImageDraw.Draw(img)
    draw.text((8, 4), "S02 death v8 x4", fill=(255, 255, 255), font=font)
    checker = make_checker()
    sheet = Image.open(FINAL_DIR / "death-sheet-clean.png").convert("RGBA")
    for row, direction in enumerate(DIRECTIONS):
        y0 = top + row * row_h
        draw.rectangle((0, y0, img.width, y0 + row_h), fill=(38, 39, 44, 255) if row % 2 else (33, 34, 39, 255))
        draw.text((6, y0 + 10), direction, fill=(255, 238, 180), font=font)
        for col in range(COLUMNS):
            tile = checker.copy()
            tile.alpha_composite(crop_frame(sheet, row, col))
            img.alpha_composite(tile.resize((CELL * scale, CELL * scale), Image.Resampling.NEAREST), (label_w + col * CELL * scale, y0 + 28))
    img.save(out_path)


def patch_sheets() -> dict[str, int]:
    stats = {"east_tail_cells_repaired": 0, "death_cells_reinforced": 0}
    idle_sheet = Image.open(FINAL_DIR / "idle-sheet-clean.png").convert("RGBA")
    idle_refs = [crop_frame(idle_sheet, EAST_ROW, col) for col in range(COLUMNS)]

    for action in ("walk", "attack_01", "skill_01", "hurt"):
        sheet_path = FINAL_DIR / f"{action}-sheet-clean.png"
        sheet = Image.open(sheet_path).convert("RGBA")
        for col in range(COLUMNS):
            frame = crop_frame(sheet, EAST_ROW, col)
            changed = repair_east_tail_with_idle_reference(frame, idle_refs[col])
            if changed:
                stats["east_tail_cells_repaired"] += 1
                paste_frame(sheet, EAST_ROW, col, frame)
        sheet.save(sheet_path)

    death_path = FINAL_DIR / "death-sheet-clean.png"
    death_sheet = Image.open(death_path).convert("RGBA")
    for row, direction in enumerate(DIRECTIONS):
        for col in (3, 4, 5):
            frame = crop_frame(death_sheet, row, col)
            changed = reinforce_death_identity(frame, direction, col)
            if changed:
                stats["death_cells_reinforced"] += 1
                paste_frame(death_sheet, row, col, frame)
    death_sheet.save(death_path)
    return stats


def main() -> None:
    QA_DIR.mkdir(parents=True, exist_ok=True)
    backup_active()
    copy_active_to_final()
    stats = patch_sheets()
    install_final()
    east_qc = QA_DIR / "S02_v8_east_all_frames_x5.png"
    death_qc = QA_DIR / "S02_death_v8_x4.png"
    make_east_qc(east_qc)
    make_death_qc(death_qc)
    manifest = {
        "hero_id": "S02_NAGA_SASINAKA",
        "version": "v8_tail_death_fix",
        "status": "installed_active_pending_visual_qc",
        "source": str(ASSET_DIR),
        "final_dir": str(FINAL_DIR),
        "backup_dir": str(BACKUP_DIR),
        "changes": {
            "east_tail": "Replaced ambiguous east lower-tail cells with a clean idle-east reference coil and bridge pixels.",
            "death_identity": "Reinforced crown, face/orb cues on late death frames so prone silhouettes still read as the same hero.",
        },
        "stats": stats,
        "qc": {
            "east_all_frames_x5": str(east_qc),
            "death_x4": str(death_qc),
        },
    }
    (RUN_DIR / "run-manifest-v8.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
