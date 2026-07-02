#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw


def is_key(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, a = pixel
    return a == 0 or (g > 140 and r < 110 and b < 110 and g > r * 1.45 and g > b * 1.45)


def find_clusters(image: Image.Image, expected: int) -> list[tuple[int, int, int, int]]:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size
    columns: list[tuple[int, int]] = []
    in_run = False
    start = 0

    for x in range(width):
        count = 0
        for y in range(height):
            if not is_key(pixels[x, y]):
                count += 1
        has_sprite = count > 4
        if has_sprite and not in_run:
            start = x
            in_run = True
        elif not has_sprite and in_run:
            if x - start > 20:
                columns.append((start, x - 1))
            in_run = False
    if in_run:
        columns.append((start, width - 1))

    clusters: list[tuple[int, int, int, int]] = []
    for x0, x1 in columns:
        ys = []
        for y in range(height):
            for x in range(x0, x1 + 1):
                if not is_key(pixels[x, y]):
                    ys.append(y)
                    break
        if ys:
            clusters.append((x0, min(ys), x1, max(ys)))

    clusters = sorted(clusters, key=lambda box: (box[2] - box[0]) * (box[3] - box[1]), reverse=True)[:expected]
    return sorted(clusters, key=lambda box: box[0])


def remove_key(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            if is_key(pixels[x, y]):
                pixels[x, y] = (0, 0, 0, 0)
    return rgba


def main() -> int:
    parser = argparse.ArgumentParser(description="Normalize one imagegen sprite strip into fixed-size cells.")
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--frames-dir", required=True, type=Path)
    parser.add_argument("--contact", required=True, type=Path)
    parser.add_argument("--report", required=True, type=Path)
    parser.add_argument("--cell", type=int, default=64)
    parser.add_argument("--frames", type=int, default=6)
    args = parser.parse_args()

    raw = Image.open(args.input).convert("RGBA")
    clusters = find_clusters(raw, args.frames)
    if len(clusters) != args.frames:
        raise SystemExit(f"expected {args.frames} clusters, got {len(clusters)}: {clusters}")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.frames_dir.mkdir(parents=True, exist_ok=True)
    args.contact.parent.mkdir(parents=True, exist_ok=True)
    args.report.parent.mkdir(parents=True, exist_ok=True)

    strip = Image.new("RGBA", (args.cell * args.frames, args.cell), (0, 0, 0, 0))
    contact = Image.new("RGBA", (args.cell * args.frames, args.cell * 2), (18, 18, 22, 255))
    draw = ImageDraw.Draw(contact)

    for index, (x0, y0, x1, y1) in enumerate(clusters):
        pad = 8
        crop = raw.crop((max(0, x0 - pad), max(0, y0 - pad), min(raw.width, x1 + pad + 1), min(raw.height, y1 + pad + 1)))
        crop = remove_key(crop)
        bbox = crop.getbbox()
        if bbox:
            crop = crop.crop(bbox)

        scale = min((args.cell - 6) / crop.width, (args.cell - 4) / crop.height)
        width = max(1, int(round(crop.width * scale)))
        height = max(1, int(round(crop.height * scale)))
        resized = crop.resize((width, height), Image.Resampling.NEAREST)
        frame = Image.new("RGBA", (args.cell, args.cell), (0, 0, 0, 0))
        frame.alpha_composite(resized, ((args.cell - width) // 2, args.cell - 2 - height))
        frame.save(args.frames_dir / f"{index:02d}.png")
        strip.alpha_composite(frame, (args.cell * index, 0))
        contact.alpha_composite(frame, (args.cell * index, 0))
        contact.alpha_composite(frame.resize((args.cell, args.cell), Image.Resampling.NEAREST), (args.cell * index, args.cell))
        draw.text((args.cell * index + 2, args.cell - 10), str(index + 1), fill=(235, 220, 170, 255))

    strip.save(args.output)
    contact.convert("RGB").save(args.contact, quality=95)
    args.report.write_text(
        json.dumps(
            {
                "source": str(args.input),
                "output": str(args.output),
                "method": "imagegen_source_component_extract_normalize_to_fixed_cells",
                "native_fixed_cell": False,
                "accepted_for_runtime": False,
                "cell": args.cell,
                "frames": args.frames,
                "clusters": clusters,
            },
            indent=2,
        ),
        encoding="utf-8",
    )
    print(args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
