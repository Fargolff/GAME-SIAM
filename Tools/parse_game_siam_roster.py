from __future__ import annotations

import json
import re
from pathlib import Path


ROSTER = Path(r"C:\Users\ADMIN\.codex\attachments\032d3ec8-5624-41b9-b927-22c4334a5b3c\pasted-text.txt")
OUT = Path(r"C:\Users\ADMIN\Documents\GAME IDLE\run\game-siam-roster-40\roster-index.json")


def current_rank(line: str, fallback: str) -> str:
    if "Rank S" in line:
        return "S"
    if "Rank A" in line:
        return "A"
    if "Rank B" in line:
        return "B"
    if "Rank C" in line:
        return "C"
    if "Rank D" in line:
        return "D"
    return fallback


def split_name(raw: str) -> tuple[str, str]:
    parts = [part.strip() for part in raw.split("—", 1)]
    return (parts + [""])[:2]


def main() -> None:
    text = ROSTER.read_text(encoding="utf-8-sig")
    lines = text.splitlines()
    chars: list[dict[str, object]] = []
    rank = ""
    current: dict[str, object] | None = None
    body: list[str] = []

    for line in lines:
        rank = current_rank(line, rank)
        match = re.match(r"^(\d+)\.\s+(.+)$", line.strip())
        if match:
            if current:
                current["body"] = "\n".join(body).strip()
                chars.append(current)
            name, title = split_name(match.group(2))
            current = {"index": int(match.group(1)), "rank": rank, "thai_name": name, "title": title}
            body = []
            continue
        if current:
            body.append(line)
            id_match = re.match(r"^ID:\s*(\S+)", line.strip())
            if id_match:
                current["character_id"] = id_match.group(1)

    if current:
        current["body"] = "\n".join(body).strip()
        chars.append(current)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(chars, ensure_ascii=False, indent=2), encoding="utf-8")
    print(len(chars))
    print(OUT)


if __name__ == "__main__":
    main()
