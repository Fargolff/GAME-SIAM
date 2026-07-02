from __future__ import annotations

import math
import shutil
import subprocess
import tempfile
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


ROOT = Path(r"C:\Users\ADMIN\Documents\GAME IDLE")
ACTION_DIR = ROOT / "Assets" / "Art" / "ActionSheets"
OUT_DIR = ACTION_DIR / "Combined" / "QC_REGEN_BASIC_CONTROLLED"
IDLE_MP4 = ACTION_DIR / "Combined" / "QC_PASS_MASTER_DEEP_QC_v3_segments" / "01_Idle.mp4"
IDLE_FRAME = ACTION_DIR / "_QC" / "idle_first_frame.png"
WALK_MP4 = ACTION_DIR / "Walk_Margin25_Left_QC5_Tencent" / "Walk_Margin25_Left_QC5_Tencent_720p60_nowm_CANDIDATE.mp4"
ATTACK_MP4 = ACTION_DIR / "Attack_SameScale_QC1_Tencent" / "Attack_SameScale_QC1_Tencent_720p60_nowm_CANDIDATE.mp4"

W, H = 1280, 720
GREEN = (0, 255, 0)
BASELINE_Y = 666
TARGET_HEIGHT = 603
TARGET_CENTER_X = 633


def run(cmd: list[str]) -> None:
    subprocess.run(cmd, check=True)


def foreground_mask(img: Image.Image) -> Image.Image:
    rgb = img.convert("RGB")
    diff = ImageChops.difference(rgb, Image.new("RGB", rgb.size, GREEN)).convert("L")
    return diff.point(lambda p: 255 if p > 54 else 0)


def bbox_non_green(img: Image.Image) -> tuple[int, int, int, int] | None:
    return foreground_mask(img).getbbox()


def green_to_alpha(img: Image.Image) -> Image.Image:
    rgba = img.convert("RGBA")
    rgba.putalpha(foreground_mask(img))
    return rgba


def sprite_from_idle() -> Image.Image:
    img = Image.open(IDLE_FRAME).convert("RGB")
    bbox = bbox_non_green(img)
    if bbox is None:
        raise RuntimeError("Idle foreground not found")
    return green_to_alpha(img.crop(bbox))


def render_mp4(frames: list[Image.Image], out: Path, fps: int = 60) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as td:
        tdp = Path(td)
        for i, frame in enumerate(frames):
            frame.convert("RGB").save(tdp / f"frame_{i:04d}.png")
        run(
            [
                "ffmpeg",
                "-hide_banner",
                "-loglevel",
                "error",
                "-y",
                "-framerate",
                str(fps),
                "-i",
                str(tdp / "frame_%04d.png"),
                "-c:v",
                "libx264",
                "-pix_fmt",
                "yuv420p",
                "-r",
                str(fps),
                "-video_track_timescale",
                "15360",
                "-movflags",
                "+faststart",
                str(out),
            ]
        )


def extract_video_frames(video: Path, start: int, end: int) -> list[Image.Image]:
    with tempfile.TemporaryDirectory() as td:
        tdp = Path(td)
        run(
            [
                "ffmpeg",
                "-hide_banner",
                "-loglevel",
                "error",
                "-y",
                "-i",
                str(video),
                "-vf",
                f"select='between(n,{start},{end})'",
                "-vsync",
                "0",
                str(tdp / "frame_%04d.png"),
            ]
        )
        return [Image.open(p).convert("RGB") for p in sorted(tdp.glob("frame_*.png"))]


def fit_foreground_frame(img: Image.Image, center_x: int = TARGET_CENTER_X) -> Image.Image:
    bbox = bbox_non_green(img)
    canvas = Image.new("RGB", (W, H), GREEN)
    if bbox is None:
        return canvas

    fg = green_to_alpha(img.crop(bbox))
    scale = TARGET_HEIGHT / max(1, fg.height)
    sw = max(1, round(fg.width * scale))
    sh = max(1, round(fg.height * scale))
    fg = fg.resize((sw, sh), Image.Resampling.LANCZOS)

    x = round(center_x - sw / 2)
    y = BASELINE_Y - sh
    x = max(24, min(W - sw - 24, x))
    y = max(0, min(H - sh, y))
    canvas.paste(fg, (x, y), fg)
    return canvas


