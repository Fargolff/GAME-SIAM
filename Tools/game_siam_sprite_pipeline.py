from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path


WORKSPACE = Path(r"C:\Users\ADMIN\Documents\GAME IDLE")
RUN_ROOT = WORKSPACE / "run" / "game-siam-roster-40"
ASSET_ROOT = WORKSPACE / "Assets" / "Art" / "Characters" / "GameSiam"
SKILL = Path(r"C:\Users\ADMIN\.codex\skills\game-character-sprites")
GEN_ROOT = Path(r"C:\Users\ADMIN\.codex\generated_images\019eeee0-fccc-7010-8677-973adb88bcb9")

CELL = 64
COLUMNS = 6
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
ACTIONS = {
    "idle": {"fps": 6, "loop": True, "unique": 4, "palette": 64},
    "walk": {"fps": 10, "loop": True, "unique": 6, "palette": 64},
    "attack_01": {"fps": 12, "loop": False, "unique": 6, "palette": 96},
    "skill_01": {"fps": 12, "loop": False, "unique": 6, "palette": 96},
    "hurt": {"fps": 12, "loop": False, "unique": 3, "palette": 96},
    "death": {"fps": 8, "loop": False, "unique": 6, "palette": 96},
}
DIRECTION_TEXT = {
    "south": "south, front-facing toward camera",
    "south-east": "south-east, front three-quarter facing screen-right",
    "east": "east, side-facing screen-right",
    "north-east": "north-east, back three-quarter facing screen-right, back of head and body visible, no front face",
    "north": "north, fully back-facing, back of head and body visible, no eyes, no front face",
    "north-west": "north-west, back three-quarter facing screen-left, back of head and body visible, no front face",
    "west": "west, side-facing screen-left",
    "south-west": "south-west, front three-quarter facing screen-left",
}
ACTION_TEXT = {
    "idle": "idle breathing loop, 4 unique poses padded to 6 cells, subtle body bob, equipment moves slightly, feet anchored near x=32 y=54",
    "walk": "walk loop with contact, down, passing, up, contact, passing poses, alternating feet, no frame drift",
    "attack_01": "normal attack, ready, anticipation, swing or shot, impact, follow-through, recovery",
    "skill_01": "active skill animation, anticipation, charge, ready, release, follow-through, recovery",
    "hurt": "hurt flinch, impact, recoil, recover, 3 unique poses padded to 6 cells, non-looping",
    "death": "death animation, fatal impact, lose balance, fall, collapse, settled, final hold, no gore",
}


def character_dir(character_id: str) -> Path:
    return RUN_ROOT / "characters" / character_id


def load_spec(character_id: str) -> dict[str, object]:
    path = RUN_ROOT / "character-specs" / f"{character_id}.json"
    return json.loads(path.read_text(encoding="utf-8-sig"))


def run_cmd(args: list[str]) -> None:
    subprocess.run(args, check=True)


def latest_generated() -> Path:
    return max(GEN_ROOT.glob("*.png"), key=lambda p: p.stat().st_mtime)


def row_prompt(spec: dict[str, object], action: str, direction: str) -> str:
    return "\n".join(
        [
            "64x64 pixel-art game sprite animation strip for GAME SIAM IDLE.",
            "One horizontal row of exactly 6 separated full-body frames, each frame designed for one native 64x64 cell.",
            f"Action: {ACTION_TEXT[action]}.",
            f"Direction: {DIRECTION_TEXT[direction]}.",
            f"Character identity lock: {spec['english_prompt_seed']}",
            f"Must preserve: {spec['visual_identity_lock']}",
            f"Weapon/prop: {spec['weapon_prop']}",
            f"Action detail: {spec['attack_01_idea'] if action == 'attack_01' else spec['skill_01_idea'] if action == 'skill_01' else 'preserve the same character identity and equipment'}",
            "Top-down three-quarter cute fantasy RPG style, readable silhouette, hard pixel edges, limited consistent palette.",
            f"Flat pure solid chroma-key background {KEY}, clear green space between frames.",
            "No gradient, no rounded panel, no shadow, no floor, no UI, no text, no frame numbers, no border.",
            "Every frame centered with 2-4 px margin; body, wings, tail, weapon, and props must not be cropped.",
        ]
    )


