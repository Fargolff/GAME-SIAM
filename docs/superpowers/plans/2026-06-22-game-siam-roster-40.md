# GAME SIAM IDLE Roster 40 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce 40 GAME SIAM IDLE characters as native 64x64 pixel-art spritesheets using `game-character-sprites`.

**Architecture:** Each character has one isolated run folder under `run/game-siam-roster-40/characters/<character_id>`. The pipeline creates 48 generated strips per character, assembles six action sheets, validates geometry/motion/provenance, exports GIF/WebP previews, then copies final sheets into Unity assets.

**Tech Stack:** Codex imagegen, `game-character-sprites` scripts, Python 3, Pillow, Unity 2D asset folders.

---

### Task 1: Normalize Roster Inputs

**Files:**
- Existing: `C:\Users\ADMIN\.codex\attachments\032d3ec8-5624-41b9-b927-22c4334a5b3c\pasted-text.txt`
- Existing: `C:\Users\ADMIN\.codex\attachments\d659d27b-b410-4d8b-a444-2b991d46a245\pasted-text.txt`
- Create: `run/game-siam-roster-40/roster-index.json`
- Create: `run/game-siam-roster-40/production-scope.json`
- Create: `run/game-siam-roster-40/character-specs/<character_id>.json`

- [x] **Step 1: Parse 40 roster entries**

Run:

```powershell
python Tools\parse_game_siam_roster.py
```

Expected:

```text
40
C:\Users\ADMIN\Documents\GAME IDLE\run\game-siam-roster-40\roster-index.json
```

- [ ] **Step 2: Create one character spec per roster entry**

Each spec must include:

```json
{
  "index": 1,
  "rank": "S",
  "character_id": "S01_GARUDA_VAYUDEJ",
  "thai_name": "วายุเดช",
  "title": "ราชันปักษาสุริย์",
  "visual_identity_lock": "ราชันครุฑหนุ่ม, เกราะไทยประยุกต์สีทองแดง แดงชาด และดำสนิท, ปีกใหญ่ทรงสามเหลี่ยม",
  "weapon_prop": "ทวนสุริยะ",
  "attack_01_idea": "แทงหรือฟันทวนระยะประชิด",
  "skill_01_idea": "ตั้งทวนแล้วพุ่งแทงเป็นเส้นตรง ก่อนกางปีกกระแทก AoE",
  "rig_asymmetry_mirror_warning": "ปีกและทวนไม่ควร mirror ลดทิศ",
  "english_prompt_seed": "Thai mythic young Garuda king, bronze gold crimson black armor, huge triangular wings, long solar spear"
}
```

### Task 2: Initialize Character Run Folder

**Files:**
- Create: `run/game-siam-roster-40/characters/<character_id>/run-manifest.json`
- Create: `run/game-siam-roster-40/characters/<character_id>/64/prompts/*.txt`

- [ ] **Step 1: Initialize a character**

Run:

```powershell
python Tools\game_siam_sprite_pipeline.py init-character S01_GARUDA_VAYUDEJ
```

Expected:

```text
run/game-siam-roster-40/characters/S01_GARUDA_VAYUDEJ
```

- [ ] **Step 2: Verify prompt count**

Run:

```powershell
(Get-ChildItem -File run\game-siam-roster-40\characters\S01_GARUDA_VAYUDEJ\64\prompts | Measure-Object).Count
```

Expected:

```text
49
```

### Task 3: Generate Canonical Base

**Files:**
- Create: `run/game-siam-roster-40/characters/<character_id>/source/canonical-base-sprite.png`

- [ ] **Step 1: Generate base with imagegen**

Use the prompt in:

```text
run/game-siam-roster-40/characters/<character_id>/64/prompts/canonical-base.txt
```

- [ ] **Step 2: Capture latest generated image**

Run:

```powershell
python Tools\game_siam_sprite_pipeline.py capture-base S01_GARUDA_VAYUDEJ
```

Expected:

