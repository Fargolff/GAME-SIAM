from __future__ import annotations

import argparse
from collections import deque
import json
import math
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ASSET_DIR = ROOT / "godot/game-siam-idle/assets/characters/GameSiam/S02_NAGA_SASINAKA"
UNITY_ASSET_DIR = ROOT / "Assets/Art/Characters/GameSiam/S02_NAGA_SASINAKA"
RUN_DIR = ROOT / "run/visual100-s02-2026-07-02"
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

DIR_VECTORS = {
    "south": (0.0, 1.0),
    "south-east": (0.78, 0.62),
    "east": (1.0, 0.0),
    "north-east": (0.78, -0.62),
    "north": (0.0, -1.0),
    "north-west": (-0.78, -0.62),
    "west": (-1.0, 0.0),
    "south-west": (-0.78, 0.62),
}


def clamp(value: float, lo: int = 2, hi: int = 61) -> int:
    return max(lo, min(hi, int(round(value))))


def frame_bbox(frame: Image.Image) -> tuple[int, int, int, int] | None:
    alpha = frame.getchannel("A")
    return alpha.getbbox()


def is_cyan_magic_pixel(r: int, g: int, b: int, a: int) -> bool:
    if a == 0:
        return False
    return r <= 105 and g >= 115 and b >= 120 and abs(g - b) <= 105


def is_preserved_fx_or_skin(r: int, g: int, b: int, a: int) -> bool:
    if a == 0:
        return False
    if is_cyan_magic_pixel(r, g, b, a):
        return True
    if r >= 160 and g >= 85 and b <= 130:
        return True
    if r >= 185 and g >= 185 and b >= 185:
        return True
    return False


def body_bbox(frame: Image.Image) -> tuple[int, int, int, int] | None:
    pixels = frame.load()
    left = top = CELL
    right = bottom = -1
    for y in range(CELL):
        for x in range(CELL):
            r, g, b, a = pixels[x, y]
            if a == 0 or is_cyan_magic_pixel(r, g, b, a):
                continue
            left = min(left, x)
            top = min(top, y)
            right = max(right, x + 1)
            bottom = max(bottom, y + 1)
    if right < left or bottom < top:
        return None
    return (left, top, right, bottom)


def paste_frame(sheet: Image.Image, row: int, col: int, frame: Image.Image) -> None:
    x = col * CELL
    y = row * CELL
    sheet.paste((0, 0, 0, 0), (x, y, x + CELL, y + CELL))
    sheet.alpha_composite(frame, (x, y))


def crop_frame(sheet: Image.Image, row: int, col: int) -> Image.Image:
    return sheet.crop((col * CELL, row * CELL, (col + 1) * CELL, (row + 1) * CELL)).convert("RGBA")


def shift_frame(frame: Image.Image, dx: int, dy: int) -> Image.Image:
    shifted = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    shifted.alpha_composite(frame, (dx, dy))
    return shifted