def init_character(character_id: str) -> None:
    spec = load_spec(character_id)
    root = character_dir(character_id)
    for rel in ["source", "64/generated", "64/prompts", "64/frames", "64/final", "64/qa/previews"]:
        (root / rel).mkdir(parents=True, exist_ok=True)

    base_prompt = "\n".join(
        [
            "64x64 pixel-art game sprite, single GAME SIAM IDLE character, top-down three-quarter cute fantasy RPG style.",
            f"Character identity lock: {spec['english_prompt_seed']}",
            f"Must preserve: {spec['visual_identity_lock']}",
            f"Weapon/prop: {spec['weapon_prop']}",
            "Transparent or flat pure #00ff00 chroma-key background, readable silhouette, hard pixel edges, limited palette.",
            "No UI, no text, no frame border, no floor, no shadow. Full body centered with foot anchor near x=32 y=54.",
        ]
    )
    (root / "64/prompts/canonical-base.txt").write_text(base_prompt + "\n", encoding="utf-8")
    for action in ACTIONS:
        for direction in DIRECTIONS:
            (root / "64" / "prompts" / f"{action}-{direction}.txt").write_text(
                row_prompt(spec, action, direction) + "\n", encoding="utf-8"
            )

    manifest = {
        "reference": {
            "source_type": "file",
            "source": f"character-specs/{character_id}.json",
            "used_for_generation": True,
            "identity_notes": [
                str(spec["english_prompt_seed"]),
                str(spec["visual_identity_lock"]),
                str(spec["weapon_prop"]),
            ],
        },
        "scope": {
            "sizes": [CELL],
            "actions": list(ACTIONS),
            "directions": DIRECTIONS,
            "frames": {action: COLUMNS for action in ACTIONS},
            "cell": CELL,
            "columns": COLUMNS,
            "key_color": KEY,
            "foot_anchor": {"x": 32, "y": 54},
        },
        "generation": {
            "method": "imagegen",
            "imagegen_output_path": "source/canonical-base-sprite.png",
            "procedural": False,
            "text_only": False,
            "imported_contact_sheet": False,
        },
        "strips": [],
        "visual_review": {"path": "64/qa/visual-review.json"},
    }
    (root / "run-manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(root)


def capture_base(character_id: str) -> None:
    root = character_dir(character_id)
    source = root / "source" / "canonical-base-sprite.png"
    shutil.copy2(latest_generated(), source)
    print(source)


def capture_strip(character_id: str, action: str, direction: str, input_path: str | None = None) -> None:
    if action not in ACTIONS or direction not in DIRECTIONS:
        raise SystemExit("unknown action or direction")
    root = character_dir(character_id)
    source = root / "source" / f"64-{action}-{direction}.png"
    generated = root / "64" / "generated" / f"{action}-{direction}.png"
    imagegen_path = Path(input_path) if input_path else latest_generated()
    shutil.copy2(imagegen_path, source)
    shutil.copy2(source, generated)

    manifest_path = root / "run-manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    manifest["strips"] = [
        strip
        for strip in manifest["strips"]
        if not (strip["cell"] == CELL and strip["action"] == action and strip["direction"] == direction)
    ]
    manifest["strips"].append(
        {
            "cell": CELL,
            "action": action,
            "direction": direction,
            "method": "imagegen",
            "imagegen_output_path": f"source/64-{action}-{direction}.png",
            "source_path": f"64/generated/{action}-{direction}.png",
            "prompt_path": f"64/prompts/{action}-{direction}.txt",
        }
    )
    manifest["strips"].sort(key=lambda strip: (strip["action"], DIRECTIONS.index(strip["direction"])))
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(source)


