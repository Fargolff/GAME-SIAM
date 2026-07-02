from __future__ import annotations

import math
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

import preview_vfx_v94_showcase as base


WORKSPACE = Path(r"C:\Users\ADMIN\Documents\GAME IDLE")
RUN_DIR = WORKSPACE / "run" / "vfx-v95"
RUNTIME_QC_DIR = WORKSPACE / "run" / "runtime-qc-2026-06-30"
LOG_PATH = RUNTIME_QC_DIR / "skill_showcase_all40_v95_2026-06-30.logic.tsv"

WIDTH = base.WIDTH
HEIGHT = base.HEIGHT
FPS = base.FPS
SECONDS_PER_HERO = base.SECONDS_PER_HERO


def load_showcase_roles() -> dict[str, str]:
    roles: dict[str, str] = {}
    if not LOG_PATH.exists():
        return roles
    for line in LOG_PATH.read_text(encoding="utf-8").splitlines():
        parts = line.split("\t")
        if len(parts) >= 6:
            roles[parts[1]] = parts[5]
    return roles


def draw_label(draw: ImageDraw.ImageDraw, text: str) -> None:
    font = ImageFont.load_default()
    draw.text((22, 18), text, fill=(255, 218, 95), font=font)
    draw.text((22, 34), "V95: stronger caster-to-target personal trail, all-40 Godot showcase log", fill=(166, 208, 190), font=font)


def draw_travel_guides(canvas: Image.Image, start: tuple[int, int], end: tuple[int, int], color: tuple[int, int, int], alpha: int) -> None:
    draw = ImageDraw.Draw(canvas)
    sx, sy = start
    ex, ey = end
    for i in range(4):
        t0 = i / 4.0
        t1 = min(1.0, t0 + 0.16)
        x0 = int(base.lerp(sx, ex, t0))
        y0 = int(base.lerp(sy, ey, t0)) + (i % 2) * 3
        x1 = int(base.lerp(sx, ex, t1))
        y1 = int(base.lerp(sy, ey, t1)) + (i % 2) * 3
        draw.line((x0, y0, x1, y1), fill=color + (alpha,), width=2)


