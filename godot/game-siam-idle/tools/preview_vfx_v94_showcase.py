from __future__ import annotations

import math
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFont


SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from build_vfx_v93 import HEROES


WORKSPACE = Path(r"C:\Users\ADMIN\Documents\GAME IDLE")
PROJECT = WORKSPACE / "godot" / "game-siam-idle"
RUN_DIR = WORKSPACE / "run" / "vfx-v94"
RUNTIME_QC_DIR = WORKSPACE / "run" / "runtime-qc-2026-06-30"
CHAR_DIR = PROJECT / "assets" / "characters" / "GameSiam"
VFX_DIR = PROJECT / "assets" / "vfx" / "generated"
BACKGROUND = PROJECT / "assets" / "ui" / "battlefield_siam_temple.png"
LOG_PATH = RUNTIME_QC_DIR / "skill_showcase_all40_v94_2026-06-30.logic.tsv"

CELL = 64
WIDTH = 1280
HEIGHT = 720
FPS = 24
SECONDS_PER_HERO = 1.85
DIRECTIONS = ["south", "south-east", "east", "north-east", "north", "north-west", "west", "south-west"]


def load_showcase_roles() -> dict[str, str]:
    roles: dict[str, str] = {}
    if not LOG_PATH.exists():
        return roles
    for line in LOG_PATH.read_text(encoding="utf-8").splitlines():
        parts = line.split("\t")
        if len(parts) >= 6:
            roles[parts[1]] = parts[5]
    return roles


def sheet_frame(path: Path, action_frame: int, direction: str = "east") -> Image.Image:
    sheet = Image.open(path).convert("RGBA")
    row = DIRECTIONS.index(direction)
    frame = max(0, min(5, action_frame))
    return sheet.crop((frame * CELL, row * CELL, frame * CELL + CELL, row * CELL + CELL))


def vfx_frame(path: Path, frame: int) -> Image.Image:
    strip = Image.open(path).convert("RGBA")
    safe_frame = max(0, min(5, frame))
    return strip.crop((safe_frame * CELL, 0, safe_frame * CELL + CELL, CELL))


def paste_nearest(canvas: Image.Image, image: Image.Image, center: tuple[int, int], scale: int, alpha: float = 1.0) -> None:
    scaled = image.resize((image.width * scale, image.height * scale), Image.Resampling.NEAREST)
    if alpha < 0.999:
        scaled = scaled.copy()
        a = scaled.getchannel("A").point(lambda px: int(px * alpha))
        scaled.putalpha(a)
    x = center[0] - scaled.width // 2
    y = center[1] - scaled.height // 2
    canvas.alpha_composite(scaled, (x, y))


def tinted(image: Image.Image, color: tuple[int, int, int], strength: float) -> Image.Image:
    overlay = Image.new("RGBA", image.size, color + (0,))
    alpha = image.getchannel("A").point(lambda px: int(px * strength))
    overlay.putalpha(alpha)
    out = image.copy()
    out.alpha_composite(overlay)
    return out


def battlefield() -> Image.Image:
    bg = Image.open(BACKGROUND).convert("RGBA")
    bg = bg.resize((WIDTH, HEIGHT), Image.Resampling.BICUBIC)
    shade = Image.new("RGBA", (WIDTH, HEIGHT), (0, 18, 20, 62))
    bg.alpha_composite(shade)
    draw = ImageDraw.Draw(bg)
    lane_ys = [252, 304, 356, 408, 460]
    for y in lane_ys:
        for x in range(120, WIDTH - 120, 42):
            draw.line((x, y, x + 18, y), fill=(215, 162, 56, 130), width=2)
    draw.rectangle((0, 0, WIDTH, 74), fill=(2, 12, 13, 150))
    return bg