def assemble_action(character_id: str, action: str) -> None:
    root = character_dir(character_id)
    final = root / "64" / "final"
    qa = root / "64" / "qa"
    palette = str(ACTIONS[action]["palette"])
    dirs = ",".join(DIRECTIONS)
    sheet = final / f"{action}-sheet.png"
    clean = final / f"{action}-sheet-clean.png"
    run_cmd(
        [
            sys.executable,
            str(SKILL / "scripts/assemble_action_sheet.py"),
            "--input-dir",
            str(root / "64/generated"),
            "--output",
            str(sheet),
            "--action",
            action,
            "--directions",
            dirs,
            "--cell",
            str(CELL),
            "--columns",
            str(COLUMNS),
            "--frames-dir",
            str(root / "64/frames"),
            "--metadata",
            str(final / f"{action}-metadata.json"),
            "--key-color",
            KEY,
        ]
    )
    run_cmd(
        [
            sys.executable,
            str(SKILL / "scripts/pixel_snap.py"),
            "--input",
            str(sheet),
            "--output",
            str(clean),
            "--cell",
            str(CELL),
            "--palette",
            palette,
            "--alpha-threshold",
            "12",
            "--chroma-key",
            KEY,
            "--edge-flood-threshold",
            "105",
            "--residue-threshold",
            "72",
        ]
    )
    run_cmd(
        [
            sys.executable,
            str(SKILL / "scripts/validate_sheet.py"),
            "--input",
            str(clean),
            "--rows",
            str(len(DIRECTIONS)),
            "--columns",
            str(COLUMNS),
            "--cell",
            str(CELL),
            "--row-names",
            dirs,
            "--chroma-key",
            KEY,
            "--json-out",
            str(qa / f"{action}-validation.json"),
            "--contact-sheet",
            str(qa / f"{action}-contact-sheet.png"),
        ]
    )
    if action == "walk":
        run_cmd(
            [
                sys.executable,
                str(SKILL / "scripts/audit_sprite_motion.py"),
                "--input",
                str(clean),
                "--rows",
                str(len(DIRECTIONS)),
                "--columns",
                str(COLUMNS),
                "--cell",
                str(CELL),
                "--row-names",
                dirs,
                "--json-out",
                str(qa / "walk-motion-audit.json"),
            ]
        )
    run_cmd(
        [
            sys.executable,
            str(SKILL / "scripts/export_animation_previews.py"),
            "--atlas",
            str(clean),
            "--rows",
            str(len(DIRECTIONS)),
            "--columns",
            str(COLUMNS),
            "--cell",
            str(CELL),
            "--row-names",
            dirs,
            "--prefix",
            action,
            "--out-dir",
            str(qa / "previews"),
            "--scale",
            "4",
        ]
    )


def copy_final_to_assets(character_id: str) -> None:
    root = character_dir(character_id)
    dest = ASSET_ROOT / character_id
    dest.mkdir(parents=True, exist_ok=True)
    for action in ACTIONS:
        shutil.copy2(root / "64" / "final" / f"{action}-sheet-clean.png", dest / f"{action}-sheet-clean.png")
        shutil.copy2(root / "64" / "final" / f"{action}-metadata.json", dest / f"{action}-metadata.json")
    shutil.copy2(root / "run-manifest.json", dest / "run-manifest.json")
    print(dest)


def self_check() -> None:
    assert len(ACTIONS) == 6
    assert len(DIRECTIONS) == 8
    assert len(ACTIONS) * len(DIRECTIONS) == 48
    assert CELL * COLUMNS == 384
    print("ok")


def main() -> None:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("self-check")
    init = sub.add_parser("init-character")
    init.add_argument("character_id")
    base = sub.add_parser("capture-base")
    base.add_argument("character_id")
    strip = sub.add_parser("capture-strip")
    strip.add_argument("character_id")
    strip.add_argument("action")
    strip.add_argument("direction")
    strip.add_argument("--input")
    assemble = sub.add_parser("assemble-action")
    assemble.add_argument("character_id")
    assemble.add_argument("action")
    copy_assets = sub.add_parser("copy-final-to-assets")
    copy_assets.add_argument("character_id")
    args = parser.parse_args()

    if args.cmd == "self-check":
        self_check()
    elif args.cmd == "init-character":
        init_character(args.character_id)
    elif args.cmd == "capture-base":
        capture_base(args.character_id)
    elif args.cmd == "capture-strip":
        capture_strip(args.character_id, args.action, args.direction, args.input)
    elif args.cmd == "assemble-action":
        assemble_action(args.character_id, args.action)
    elif args.cmd == "copy-final-to-assets":
        copy_final_to_assets(args.character_id)


if __name__ == "__main__":
    main()