def compose_frame(hero_id: str, key: str, vfx_file: str, role: str, frame_no: int) -> Image.Image:
    local_t = frame_no / float(FPS)
    phase = local_t / SECONDS_PER_HERO
    ranged = role == "ranged"
    y = 360 + int(math.sin(frame_no * 0.09) * 2)
    start_x = 330
    target_x = 900 if ranged else 675
    cast_x = start_x if ranged else 585
    target_id = "S03_YAKSHA_KRAIASURA" if hero_id != "S03_YAKSHA_KRAIASURA" else "A02_TIGER_PLOENGPAYAK"

    canvas = base.battlefield()
    draw = ImageDraw.Draw(canvas)
    draw_label(draw, f"{hero_id} | {key} | {role.upper()}")

    move_t = 0.0 if ranged else max(0.0, min(1.0, phase / 0.24))
    hero_x = int(base.lerp(start_x, cast_x, move_t))

    target_idle = base.sheet_frame(base.CHAR_DIR / target_id / "idle-sheet-clean.png", (frame_no // 5) % 6, "west")
    target_idle = base.tinted(target_idle, (255, 70, 58), 0.22)
    base.draw_shadow(draw, (target_x, y + 52), 108, 32)
    base.paste_nearest(canvas, target_idle, (target_x, y), 3)
    base.draw_hp(draw, (target_x, y), False)

    action = "walk" if (not ranged and phase < 0.24) else "skill_01"
    sheet_path = base.CHAR_DIR / hero_id / f"{action}-sheet-clean.png"
    char_frame = min(5, int(max(0.0, local_t - (0.20 if not ranged else 0.04)) * 10.5))
    if action == "walk":
        char_frame = (frame_no // 4) % 6
    hero = base.sheet_frame(sheet_path, char_frame, "east")
    base.draw_shadow(draw, (hero_x, y + 52), 104, 32)
    base.paste_nearest(canvas, hero, (hero_x, y), 3)
    base.draw_hp(draw, (hero_x, y), True)

    vfx_path = base.VFX_DIR / vfx_file
    cast_start = 0.30 if not ranged else 0.14
    release_start = cast_start + 0.16
    impact_start = release_start + (0.38 if ranged else 0.20)
    hand = (hero_x + 60, y - 18)
    body_hit = (target_x - 18, y - 18)
    effect = None
    if cast_start <= local_t < release_start:
        f = min(5, int((local_t - cast_start) / max(0.001, release_start - cast_start) * 6.0))
        effect = base.vfx_frame(vfx_path, f)
        base.paste_nearest(canvas, effect, hand, 2, 0.82)
    elif release_start <= local_t < impact_start:
        f = min(5, int((local_t - release_start) / max(0.001, impact_start - release_start) * 6.0))
        travel_t = (local_t - release_start) / max(0.001, impact_start - release_start)
        effect = base.vfx_frame(vfx_path, f)
        draw_travel_guides(canvas, hand, body_hit, (255, 204, 78), 105 if ranged else 70)
        for ghost in range(3 if ranged else 2):
            ghost_t = max(0.0, travel_t - 0.105 * ghost)
            gx = int(base.lerp(hand[0], body_hit[0], ghost_t))
            gy = int(base.lerp(hand[1], body_hit[1], ghost_t)) + ghost * 2
            alpha = (0.82 if ranged else 0.66) / float(ghost + 1)
            scale = 2 if ranged else 2
            base.paste_nearest(canvas, effect, (gx, gy), scale, alpha)
    elif local_t >= impact_start:
        f = min(5, int((local_t - impact_start) / 0.085))
        effect = base.vfx_frame(vfx_path, f)
        base.paste_nearest(canvas, effect, body_hit, 2, 0.98)
        draw.ellipse((target_x - 52, y + 22, target_x + 22, y + 48), outline=(255, 199, 72, 160), width=2)
        pop = int(900 + (hash(hero_id) % 220))
        font = ImageFont.load_default()
        draw.text((target_x - 20, y - 104 - int((local_t - impact_start) * 24)), f"-{pop}", fill=(255, 224, 86), font=font)

    return canvas.convert("RGB")


def build_movie() -> Path:
    RUN_DIR.mkdir(parents=True, exist_ok=True)
    roles = load_showcase_roles()
    out_movie = RUN_DIR / "personal_vfx_40_character_showcase_v95.mp4"
    proc = subprocess.Popen(
        [
            "ffmpeg", "-y",
            "-f", "rawvideo",
            "-vcodec", "rawvideo",
            "-pix_fmt", "rgb24",
            "-s", f"{WIDTH}x{HEIGHT}",
            "-r", str(FPS),
            "-i", "-",
            "-an",
            "-c:v", "libx264",
            "-pix_fmt", "yuv420p",
            "-crf", "18",
            str(out_movie),
        ],
        stdin=subprocess.PIPE,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    assert proc.stdin is not None
    frames_per_hero = int(FPS * SECONDS_PER_HERO)
    for hero_id, key, vfx_file, _style in base.HEROES:
        role = roles.get(hero_id, "ranged")
        for frame_no in range(frames_per_hero):
            proc.stdin.write(compose_frame(hero_id, key, vfx_file, role, frame_no).tobytes())
    proc.stdin.close()
    code = proc.wait()
    if code != 0:
        raise RuntimeError(f"ffmpeg failed with code {code}")
    return out_movie


def build_contact() -> Path:
    RUN_DIR.mkdir(parents=True, exist_ok=True)
    roles = load_showcase_roles()
    thumb_w, thumb_h = 320, 180
    columns = 5
    rows = math.ceil(len(base.HEROES) / columns)
    contact = Image.new("RGB", (thumb_w * columns, thumb_h * rows), (2, 10, 11))
    frame_no = int(FPS * 0.80)
    for idx, (hero_id, key, vfx_file, _style) in enumerate(base.HEROES):
        role = roles.get(hero_id, "ranged")
        frame = compose_frame(hero_id, key, vfx_file, role, frame_no)
        thumb = frame.resize((thumb_w, thumb_h), Image.Resampling.BICUBIC)
        contact.paste(thumb, ((idx % columns) * thumb_w, (idx // columns) * thumb_h))
    out = RUN_DIR / "personal_vfx_40_character_showcase_contact_v95.jpg"
    contact.save(out, quality=92)
    return out


def main() -> None:
    contact = build_contact()
    movie = build_movie()
    print(contact)
    print(movie)


if __name__ == "__main__":
    main()
