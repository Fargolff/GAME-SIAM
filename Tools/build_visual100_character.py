from __future__ import annotations

import json
import math
import shutil
import argparse
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(r"C:\Users\ADMIN\Documents\GAME IDLE")
RUN = ROOT / "run" / "visual100-character-2026-07-02" / "S01_GARUDA_VAYUDEJ"
CELL = 64
COLS = 6
ROWS = 8
KEY = "#00ff00"

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

PALETTE = {
    "outline": (18, 13, 10, 255),
    "deep": (34, 24, 20, 255),
    "gold_dark": (111, 64, 17, 255),
    "gold": (214, 148, 35, 255),
    "gold_hi": (255, 220, 92, 255),
    "red_dark": (80, 20, 18, 255),
    "red": (174, 45, 31, 255),
    "red_hi": (241, 90, 49, 255),
    "beak": (255, 196, 58, 255),
    "white": (255, 238, 188, 255),
    "black": (8, 8, 7, 255),
    "vfx": (255, 226, 80, 220),
    "vfx2": (96, 226, 255, 180),
}


def dir_vec(direction: str) -> tuple[float, float]:
    angle = {
        "east": 0,
        "south-east": 45,
        "south": 90,
        "south-west": 135,
        "west": 180,
        "north-west": 225,
        "north": 270,
        "north-east": 315,
    }[direction]
    rad = math.radians(angle)
    return math.cos(rad), math.sin(rad)


def draw_poly(draw: ImageDraw.ImageDraw, pts, fill, outline=PALETTE["outline"]) -> None:
    draw.polygon(pts, fill=outline)
    cx = sum(x for x, _ in pts) / len(pts)
    cy = sum(y for _, y in pts) / len(pts)
    inner = [(round(cx + (x - cx) * 0.82), round(cy + (y - cy) * 0.82)) for x, y in pts]
    draw.polygon(inner, fill=fill)


def draw_line(draw: ImageDraw.ImageDraw, p1, p2, fill, width=2) -> None:
    draw.line((p1, p2), fill=PALETTE["outline"], width=width + 2)
    draw.line((p1, p2), fill=fill, width=width)