def draw_shadow(draw: ImageDraw.ImageDraw, center: tuple[int, int], width: int, height: int) -> None:
    x, y = center
    draw.ellipse((x - width // 2, y - height // 2, x + width // 2, y + height // 2), fill=(0, 0, 0, 120))
    draw.ellipse((x - width // 3, y - height // 3, x + width // 3, y + height // 3), outline=(185, 134, 45, 150), width=1)


def draw_hp(draw: ImageDraw.ImageDraw, center: tuple[int, int], player: bool = True) -> None:
    x, y = center
    fill = (104, 220, 68, 255) if player else (232, 52, 36, 255)
    draw.rectangle((x - 34, y - 78, x + 34, y - 72), fill=(9, 12, 8, 210))
    draw.rectangle((x - 32, y - 77, x + 31, y - 73), fill=fill)


def hero_label(draw: ImageDraw.ImageDraw, text: str) -> None:
    font = ImageFont.load_default()
    draw.text((22, 18), text, fill=(255, 217, 99), font=font)
    draw.text((22, 34), "V94 offline visual proof: real sheets + generated personal VFX; Godot headless viewport capture is blocked", fill=(178, 210, 198), font=font)


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * max(0.0, min(1.0, t))


def compose_frame(hero_id: str, key: str, vfx_file: str, role: str, frame_no: int) -> Image.Image:
    local_t = frame_no / float(FPS)
    duration = SECONDS_PER_HERO
    phase = local_t / duration
    ranged = role == "ranged"
    y = 360 + int(math.sin(frame_no * 0.09) * 2)
    start_x = 330
    target_x = 900 if ranged else 675
    cast_x = start_x if ranged else 586
    target_id = "S03_YAKSHA_KRAIASURA" if hero_id != "S03_YAKSHA_KRAIASURA" else "A02_TIGER_PLOENGPAYAK"

    canvas = battlefield()
    draw = ImageDraw.Draw(canvas)
    hero_label(draw, f"{hero_id} | {key} | {role.upper()}")

    move_t = 0.0
    if not ranged:
        move_t = max(0.0, min(1.0, phase / 0.22))
    hero_x = int(lerp(start_x, cast_x, move_t))

    target_idle = sheet_frame(CHAR_DIR / target_id / "idle-sheet-clean.png", (frame_no // 5) % 6, "west")
    target_idle = tinted(target_idle, (255, 70, 58), 0.26)
    draw_shadow(draw, (target_x, y + 52), 110, 34)
    paste_nearest(canvas, target_idle, (target_x, y), 3)
    draw_hp(draw, (target_x, y), False)

    action = "walk" if (not ranged and phase < 0.22) else "skill_01"
    sheet_path = CHAR_DIR / hero_id / f"{action}-sheet-clean.png"
    char_frame = min(5, int(max(0.0, local_t - (0.18 if not ranged else 0.04)) * 10.0))
    if action == "walk":
        char_frame = (frame_no // 4) % 6
    hero = sheet_frame(sheet_path, char_frame, "east")
    draw_shadow(draw, (hero_x, y + 52), 104, 32)
    paste_nearest(canvas, hero, (hero_x, y), 3)
    draw_hp(draw, (hero_x, y), True)

    vfx_path = VFX_DIR / vfx_file
    cast_start = 0.28 if not ranged else 0.16
    release_start = cast_start + 0.18
    impact_start = release_start + (0.34 if ranged else 0.18)
    effect_scale = 2 if ranged else 2
    if cast_start <= local_t < release_start:
        f = min(5, int((local_t - cast_start) / max(0.001, (release_start - cast_start)) * 6.0))
        effect = vfx_frame(vfx_path, f)
        paste_nearest(canvas, effect, (hero_x + 55, y - 18), effect_scale, 0.78)
    elif release_start <= local_t < impact_start:
        f = min(5, int((local_t - release_start) / max(0.001, (impact_start - release_start)) * 6.0))
        travel_t = (local_t - release_start) / max(0.001, (impact_start - release_start))
        fx_x = int(lerp(hero_x + 62, target_x - 30, travel_t))
        fx_y = int(lerp(y - 18, y - 22, travel_t))
        effect = vfx_frame(vfx_path, f)
        trail_alpha = 0.36 if ranged else 0.22
        if ranged:
            for ghost in range(2):
                ghost_t = max(0.0, travel_t - 0.08 * (ghost + 1))
                gx = int(lerp(hero_x + 62, target_x - 30, ghost_t))
                paste_nearest(canvas, effect, (gx, fx_y + ghost * 2), effect_scale, trail_alpha / (ghost + 1))
        paste_nearest(canvas, effect, (fx_x, fx_y), effect_scale, 0.92)
    elif local_t >= impact_start:
        f = min(5, int((local_t - impact_start) / 0.085))
        effect = vfx_frame(vfx_path, f)
        paste_nearest(canvas, effect, (target_x - 18, y - 18), 3, 0.94)
        pop = int(900 + (hash(hero_id) % 220))
        font = ImageFont.load_default()
        draw.text((target_x - 22, y - 108 - int((local_t - impact_start) * 26)), f"-{pop}", fill=(255, 218, 82), font=font)

    return canvas.convert("RGB")


def build_movie() -> Path:
    RUN_DIR.mkdir(parents=True, exist_ok=True)
    roles = load_showcase_roles()
    out_movie = RUN_DIR / "personal_vfx_40_character_showcase_v94.mp4"
    proc = subprocess.Popen(
        [
            "ffmpeg",
            "-y",
            "-f",
            "rawvideo",
            "-vcodec",
            "rawvideo",
            "-pix_fmt",
            "rgb24",
            "-s",
            f"{WIDTH}x{HEIGHT}",
            "-r",
            str(FPS),
            "-i",
            "-",
            "-an",
            "-c:v",
            "libx264",
            "-pix_fmt",
            "yuv420p",
            "-crf",
            "18",
            str(out_movie),
        ],
        stdin=subprocess.PIPE,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    assert proc.stdin is not None
    frames_per_hero = int(FPS * SECONDS_PER_HERO)
    for hero_id, key, vfx_file, _style in HEROES:
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
    rows = math.ceil(len(HEROES) / columns)
    contact = Image.new("RGB", (thumb_w * columns, thumb_h * rows), (2, 10, 11))
    frame_no = int(FPS * 0.82)
    for idx, (hero_id, key, vfx_file, _style) in enumerate(HEROES):
        role = roles.get(hero_id, "ranged")
        frame = compose_frame(hero_id, key, vfx_file, role, frame_no)
        thumb = frame.resize((thumb_w, thumb_h), Image.Resampling.BICUBIC)
        contact.paste(thumb, ((idx % columns) * thumb_w, (idx // columns) * thumb_h))
    out = RUN_DIR / "personal_vfx_40_character_showcase_contact_v94.jpg"
    contact.save(out, quality=92)
    return out


def main() -> None:
    contact = build_contact()
    movie = build_movie()
    print(contact)
    print(movie)


if __name__ == "__main__":
    main()
