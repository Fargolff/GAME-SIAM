#!/usr/bin/env python3
"""Remove conservative chroma-green fringe from generated runtime PNG assets."""

from __future__ import annotations

import argparse
import shutil
from pathlib import Path

from PIL import Image


DEFAULT_DIRS = (
    "assets/ui/generated",
    "assets/vfx/generated",
    "assets/characters/GameSiam",
)


def is_keylike_green(r: int, g: int, b: int) -> bool:
    return g >= 145 and r <= 90 and b <= 130 and g - r >= 50 and g - b >= 25


def is_strict_chroma_green(r: int, g: int, b: int) -> bool:
    return g >= 200 and r <= 70 and b <= 100 and g - r >= 120 and g - b >= 100


def touches_transparent(pixels, width: int, height: int, x: int, y: int) -> bool:
    for nx in range(max(0, x - 1), min(width, x + 2)):
        for ny in range(max(0, y - 1), min(height, y + 2)):
            if nx == x and ny == y:
                continue
            if pixels[nx, ny][3] == 0:
                return True
    return False


def clean_image(path: Path, write: bool) -> dict[str, int]:
    if path.stem.endswith("_raw") or path.stem.endswith("_source"):
        return {
            "transparent_rgb_fixed": 0,
            "semi_removed": 0,
            "strict_edge_removed": 0,
            "changed": 0,
        }

    with Image.open(path) as opened:
        image = opened.convert("RGBA")

    is_character_sheet = "assets\\characters\\GameSiam" in str(path) or "assets/characters/GameSiam" in str(path)
    pixels = image.load()
    width, height = image.size
    transparent_rgb_fixed = 0
    semi_removed = 0
    strict_edge_removed = 0

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                if is_keylike_green(r, g, b):
                    pixels[x, y] = (0, 0, 0, 0)
                    transparent_rgb_fixed += 1
                continue

            if 0 < a < 245 and is_keylike_green(r, g, b):
                if touches_transparent(pixels, width, height, x, y):
                    pixels[x, y] = (0, 0, 0, 0)
                    semi_removed += 1
            elif not is_character_sheet and a >= 245 and is_strict_chroma_green(r, g, b):
                if touches_transparent(pixels, width, height, x, y):
                    pixels[x, y] = (0, 0, 0, 0)
                    strict_edge_removed += 1

    changed = transparent_rgb_fixed + semi_removed + strict_edge_removed
    if write and changed:
        image.save(path)

    return {
        "transparent_rgb_fixed": transparent_rgb_fixed,
        "semi_removed": semi_removed,
        "strict_edge_removed": strict_edge_removed,
        "changed": changed,
    }


def iter_pngs(project_dir: Path) -> list[Path]:
    pngs: list[Path] = []
    for relative in DEFAULT_DIRS:
        root = project_dir / relative
        if root.exists():
            pngs.extend(sorted(root.rglob("*.png")))
    return pngs


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", default=".")
    parser.add_argument("--write", action="store_true")
    parser.add_argument("--backup-dir", default="")
    args = parser.parse_args()

    project_dir = Path(args.project).resolve()
    backup_root = Path(args.backup_dir).resolve() if args.backup_dir else None
    total_changed = 0
    files_changed = 0

    for path in iter_pngs(project_dir):
        before = clean_image(path, False)
        if before["changed"] == 0:
            continue
        files_changed += 1
        total_changed += before["changed"]
        rel = path.relative_to(project_dir)
        print(
            f"{rel}\ttransparent={before['transparent_rgb_fixed']}"
            f"\tsemi={before['semi_removed']}\tstrict_edge={before['strict_edge_removed']}"
        )
        if args.write:
            if backup_root:
                backup_path = backup_root / rel
                backup_path.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(path, backup_path)
            clean_image(path, True)

    mode = "wrote" if args.write else "dry-run"
    print(f"{mode}: files_changed={files_changed} pixels_changed={total_changed}")


if __name__ == "__main__":
    main()