def star(draw: ImageDraw.ImageDraw, cx: int, cy: int, r: int, fill=PALETTE["vfx"]) -> None:
    pts = []
    for i in range(10):
        a = -math.pi / 2 + i * math.pi / 5
        rr = r if i % 2 == 0 else max(2, r // 3)
        pts.append((round(cx + math.cos(a) * rr), round(cy + math.sin(a) * rr)))
    draw.polygon(pts, fill=fill)


def ellipse(draw: ImageDraw.ImageDraw, box, fill, outline=PALETTE["outline"]) -> None:
    draw.ellipse(box, fill=outline)
    x0, y0, x1, y1 = box
    draw.ellipse((x0 + 1, y0 + 1, x1 - 1, y1 - 1), fill=fill)


def body_points(cx: int, cy: int, facing_x: float, crouch: int = 0):
    lean = round(facing_x * 2)
    return [
        (cx - 9 + lean, cy - 12 + crouch),
        (cx + 9 + lean, cy - 12 + crouch),
        (cx + 11, cy + 8 + crouch),
        (cx, cy + 15 + crouch),
        (cx - 11, cy + 8 + crouch),
    ]


def draw_wings(draw: ImageDraw.ImageDraw, cx: int, cy: int, direction: str, spread: int = 0) -> None:
    dx, dy = dir_vec(direction)
    back = dy < -0.3
    front = dy > 0.3
    side = 1 if dx >= 0 else -1
    size = 8 + spread

    if abs(dx) < 0.25:
        left = [(cx - 6, cy - 8), (cx - 17 - spread, cy - 1), (cx - 15, cy + 10), (cx - 5, cy + 7)]
        right = [(cx + 6, cy - 8), (cx + 17 + spread, cy - 1), (cx + 15, cy + 10), (cx + 5, cy + 7)]
        for wing in (left, right):
            draw_poly(draw, wing, PALETTE["red_dark" if back else "red"])
    else:
        far = [(cx - side * 3, cy - 8), (cx - side * (size + 5), cy - 2), (cx - side * (size + 1), cy + 10), (cx - side * 3, cy + 7)]
        near = [(cx + side * 4, cy - 9), (cx + side * (size + 8), cy - 3), (cx + side * (size + 4), cy + 11), (cx + side * 4, cy + 7)]
        draw_poly(draw, far, PALETTE["red_dark"])
        draw_poly(draw, near, PALETTE["red" if front else "red_dark"])

    for s in (-1, 1):
        if abs(dx) < 0.25 or s == side:
            base_x = cx + s * (10 + spread // 2)
            for i in range(3):
                draw.line(
                    (base_x, cy + 1 + i * 4, base_x + s * (5 + i), cy + 9 + i * 2),
                    fill=PALETTE["red_hi"],
                    width=1,
                )


def draw_legs(draw: ImageDraw.ImageDraw, cx: int, y: int, direction: str, pose: int, action: str) -> None:
    dx, dy = dir_vec(direction)
    side = 1 if dx >= 0 else -1
    step = [0, 2, 4, 2, 0, -2][pose % 6] if action == "walk" else 0
    if action == "death" and pose >= 3:
        return
    for leg in (-1, 1):
        x = cx + leg * 4 + round(dx * step * leg)
        knee_y = y - 7 + (1 if leg * step > 0 else 0)
        draw_line(draw, (x, y - 15), (x + leg * 2, knee_y), PALETTE["gold_dark"], 2)
        draw_line(draw, (x + leg * 2, knee_y), (x + leg * 3 + side, y - 2), PALETTE["gold"], 2)
        draw.line((x + leg * 3 + side, y - 1, x + leg * 7 + side, y - 1), fill=PALETTE["gold_hi"], width=2)


def draw_head(draw: ImageDraw.ImageDraw, cx: int, cy: int, direction: str, hurt: bool = False) -> None:
    dx, dy = dir_vec(direction)
    back = dy < -0.35
    side = 1 if dx >= 0 else -1
    ellipse(draw, (cx - 7, cy - 7, cx + 7, cy + 7), PALETTE["gold"])
    draw.polygon([(cx - 6, cy - 8), (cx, cy - 14), (cx + 6, cy - 8)], fill=PALETTE["outline"])
    draw.polygon([(cx - 4, cy - 8), (cx, cy - 12), (cx + 4, cy - 8)], fill=PALETTE["gold_hi"])
    draw.line((cx - 6, cy - 11, cx - 10, cy - 15), fill=PALETTE["gold_hi"], width=2)
    draw.line((cx + 6, cy - 11, cx + 10, cy - 15), fill=PALETTE["gold_hi"], width=2)
    if not back:
        if abs(dx) < 0.25:
            draw.rectangle((cx - 4, cy - 2, cx - 2, cy), fill=PALETTE["black"])
            draw.rectangle((cx + 2, cy - 2, cx + 4, cy), fill=PALETTE["black"])
            draw.polygon([(cx - 3, cy + 1), (cx + 3, cy + 1), (cx, cy + 5)], fill=PALETTE["beak"])
        else:
            x0, x1 = sorted((cx + side * 2, cx + side * 4))
            draw.rectangle((x0, cy - 2, x1, cy), fill=PALETTE["black"])
            draw.polygon([(cx + side * 5, cy + 1), (cx + side * 10, cy + 3), (cx + side * 5, cy + 5)], fill=PALETTE["outline"])
            draw.polygon([(cx + side * 5, cy + 2), (cx + side * 8, cy + 3), (cx + side * 5, cy + 4)], fill=PALETTE["beak"])
        if hurt:
            draw.line((cx - 4, cy + 5, cx + 4, cy + 6), fill=PALETTE["black"], width=1)
    else:
        draw.rectangle((cx - 5, cy + 1, cx + 5, cy + 3), fill=PALETTE["gold_dark"])


def spear(draw: ImageDraw.ImageDraw, hand: tuple[int, int], direction: str, mode: str, frame: int) -> tuple[int, int]:
    dx, dy = dir_vec(direction)
    if mode == "idle":
        vx, vy = dx * 0.35, -1.0
    elif mode == "attack":
        thrust = [0.1, -0.1, 0.55, 1.0, 0.7, 0.2][frame]
        vx, vy = dx * (0.8 + thrust), dy * (0.45 + thrust * 0.35)
    elif mode == "skill":
        vx, vy = dx * (1.2 if frame >= 2 else 0.5), dy * (0.9 if frame >= 2 else 0.2)
    elif mode == "hurt":
        vx, vy = -dx * 0.4, 0.9
    else:
        vx, vy = dx * 0.8, dy * 0.8
    length = 20 if mode == "idle" else 23 if mode != "skill" else 25
    mag = max(0.1, math.hypot(vx, vy))
    vx, vy = vx / mag, vy / mag
    tip = (round(hand[0] + vx * length), round(hand[1] + vy * length))
    butt = (round(hand[0] - vx * 7), round(hand[1] - vy * 7))
    tip = (max(4, min(59, tip[0])), max(4, min(59, tip[1])))
    butt = (max(4, min(59, butt[0])), max(4, min(59, butt[1])))
    draw_line(draw, butt, tip, PALETTE["gold"], 2)
    tx, ty = tip
    draw.polygon([(tx, ty), (tx - round(vy * 4), ty + round(vx * 4)), (tx + round(vx * 8), ty + round(vy * 8)), (tx + round(vy * 4), ty - round(vx * 4))], fill=PALETTE["outline"])
    draw.polygon([(tx, ty), (tx - round(vy * 2), ty + round(vx * 2)), (tx + round(vx * 6), ty + round(vy * 6)), (tx + round(vy * 2), ty - round(vx * 2))], fill=PALETTE["gold_hi"])
    return tip


def draw_vfx(draw: ImageDraw.ImageDraw, tip: tuple[int, int], direction: str, frame: int, kind: str) -> None:
    dx, dy = dir_vec(direction)
    if kind == "attack" and frame in (3, 4):
        star(draw, round(tip[0] + dx * 4), round(tip[1] + dy * 4), 5)
    if kind == "skill":
        if frame >= 1:
            star(draw, round(tip[0] + dx * (frame * 3)), round(tip[1] + dy * (frame * 3)), 3 + frame)
        if frame in (3, 4):
            cx = round(tip[0] + dx * 10)
            cy = round(tip[1] + dy * 10)
            draw.arc((cx - 12, cy - 12, cx + 12, cy + 12), 20, 300, fill=PALETTE["vfx2"], width=2)
            draw.line((tip[0], tip[1], cx, cy), fill=PALETTE["vfx"], width=2)


def draw_frame(direction: str, action: str, frame: int) -> Image.Image:
    im = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im, "RGBA")
    dx, dy = dir_vec(direction)
    cx = 32
    ground = 57
    bob = 0
    crouch = 0
    lean = 0
    spread = 0
    pose = frame
    if action == "idle":
        bob = [0, -1, 0, 1, 0, -1][frame]
    elif action == "walk":
        bob = [0, 1, 0, -1, 0, 1][frame]
        lean = round(dx * [0, 1, 1, 0, -1, -1][frame])
    elif action == "attack_01":
        crouch = [0, 1, 2, 1, 0, 0][frame]
        lean = round(dx * [0, -2, 3, 5, 2, 0][frame])
    elif action == "skill_01":
        crouch = [0, 1, 2, 2, 0, 0][frame]
        spread = [0, 2, 4, 6, 9, 2][frame]
        lean = round(dx * [0, -1, 0, 2, 3, 0][frame])
    elif action == "hurt":
        crouch = [0, 1, 2, 1, 0, 0][frame]
        lean = round(-dx * [0, 2, 5, 3, 1, 0][frame])
    elif action == "death":
        crouch = [0, 2, 6, 10, 13, 13][frame]
        lean = round(-dx * [0, 1, 3, 6, 10, 10][frame])

    base_x = cx + lean
    base_y = ground + bob

    if action == "death" and frame >= 3:
        draw_wings(draw, base_x - round(dx * 4), base_y - 16, direction, 1)
        body_y = base_y - 12
        body_len = 24
        side = 1 if dx >= 0 else -1
        angle_x = round((dx if abs(dx) > 0.2 else side) * body_len)
        angle_y = round((dy if abs(dy) > 0.2 else 0.25) * 5)
        draw_line(draw, (base_x - angle_x // 2, body_y - angle_y), (base_x + angle_x // 2, body_y + angle_y), PALETTE["gold_dark"], 9)
        ellipse(draw, (base_x + angle_x // 2 - 7, body_y + angle_y - 8, base_x + angle_x // 2 + 7, body_y + angle_y + 7), PALETTE["gold"])
        draw_head(draw, base_x + angle_x // 2, body_y + angle_y, direction, hurt=True)
        tip = spear(draw, (base_x - angle_x // 3, body_y), direction, "hurt", frame)
        if frame == 3:
            star(draw, base_x - round(dx * 10), base_y - 28, 4)
        return im

    draw_wings(draw, base_x, base_y - 28 + crouch, direction, spread)
    draw_legs(draw, base_x, ground, direction, pose, action)
    draw_poly(draw, body_points(base_x, base_y - 23, dx, crouch), PALETTE["gold_dark"])
    draw.polygon([(base_x - 5, base_y - 33 + crouch), (base_x + 5, base_y - 33 + crouch), (base_x + 2, base_y - 21 + crouch), (base_x - 2, base_y - 21 + crouch)], fill=PALETTE["red"])
    draw.line((base_x - 7, base_y - 26 + crouch, base_x + 7, base_y - 26 + crouch), fill=PALETTE["gold_hi"], width=1)
    draw_head(draw, base_x + round(dx * 2), base_y - 37 + crouch, direction, action == "hurt")

    hand = (base_x + round(dx * 5) + (1 if dx >= 0 else -1) * 4, base_y - 25 + crouch)
    mode = "idle"
    if action == "attack_01":
        mode = "attack"
    elif action == "skill_01":
        mode = "skill"
    elif action == "hurt":
        mode = "hurt"
    tip = spear(draw, hand, direction, mode, frame)
    draw_vfx(draw, tip, direction, frame, "attack" if action == "attack_01" else "skill" if action == "skill_01" else "")
    if action == "hurt" and frame in (1, 2):
        star(draw, base_x - round(dx * 12), base_y - 43, 4)
    return im


def save_sheet(action: str) -> None:
    sheet = Image.new("RGBA", (CELL * COLS, CELL * ROWS), (0, 0, 0, 0))
    frames_dir = RUN / "frames" / action
    frames_dir.mkdir(parents=True, exist_ok=True)
    for row, direction in enumerate(DIRECTIONS):
        for col in range(COLS):
            frame = draw_frame(direction, action, col)
            frame.save(frames_dir / f"{direction}-{col:02d}.png")
            sheet.alpha_composite(frame, (col * CELL, row * CELL))
    final = RUN / "final"
    final.mkdir(parents=True, exist_ok=True)
    sheet.save(final / f"{action}-sheet-clean.png")
    meta = {
        "cell": CELL,
        "columns": COLS,
        "rows": ROWS,
        "action": action,
        "directions": DIRECTIONS,
        "rows_meta": [
            {"row": i, "action": action, "direction": direction, "frames": COLS}
            for i, direction in enumerate(DIRECTIONS)
        ],
    }
    (final / f"{action}-metadata.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")


def copy_to_assets() -> None:
    src = RUN / "final"
    destinations = [
        ROOT / "Assets" / "Art" / "Characters" / "GameSiam" / "S01_GARUDA_VAYUDEJ",
        ROOT / "godot" / "game-siam-idle" / "assets" / "characters" / "GameSiam" / "S01_GARUDA_VAYUDEJ",
    ]
    for dest in destinations:
        backup = RUN / "backup" / dest.relative_to(ROOT)
        backup.mkdir(parents=True, exist_ok=True)
        dest.mkdir(parents=True, exist_ok=True)
        for action in ACTIONS:
            for suffix in ["sheet-clean.png", "metadata.json"]:
                name = f"{action}-{suffix}"
                if (dest / name).exists() and not (backup / name).exists():
                    shutil.copy2(dest / name, backup / name)
                shutil.copy2(src / name, dest / name)
        (dest / "QC_STATUS.json").write_text(
            json.dumps(
                {
                    "status": "VISUAL100_REPLACEMENT_CANDIDATE",
                    "source": str(RUN),
                    "notes": "Procedural replacement generated to fix identity, direction, scale, and runtime readability blockers.",
                },
                indent=2,
            ),
            encoding="utf-8",
        )


def write_manifest() -> None:
    RUN.mkdir(parents=True, exist_ok=True)
    (RUN / "run-manifest.json").write_text(
        json.dumps(
            {
                "hero_id": "S01_GARUDA_VAYUDEJ",
                "method": "component_pixel_art_replacement",
                "cell": CELL,
                "columns": COLS,
                "rows": ROWS,
                "actions": ACTIONS,
                "directions": DIRECTIONS,
                "target": "drop-in replacement for existing 384x512 action sheets",
                "identity_lock": [
                    "Garuda/bird warrior read, not human/elf",
                    "gold red black Thai fantasy armor",
                    "large feather wings persist in every action",
                    "solar spear keeps one length and hand anchor",
                ],
            },
            indent=2,
        ),
        encoding="utf-8",
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--copy-to-assets", action="store_true")
    args = parser.parse_args()

    write_manifest()
    for action in ACTIONS:
        save_sheet(action)
    if args.copy_to_assets:
        copy_to_assets()
    print(RUN)


if __name__ == "__main__":
    main()