def clean_green_residue(frame: Image.Image) -> tuple[Image.Image, int]:
    pixels = frame.load()
    removed = 0
    for y in range(frame.height):
        for x in range(frame.width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            green_key_like = g >= 55 and r <= 78 and b <= 122 and g >= r + 28 and g >= b + 8
            if green_key_like:
                pixels[x, y] = (0, 0, 0, 0)
                removed += 1
    return frame, removed


def remove_tail_islands(frame: Image.Image) -> int:
    pixels = frame.load()
    seen: set[tuple[int, int]] = set()
    removed = 0
    for start_y in range(CELL):
        for start_x in range(CELL):
            if (start_x, start_y) in seen:
                continue
            r, g, b, a = pixels[start_x, start_y]
            if a == 0 or is_preserved_fx_or_skin(r, g, b, a):
                continue
            queue = deque([(start_x, start_y)])
            seen.add((start_x, start_y))
            component: list[tuple[int, int]] = []
            while queue:
                x, y = queue.popleft()
                component.append((x, y))
                for nx in range(x - 1, x + 2):
                    for ny in range(y - 1, y + 2):
                        if nx < 0 or ny < 0 or nx >= CELL or ny >= CELL or (nx, ny) in seen:
                            continue
                        rr, gg, bb, aa = pixels[nx, ny]
                        if aa > 0 and not is_preserved_fx_or_skin(rr, gg, bb, aa):
                            seen.add((nx, ny))
                            queue.append((nx, ny))
            if len(component) > 58:
                continue
            top = min(y for _, y in component)
            bottom = max(y for _, y in component)
            if top < 28 or bottom < 40:
                continue
            blueish = 0
            dark = 0
            for x, y in component:
                rr, gg, bb, aa = pixels[x, y]
                if bb >= rr + 18 and bb >= gg - 8:
                    blueish += 1
                if rr <= 78 and gg <= 92 and bb <= 135:
                    dark += 1
            if blueish / len(component) < 0.45 and dark / len(component) < 0.55:
                continue
            for x, y in component:
                pixels[x, y] = (0, 0, 0, 0)
                removed += 1
    return removed


def draw_pixel_square(draw: ImageDraw.ImageDraw, x: int, y: int, color: tuple[int, int, int, int], size: int = 1) -> None:
    half = size // 2
    draw.rectangle((x - half, y - half, x + half, y + half), fill=color)


def draw_star(draw: ImageDraw.ImageDraw, x: int, y: int, color: tuple[int, int, int, int], size: int = 4) -> None:
    x = clamp(x)
    y = clamp(y)
    draw.point((x, y), fill=color)
    for i in range(1, size + 1):
        fade = (color[0], color[1], color[2], max(80, color[3] - i * 34))
        if x - i >= 1:
            draw.point((x - i, y), fill=fade)
        if x + i <= 62:
            draw.point((x + i, y), fill=fade)
        if y - i >= 1:
            draw.point((x, y - i), fill=fade)
        if y + i <= 62:
            draw.point((x, y + i), fill=fade)


def draw_magic_ring(draw: ImageDraw.ImageDraw, x: int, y: int, radius: int = 5) -> None:
    cyan = (42, 230, 244, 255)
    pale = (178, 255, 255, 255)
    points = [
        (x - radius, y),
        (x + radius, y),
        (x, y - radius),
        (x, y + radius),
        (x - radius + 2, y - radius + 2),
        (x + radius - 2, y - radius + 2),
        (x - radius + 2, y + radius - 2),
        (x + radius - 2, y + radius - 2),
    ]
    for px, py in points:
        draw.point((clamp(px), clamp(py)), fill=cyan)
    draw.point((clamp(x + radius - 1), clamp(y - 1)), fill=pale)
    draw.point((clamp(x - 1), clamp(y - radius + 1)), fill=pale)


def draw_attached_energy(frame: Image.Image, direction: str, origin: tuple[int, int], action: str, col: int) -> None:
    draw = ImageDraw.Draw(frame, "RGBA")
    vx, vy = DIR_VECTORS[direction]
    ox, oy = origin
    cyan = (35, 229, 244, 255)
    pale = (190, 255, 255, 255)
    blue = (24, 131, 234, 255)
    if action == "skill_01":
        ring_radius = {1: 4, 2: 5, 3: 5, 4: 4, 5: 3}
        if col not in ring_radius:
            return
        draw_magic_ring(draw, ox, oy, ring_radius[col])
        draw_star(draw, clamp(ox - vy * 4), clamp(oy + vx * 4), pale, 2)
        draw_star(draw, clamp(ox + vx * 4), clamp(oy + vy * 4), cyan, 1)
        if col in (2, 3, 4):
            for side in (-1, 1):
                px = clamp(ox + vx * 6 + (-vy * side * 3))
                py = clamp(oy + vy * 6 + (vx * side * 3))
                draw.point((px, py), fill=blue if col == 4 else cyan)
    elif action == "attack_01":
        if col not in (2, 3, 4):
            return
        px = clamp(ox + vx * (4 + col))
        py = clamp(oy + vy * (4 + col))
        draw_star(draw, px, py, pale if col == 3 else cyan, 2)
        draw.point((clamp(px + vx * 3), clamp(py + vy * 3)), fill=blue)


def origin_for(direction: str, bbox: tuple[int, int, int, int]) -> tuple[int, int]:
    left, top, right, bottom = bbox
    cx = (left + right) / 2
    if direction == "south":
        return clamp(left + 13), clamp(top + 23)
    if direction == "south-east":
        return clamp(right - 16), clamp(top + 24)
    if direction == "east":
        return clamp(right - 15), clamp(top + 24)
    if direction == "north-east":
        return clamp(right - 17), clamp(top + 20)
    if direction == "north":
        return clamp(cx - 8), clamp(top + 20)
    if direction == "north-west":
        return clamp(left + 17), clamp(top + 20)
    if direction == "west":
        return clamp(left + 15), clamp(top + 24)
    if direction == "south-west":
        return clamp(left + 16), clamp(top + 24)
    return clamp(cx), clamp(top + 24)


def remove_loose_magic(frame: Image.Image, bbox: tuple[int, int, int, int]) -> int:
    left, top, right, bottom = bbox
    keep = (left - 7, top - 7, right + 7, bottom + 7)
    pixels = frame.load()
    removed = 0
    for y in range(CELL):
        for x in range(CELL):
            r, g, b, a = pixels[x, y]
            if not is_cyan_magic_pixel(r, g, b, a):
                continue
            if keep[0] <= x <= keep[2] and keep[1] <= y <= keep[3]:
                continue
            pixels[x, y] = (0, 0, 0, 0)
            removed += 1
    return removed


def polish_action(sheet: Image.Image, action: str) -> dict[str, int]:
    stats = {"green_removed": 0, "loose_magic_removed": 0, "frames_changed": 0}
    for row, direction in enumerate(DIRECTIONS):
        for col in range(COLUMNS):
            frame = crop_frame(sheet, row, col)
            frame, removed = clean_green_residue(frame)
            stats["green_removed"] += removed
            changed = removed > 0
            bbox = frame_bbox(frame)
            if bbox is None:
                paste_frame(sheet, row, col, frame)
                continue

            if action in ("attack_01", "skill_01") and col in (1, 2, 3, 4, 5):
                core_bbox = body_bbox(frame) or bbox
                non_magic = frame.copy()
                loose_removed = remove_loose_magic(non_magic, core_bbox)
                if loose_removed:
                    frame = non_magic
                    stats["loose_magic_removed"] += loose_removed
                    changed = True
                origin = origin_for(direction, core_bbox)
                before = frame.tobytes()
                draw_attached_energy(frame, direction, origin, action, col)
                changed = changed or before != frame.tobytes()

            if action == "hurt" and col in (1, 2, 3):
                vx, vy = DIR_VECTORS[direction]
                bbox2 = frame_bbox(frame) or bbox
                ox, oy = origin_for(direction, bbox2)
                fx = clamp(ox + DIR_VECTORS[direction][0] * 7)
                fy = clamp(oy + DIR_VECTORS[direction][1] * 7)
                draw = ImageDraw.Draw(frame, "RGBA")
                draw_star(draw, fx, fy, (255, 176, 72, 255), 3)
                draw.point((clamp(fx - DIR_VECTORS[direction][0] * 2), clamp(fy - DIR_VECTORS[direction][1] * 2)), fill=(255, 238, 152, 255))
                changed = True

            if action == "death" and col >= 4:
                bbox3 = frame_bbox(frame)
                if bbox3:
                    target_bottom = 58
                    dy = max(-3, min(5, target_bottom - bbox3[3]))
                    if dy:
                        frame = shift_frame(frame, 0, dy)
                        changed = True
                    sharpen_death_identity(frame, direction)
                    changed = True

            tail_removed = remove_tail_islands(frame)
            if tail_removed:
                changed = True

            paste_frame(sheet, row, col, frame)
            if changed:
                stats["frames_changed"] += 1
    return stats


def sharpen_death_identity(frame: Image.Image, direction: str) -> None:
    bbox = frame_bbox(frame)
    if not bbox:
        return
    left, top, right, bottom = bbox
    draw = ImageDraw.Draw(frame, "RGBA")
    if direction in ("north", "north-east", "north-west"):
        hx = clamp((left + right) / 2 + (4 if direction == "north-east" else -4 if direction == "north-west" else 2))
        hy = clamp(top + 5)
    elif direction in ("east", "south-east"):
        hx = clamp(right - 12)
        hy = clamp(top + 9)
    elif direction in ("west", "south-west"):
        hx = clamp(left + 12)
        hy = clamp(top + 9)
    else:
        hx = clamp(left + 16)
        hy = clamp(top + 9)
    white = (232, 249, 255, 255)
    navy = (3, 24, 52, 255)
    for dx, dy in [(-2, 0), (-1, -1), (0, -2), (1, -1), (2, 0)]:
        draw.point((clamp(hx + dx), clamp(hy + dy)), fill=navy)
    for dx, dy in [(-1, 0), (0, -1), (1, 0)]:
        draw.point((clamp(hx + dx), clamp(hy + dy)), fill=white)
    if direction in ("north", "north-east", "north-west"):
        orb_x = clamp(left + 10 if direction == "north-west" else right - 10)
        orb_y = clamp(bottom - 10)
        draw_magic_ring(draw, orb_x, orb_y, 3)
        draw.point((clamp(hx), clamp(hy + 3)), fill=(185, 224, 248, 255))
        draw.point((clamp(hx + (2 if direction != "north-west" else -2)), clamp(hy + 4)), fill=(235, 247, 255, 255))


def make_full_qc(candidate_dir: Path, out_path: Path) -> None:
    try:
        font = ImageFont.truetype("arial.ttf", 12)
        title_font = ImageFont.truetype("arial.ttf", 14)
    except OSError:
        font = ImageFont.load_default()
        title_font = ImageFont.load_default()
    label_w = 128
    top_h = 28
    row_h = CELL + 18
    width = label_w + COLUMNS * CELL
    height = top_h + len(ACTIONS) * len(DIRECTIONS) * row_h
    poster = Image.new("RGBA", (width, height), (29, 30, 34, 255))
    draw = ImageDraw.Draw(poster)
    draw.text((8, 6), "S02_NAGA_SASINAKA visual100 candidate full QC", fill=(255, 255, 255), font=title_font)
    checker = Image.new("RGBA", (CELL, CELL), (246, 244, 238, 255))
    px = checker.load()
    for y in range(CELL):
        for x in range(CELL):
            if ((x // 8 + y // 8) & 1) == 0:
                px[x, y] = (232, 228, 218, 255)
    row_idx = 0
    for action in ACTIONS:
        sheet = Image.open(candidate_dir / f"{action}-sheet-clean.png").convert("RGBA")
        for direction_idx, direction in enumerate(DIRECTIONS):
            y = top_h + row_idx * row_h
            draw.rectangle((0, y, width, y + row_h), fill=(42, 43, 47, 255) if row_idx % 2 else (35, 36, 40, 255))
            draw.text((6, y + 8), f"{action} {direction}", fill=(230, 230, 220), font=font)
            for col in range(COLUMNS):
                tile = checker.copy()
                tile.alpha_composite(crop_frame(sheet, direction_idx, col))
                poster.alpha_composite(tile, (label_w + col * CELL, y + 12))
            row_idx += 1
    poster.save(out_path)


def make_focus_qc(candidate_dir: Path, out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    for action in ("attack_01", "skill_01", "hurt", "death"):
        sheet = Image.open(candidate_dir / f"{action}-sheet-clean.png").convert("RGBA")
        scale = 4
        label_w = 145
        top = 28
        row_h = CELL * scale + 32
        width = label_w + COLUMNS * CELL * scale
        height = top + len(DIRECTIONS) * row_h
        img = Image.new("RGBA", (width, height), (26, 27, 31, 255))
        draw = ImageDraw.Draw(img)
        try:
            font = ImageFont.truetype("arial.ttf", 18)
        except OSError:
            font = ImageFont.load_default()
        draw.text((8, 4), f"S02 {action} x4 visual100 candidate", fill=(255, 255, 255), font=font)
        checker = Image.new("RGBA", (CELL, CELL), (246, 244, 238, 255))
        px = checker.load()
        for y in range(CELL):
            for x in range(CELL):
                if ((x // 8 + y // 8) & 1) == 0:
                    px[x, y] = (232, 228, 218, 255)
        for row, direction in enumerate(DIRECTIONS):
            y = top + row * row_h
            draw.rectangle((0, y, width, y + row_h), fill=(38, 39, 44, 255) if row % 2 else (33, 34, 39, 255))
            draw.text((6, y + 10), direction, fill=(255, 238, 180), font=font)
            for col in range(COLUMNS):
                tile = checker.copy()
                tile.alpha_composite(crop_frame(sheet, row, col))
                tile = tile.resize((CELL * scale, CELL * scale), Image.Resampling.NEAREST)
                img.alpha_composite(tile, (label_w + col * CELL * scale, y + 28))
        img.save(out_dir / f"S02_{action}_candidate_x4.png")


def copy_current_assets(target_dir: Path) -> None:
    target_dir.mkdir(parents=True, exist_ok=True)
    for action in ACTIONS:
        for suffix in ("sheet-clean.png", "metadata.json"):
            src = ASSET_DIR / f"{action}-{suffix}"
            if src.exists():
                shutil.copy2(src, target_dir / src.name)


def install_to_active(candidate_dir: Path, backup_dir: Path) -> None:
    backup_dir.mkdir(parents=True, exist_ok=True)
    for base in (ASSET_DIR, UNITY_ASSET_DIR):
        if not base.exists():
            continue
        backup_subdir = backup_dir / base.relative_to(ROOT)
        backup_subdir.mkdir(parents=True, exist_ok=True)
        for action in ACTIONS:
            src_png = candidate_dir / f"{action}-sheet-clean.png"
            dst_png = base / f"{action}-sheet-clean.png"
            if dst_png.exists():
                shutil.copy2(dst_png, backup_subdir / dst_png.name)
            shutil.copy2(src_png, dst_png)
            src_meta = candidate_dir / f"{action}-metadata.json"
            dst_meta = base / f"{action}-metadata.json"
            if src_meta.exists() and dst_meta.exists():
                shutil.copy2(dst_meta, backup_subdir / dst_meta.name)
                shutil.copy2(src_meta, dst_meta)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--install-active", action="store_true", help="Copy accepted candidate sheets into active Godot/Unity asset folders.")
    args = parser.parse_args()

    candidate_dir = RUN_DIR / "S02_NAGA_SASINAKA/final"
    qa_dir = RUN_DIR / "S02_NAGA_SASINAKA/qa"
    backup_dir = RUN_DIR / "S02_NAGA_SASINAKA/backup/pre_visual100_patch"
    candidate_dir.mkdir(parents=True, exist_ok=True)
    qa_dir.mkdir(parents=True, exist_ok=True)
    copy_current_assets(candidate_dir)

    per_action: dict[str, dict[str, int]] = {}
    for action in ACTIONS:
        path = candidate_dir / f"{action}-sheet-clean.png"
        sheet = Image.open(path).convert("RGBA")
        per_action[action] = polish_action(sheet, action)
        sheet.save(path)

    full_qc = qa_dir / "S02_visual100_candidate_full_qc.png"
    make_full_qc(candidate_dir, full_qc)
    make_focus_qc(candidate_dir, qa_dir)

    manifest = {
        "hero_id": "S02_NAGA_SASINAKA",
        "status": "candidate_not_final_until_subagent_runtime_qc_passes",
        "method": "targeted_existing_asset_pixel_polish",
        "source_asset_dir": str(ASSET_DIR),
        "candidate_dir": str(candidate_dir),
        "qa_dir": str(qa_dir),
        "changes": {
            "green_residue_cleanup": "Removed key-green-like fringe while preserving blue/cyan magic pixels.",
            "attack_01": "Added clearer direction-locked aqua bolt frames without changing idle/walk identity.",
            "skill_01": "Replaced ambiguous loose cyan particles with direction-locked charge/travel/fade frames.",
            "hurt": "Added small opposite-facing recoil and orange hit sparkle to make damage readable.",
            "death": "Normalized late-frame ground anchor and sharpened crown/orb identity marks on collapsed frames.",
        },
        "per_action_stats": per_action,
        "installed_active": args.install_active,
        "backup_dir": str(backup_dir) if args.install_active else None,
        "qc_full_contact": str(full_qc),
    }
    (RUN_DIR / "S02_NAGA_SASINAKA/run-manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")

    if args.install_active:
        install_to_active(candidate_dir, backup_dir)

    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