def build_walk() -> Path:
    # Skip the seed-to-result scale ramp. The later section contains the stable walk-in-place motion.
    frames = extract_video_frames(WALK_MP4, 82, 180)
    fitted = [fit_foreground_frame(f) for f in frames]
    # Pad to a short readable loop without exceeding the requested 1-3 second action length.
    looped = (fitted * 2)[:150]
    out = OUT_DIR / "02_Walk_QC_controlled_60fps.mp4"
    render_mp4(looped, out)
    return out


def transformed_sprite(sprite: Image.Image, angle: float, x_offset: int = 0, y_offset: int = 0, opacity: float = 1.0) -> Image.Image:
    rot = sprite.rotate(angle, expand=True, resample=Image.Resampling.BICUBIC)
    if opacity < 0.999:
        alpha = rot.getchannel("A").point(lambda a: int(a * opacity))
        rot.putalpha(alpha)

    canvas = Image.new("RGB", (W, H), GREEN)
    bbox = rot.getbbox()
    if bbox is None:
        return canvas
    x = TARGET_CENTER_X - rot.width // 2 + x_offset
    y = BASELINE_Y - rot.height + y_offset
    x = max(24, min(W - rot.width - 24, x))
    y = max(0, min(H - rot.height, y))
    canvas.paste(rot, (x, y), rot)
    return canvas


def star(draw: ImageDraw.ImageDraw, cx: int, cy: int, radius: int, fill: tuple[int, int, int]) -> None:
    pts = []
    for i in range(16):
        a = -math.pi / 2 + i * math.pi / 8
        r = radius if i % 2 == 0 else radius * 0.35
        pts.append((cx + math.cos(a) * r, cy + math.sin(a) * r))
    draw.polygon(pts, fill=fill)


def build_hit(sprite: Image.Image) -> Path:
    frames: list[Image.Image] = []
    for i in range(90):
        if i < 12:
            t = 0.0
        elif i < 18:
            t = (i - 12) / 6
        elif i < 35:
            t = 1.0 - (i - 18) / 34
        elif i < 64:
            t = 1.0 - (i - 35) / 29
        else:
            t = 0.0

        if i < 18:
            angle = 1.5 * t
            xoff = round(10 * t)
        elif i < 35:
            shake = -1 if i % 4 < 2 else 1
            angle = -16 * t + shake * 2.0
            xoff = round(-78 * t + shake * 8)
        else:
            angle = -10 * max(t, 0)
            xoff = round(-46 * max(t, 0))

        yoff = 0 if i < 18 else round(18 * max(t, 0))
        frame = transformed_sprite(sprite, angle, xoff, yoff)
        draw = ImageDraw.Draw(frame, "RGBA")
        if 17 <= i <= 25:
            pulse = 1 - abs(i - 21) / 5
            star(draw, TARGET_CENTER_X + 235, 340, round(30 + 14 * pulse), (255, 220, 40, 230))
            draw.line((TARGET_CENTER_X + 300, 320, TARGET_CENTER_X + 210, 365), fill=(255, 80, 40, 190), width=8)
        if 18 <= i <= 34:
            overlay = Image.new("RGBA", (W, H), (255, 0, 0, 0))
            overlay_alpha = max(0, int(36 * (1 - (i - 18) / 16)))
            ImageDraw.Draw(overlay).rectangle((0, 0, W, H), fill=(255, 0, 0, overlay_alpha))
            frame = Image.alpha_composite(frame.convert("RGBA"), overlay).convert("RGB")
        frames.append(frame)

    out = OUT_DIR / "04_Hit_QC_controlled_60fps.mp4"
    render_mp4(frames, out)
    return out