```text
run/game-siam-roster-40/characters/S01_GARUDA_VAYUDEJ/source/canonical-base-sprite.png
```

- [ ] **Step 3: Inspect base**

Accept only if the identity is readable and no key props are impossible to fit inside 64x64 animation cells.

### Task 4: Produce One Action

**Files:**
- Create: `run/game-siam-roster-40/characters/<character_id>/source/64-<action>-<direction>.png`
- Create: `run/game-siam-roster-40/characters/<character_id>/64/generated/<action>-<direction>.png`
- Create: `run/game-siam-roster-40/characters/<character_id>/64/final/<action>-sheet-clean.png`
- Create: `run/game-siam-roster-40/characters/<character_id>/64/qa/<action>-validation.json`
- Create: `run/game-siam-roster-40/characters/<character_id>/64/qa/<action>-contact-sheet.png`
- Create: `run/game-siam-roster-40/characters/<character_id>/64/qa/previews/<action>-*.gif`
- Create: `run/game-siam-roster-40/characters/<character_id>/64/qa/previews/<action>-*.webp`

- [ ] **Step 1: Generate each direction strip**

Use each row prompt in:

```text
run/game-siam-roster-40/characters/<character_id>/64/prompts/<action>-<direction>.txt
```

After each imagegen result:

```powershell
python Tools\game_siam_sprite_pipeline.py capture-strip S01_GARUDA_VAYUDEJ idle south
```

- [ ] **Step 2: Assemble and validate the action**

Run:

```powershell
python Tools\game_siam_sprite_pipeline.py assemble-action S01_GARUDA_VAYUDEJ idle
```

Expected action sheet:

```text
run/game-siam-roster-40/characters/S01_GARUDA_VAYUDEJ/64/final/idle-sheet-clean.png
```

- [ ] **Step 3: Visual inspect contact sheet**

Open:

```text
run/game-siam-roster-40/characters/S01_GARUDA_VAYUDEJ/64/qa/idle-contact-sheet.png
```

Regenerate only failed rows.

### Task 5: Complete Character

**Files:**
- Create final action sheets for: `idle`, `walk`, `attack_01`, `skill_01`, `hurt`, `death`
- Create: `run/game-siam-roster-40/characters/<character_id>/64/qa/visual-review.json`
- Copy to: `Assets/Art/Characters/GameSiam/<character_id>/`

- [ ] **Step 1: Complete all six actions**

Run one action at a time in this order:

```text
idle
walk
attack_01
skill_01
hurt
death
```

- [ ] **Step 2: Validate manifest**

Run:

```powershell
python C:\Users\ADMIN\.codex\skills\game-character-sprites\scripts\validate_run_manifest.py --manifest run\game-siam-roster-40\characters\S01_GARUDA_VAYUDEJ\run-manifest.json --required-sizes 64 --required-actions idle,walk,attack_01,skill_01,hurt,death --required-directions south,south-east,east,north-east,north,north-west,west,south-west --require-visual-review
```

- [ ] **Step 3: Copy final files into Unity**

Run:

```powershell
python Tools\game_siam_sprite_pipeline.py copy-final-to-assets S01_GARUDA_VAYUDEJ
```

### Task 6: Batch Order

**Files:**
- Update: `run/game-siam-roster-40/production-progress.json`

- [ ] **Step 1: Finish Rank S first**

Order:

```text
S01_GARUDA_VAYUDEJ
S02_NAGA_SASINAKA
S03_YAKSHA_KRAIASURA
```

- [ ] **Step 2: Continue by rank**

Order:

```text
A01-A07
B01-B10
C01-C10
D01-D10
```

- [ ] **Step 3: Stop after each character for QA**

Do not batch-generate multiple characters before visual review. The cost of one bad identity pattern repeated 48 times is too high.

---

Self-review:
- Spec coverage: 64x64 native, six actions, eight directions, per-action sheets, metadata, QA, GIF/WebP previews, Unity output covered.
- Placeholder scan: no TBD/TODO entries.
- Type consistency: action names use `attack_01` and `skill_01` throughout.