def build_death(sprite: Image.Image) -> Path:
    rng_particles = []
    for p in range(90):
        rng_particles.append(
            (
                TARGET_CENTER_X - 120 + (p * 37) % 260,
                BASELINE_Y - 260 + (p * 53) % 220,
                2 + (p % 4),
                (p * 11) % 50,
            )
        )

    frames: list[Image.Image] = []
    for i in range(150):
        if i < 20:
            frame = transformed_sprite(sprite, 0)
        elif i < 45:
            t = (i - 20) / 25
            frame = transformed_sprite(sprite, -10 * t, round(-20 * t), round(12 * t))
        elif i < 82:
            t = (i - 45) / 37
            ease = 1 - (1 - t) * (1 - t)
            frame = transformed_sprite(sprite, -82 * ease, round(70 * ease), round(70 * ease))
        elif i < 112:
            t = (i - 82) / 30
            frame = transformed_sprite(sprite, -82, 70, 70, opacity=1 - 0.65 * t)
        else:
            frame = Image.new("RGB", (W, H), GREEN)

        draw = ImageDraw.Draw(frame, "RGBA")
        if i >= 92:
            t = min(1.0, (i - 92) / 58)
            for x, y, r, phase in rng_particles:
                yy = y - int(t * (90 + phase))
                alpha = int(220 * (1 - t))
                if alpha > 0:
                    draw.ellipse((x - r, yy - r, x + r, yy + r), fill=(255, 225, 115, alpha))
                    if r > 3:
                        draw.ellipse((x - 1, yy - 1, x + 1, yy + 1), fill=(255, 255, 255, alpha))
        frames.append(frame)

    out = OUT_DIR / "05_Death_QC_controlled_60fps.mp4"
    render_mp4(frames, out)
    return out


def build_attack() -> Path:
    out = OUT_DIR / "03_Attack_QC_shifted_60fps.mp4"
    with tempfile.TemporaryDirectory() as td:
        tdp = Path(td)
        run(
            [
                "ffmpeg",
                "-hide_banner",
                "-loglevel",
                "error",
                "-y",
                "-i",
                str(ATTACK_MP4),
                "-vf",
                "fps=60,crop=1280:720:0:0,pad=1280:720:0:0:color=0x00ff00,setsar=1,format=rgba",
                str(tdp / "frame_%04d.png"),
            ]
        )
        frames = []
        for p in sorted(tdp.glob("frame_*.png")):
            img = Image.open(p).convert("RGB")
            canvas = Image.new("RGB", (W, H), GREEN)
            canvas.paste(img.crop((28, 0, W, H)), (0, 0))
            frames.append(canvas)
    render_mp4(frames, out)
    return out


def normalize_idle() -> Path:
    out = OUT_DIR / "01_Idle_QC_approved_60fps.mp4"
    shutil.copy2(IDLE_MP4, out)
    return out


def contact_sheet(video: Path) -> Path:
    out = video.with_name(video.stem + "_contact.png")
    run(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",
            "-i",
            str(video),
            "-vf",
            "select='not(mod(n,6))',scale=200:-1,tile=6x5",
            "-frames:v",
            "1",
            "-update",
            "1",
            str(out),
        ]
    )
    return out


def concat_videos(videos: list[Path], out: Path) -> None:
    norm_dir = OUT_DIR / "_norm"
    norm_dir.mkdir(parents=True, exist_ok=True)
    lines = []
    for i, v in enumerate(videos):
        n = norm_dir / f"{i:02d}_{v.stem}.mp4"
        run(
            [
                "ffmpeg",
                "-hide_banner",
                "-loglevel",
                "error",
                "-y",
                "-i",
                str(v),
                "-vf",
                "fps=60,scale=1280:720,setsar=1,format=yuv420p",
                "-an",
                "-c:v",
                "libx264",
                "-preset",
                "veryfast",
                "-crf",
                "18",
                "-pix_fmt",
                "yuv420p",
                "-r",
                "60",
                "-video_track_timescale",
                "15360",
                "-movflags",
                "+faststart",
                str(n),
            ]
        )
        lines.append(f"file '{n.as_posix()}'\n")
    concat_file = OUT_DIR / "concat_basic.txt"
    concat_file.write_text("".join(lines), encoding="utf-8")
    run(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",
            "-f",
            "concat",
            "-safe",
            "0",
            "-i",
            str(concat_file),
            "-c",
            "copy",
            "-movflags",
            "+faststart",
            str(out),
        ]
    )


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    sprite = sprite_from_idle()
    videos = [
        normalize_idle(),
        build_walk(),
        build_attack(),
        build_hit(sprite),
        build_death(sprite),
    ]
    for v in videos:
        contact_sheet(v)
    final = OUT_DIR / "GAME_SIAM_BASIC_REQUIRED_CONTROLLED_QC_60fps.mp4"
    concat_videos(videos, final)
    contact_sheet(final)
    print("FINAL=" + str(final))
    for v in videos:
        print("SEGMENT=" + str(v))


if __name__ == "__main__":
    main()
