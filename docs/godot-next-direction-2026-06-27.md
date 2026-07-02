# GAME SIAM IDLE: Godot Next Direction Research

Date: 2026-06-27

## Executive Decision

ทางที่ควรไปต่อ: **Godot 4.7 + GDScript + 2D top-down idle auto-battler / hero-collector prototype, PC-first, mobile later**.

ไม่ควรเริ่มจากเกม idle clicker ล้วน ๆ และไม่ควรเริ่มจาก full gacha/live-service เพราะโปรเจกต์มี asset ที่แพงที่สุดแล้วคือ **40 ตัวละคร mythic Siam พร้อม 6 actions x 8 directions**. จุดแข็งนี้ควรถูกโชว์ด้วยสนามรบที่ตัวละครเดิน โจมตี ใช้สกิล เจ็บ และตายได้จริง ไม่ใช่ UI ตัวเลขอย่างเดียว.

## What Exists Now

Local audit:

- Godot installed: `4.7.stable.official.5b4e0cb0f`
- Godot path: `C:\Users\ADMIN\AppData\Local\Programs\Godot\4.7-stable\Godot_v4.7-stable_win64.exe`
- Export templates: not installed yet
- Character roster: `40`
- Character ranks: `S=3, A=7, B=10, C=10, D=10`
- Dominant species/groups: `HUMAN=12`, `GARUDA=4`, `NAGA=4`, `SPIRIT=4`, plus many rare mythic types
- Final character sheets: `240`
- Metadata files: `240`
- Sheet storage size: about `42.17 MB`
- QC status: PASS, 0 failures, 2 non-blocking idle weak-motion warnings
- Sheet contract: `64x64`, `384x512` per action sheet, `6 frames x 8 directions`
- Actions: `idle`, `walk`, `attack_01`, `skill_01`, `hurt`, `death`
- Directions: `south`, `south-east`, `east`, `north-east`, `north`, `north-west`, `west`, `south-west`

Important constraint: do not regenerate sprite art unless explicitly requested. Use the passed outputs.

## External Research Notes

Godot:

- Godot 4.7 stable was released on 2026-06-18 and is the current stable Windows line.
- Godot standard build is self-contained; no heavy installation is needed.
- The installed build is the standard, non-.NET build, so the shortest path is **GDScript**.
- Godot docs support this asset shape directly: `AnimatedSprite2D` uses `SpriteFrames`, and Godot's 2D sprite animation workflow supports sprite sheets.
- Export templates are required only when exporting builds. They are not needed for prototype work inside the editor.

Market/product:

- Idle and auto-battler genres work because players make strategic prep decisions, then watch automated resolution.
- PC remains healthy for smaller and long-tail games; Newzoo's 2026 PC/console reporting highlights opportunity outside only the biggest titles.
- Mobile is still the biggest revenue platform, but it is also the most punishing for retention, ads, UA, live ops, and monetization. Build PC prototype first; port only after the loop is fun.

Sources:

- Godot Windows download: https://godotengine.org/download/windows/
- Godot 4.7 archive: https://godotengine.org/download/archive/4.7-stable/
- Godot AnimatedSprite2D docs: https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html
- Godot SpriteFrames docs: https://docs.godotengine.org/en/4.7/classes/class_spriteframes.html
- Godot 2D sprite animation docs: https://docs.godotengine.org/en/4.7/tutorials/2d/2d_sprite_animation.html
- Godot export docs: https://docs.godotengine.org/en/latest/tutorials/export/exporting_projects.html
- SteamDB Auto Battler tag definition: https://steamdb.info/tag/1084988/
- Newzoo 2026 PC & Console report page: https://newzoo.com/resources/trend-reports/the-pc-console-gaming-report-2026
- Newzoo 2026 global games market blog: https://newzoo.com/resources/blog/global-games-market-q2-2026

## Product Shape

Working title: **GAME SIAM IDLE**

One-line pitch:

> สะสมวีรชนและอสูรจากตำนานสยาม จัดทีม 5 ตัว วางตำแหน่ง แล้วปล่อยให้ทีมต่อสู้อัตโนมัติผ่าน wave, boss, และ offline progression.

Player fantasy:

- "ผมเป็นผู้จัดทัพตำนานสยาม"
- "ผมเลือกทีม วางตำแหน่ง อัปเกรด แล้วดูสนามรบเดินเอง"
- "ตัวละครแต่ละตัวมี identity ชัด ไม่ใช่แค่ stat card"

Primary verbs:

- collect hero
- inspect hero
- deploy team
- position units
- start wave
- watch auto battle
- trigger or queue skill later, but not in MVP
- upgrade hero
- claim idle rewards
- unlock deeper stages

Target session:

- First session: 8-12 minutes
- Return session: 1-4 minutes
- Background/idle check-in: 30-90 seconds

## Recommended MVP

MVP is not "all 40 characters playable." MVP is:

- 6 playable heroes
- 3 enemy archetypes using tinted/reused or selected existing sprites
- 1 battlefield
- 20 waves
- 1 boss wave
- local save
- offline rewards capped at 8 hours
- deploy 5 units
- auto-combat with simple targeting
- upgrade levels
- readable HUD
- one debug panel

Recommended first 6 heroes:

- `S01_GARUDA_VAYUDEJ` - premium frontliner signal
- `S02_NAGA_SASINAKA` - control mage
- `S03_YAKSHA_KRAIASURA` - tank
- `A02_TIGER_PLOENGPAYAK` - assassin/melee DPS
- `A03_HUMAN_ARUNRAT` - ranged DPS
- `A06_SPIRIT_RAMPAN_MASK` - debuff support

Why these:

- Covers tank, melee, ranged, mage, support, boss-worthy S rank.
- Uses strong visual variety.
- Gives enough combat roles to test team composition without loading all 40.

## Core Loop

1. Player opens camp screen.
2. Claims idle rewards.
3. Upgrades 1-2 heroes.
4. Edits formation.
5. Starts next wave.
6. Units fight automatically.
7. Win gives gold, essence, character shards, stage progress.
8. Lose gives partial rewards and suggests upgrade/formation changes.
9. Repeat until boss gate.

No energy system in prototype. No monetization. No online account. No gacha spend.

## Combat Model

Use deterministic simple combat first:

- 5 player units vs enemy wave
- Top-down 2D field
- Units move toward targets
- Targeting rule: nearest enemy unless role overrides
- Attack cooldown per unit
- Skill cooldown per unit
- Basic damage formula:
  - `damage = max(1, attack - defense * 0.35) * skill_multiplier`
- Roles:
  - Tank: high HP, taunt later
  - Melee DPS: closes distance
  - Ranged DPS: attacks from range
  - Mage: slower attack, AoE/status later
  - Support: buff/debuff later

MVP skills should be mostly visual + simple stat effect:

- Dash strike
- AoE pulse
- Taunt
- Slow/root
- Debuff attack
- Heal/shield

Delay complicated mechanics:

- true damage
- nested status interactions
- projectile collision
- summoning clones
- real-time manual skill timing
- PvP
- roguelike relic trees

## Why Godot Is The Right Next Move

Godot fits because:

- Your asset pack is 2D and already clean PNG/JSON.
- Godot's `AnimatedSprite2D` + `SpriteFrames` maps naturally to action/direction animations.
- GDScript keeps iteration fast.
- Scenes/resources are easy to generate from metadata.
- No engine license anxiety.
- Export can come later; editor prototype works now.

Use Godot standard build, not .NET:

- We installed standard Godot 4.7.
- C# would require the .NET build and extra setup.
- GDScript is enough for this MVP.

## Godot Project Structure

Create a new Godot project under:

```text
godot/game-siam-idle/
```

Keep old Unity workspace untouched for provenance. Do not move or mutate passed sprite outputs.

Recommended structure:

```text
godot/game-siam-idle/
  project.godot
  assets/
    characters/
      GameSiam/
        <character_id>/
          idle-sheet-clean.png
          idle-metadata.json
          walk-sheet-clean.png
          walk-metadata.json
          ...
  data/
    roster/
      characters.json
      hero_stats.json
      waves.json
  scenes/
    boot/
      Boot.tscn
    battle/
      Battle.tscn
      Unit.tscn
      Battlefield.tscn
    ui/
      Hud.tscn
      HeroCard.tscn
      FormationPanel.tscn
  scripts/
    core/
      sim_state.gd
      save_game.gd
      fixed_tick.gd
    combat/
      unit_model.gd
      combat_system.gd
      targeting_system.gd
      wave_system.gd
    presentation/
      unit_view.gd
      sprite_animator.gd
      direction_resolver.gd
    tools/
      import_gamesiam_roster.gd
  generated/
    spriteframes/
      <character_id>.tres
```

## Asset Import Plan

Do not split 11,520 frame PNGs manually. The lazy correct path is:

1. Copy 240 final sheets + metadata into Godot.
2. Generate `SpriteFrames` resources from each character's six sheets.
3. Animation names:
   - `idle_south`
   - `walk_south`
   - `attack_01_south`
   - `skill_01_south`
   - `hurt_south`
   - `death_south`
   - same for all directions
4. Use `AtlasTexture` regions pointing at the source sheet.
5. Set loops:
   - `idle_*`: loop
   - `walk_*`: loop
   - `attack_01_*`: no loop
   - `skill_01_*`: no loop
   - `hurt_*`: no loop or short return
   - `death_*`: no loop, freeze last frame
6. Use metadata JSON to avoid hardcoding rows/columns.

Import settings:

- filter: off / nearest
- mipmaps: off
- compression: lossless or no destructive compression
- keep transparent alpha
- pixel snap/camera integer scaling later

## Simulation Architecture

Separate simulation from rendering:

- Simulation owns HP, position, cooldowns, targets, wave state, rewards, save data.
- Rendering owns sprites, animation playback, camera, FX, UI.
- Save serializes simulation/economy state only.

Why this matters:

- Idle games become impossible to balance if state is hidden inside scene nodes.
- Offline rewards need pure data simulation.
- Playtests need deterministic reproduction.

Core data types:

```text
HeroDefinition
  id
  rank
  role
  species
  base_stats
  attack_range
  attack_cooldown
  skill_cooldown
  skill_id

HeroInstance
  definition_id
  level
  stars
  xp
  unlocked

BattleUnit
  team
  hero_id
  hp
  position
  target_id
  attack_timer
  skill_timer
  state

BattleState
  wave_id
  elapsed
  units
  result
```

## UI Direction

UI should feel like a compact game command surface, not a dashboard.

Persistent battle HUD:

- Top-left: wave/stage
- Top-right: speed toggle and pause
- Bottom: 5 deployed hero portraits with HP/skill cooldown
- Center field: clear, no large panels

Camp screen:

- Left: roster list
- Center: selected hero preview and stats
- Right/bottom: upgrade/deploy buttons

Use Thai mythic tone but keep UI utilitarian:

- dark lacquer / gold / red accents
- readable sans font first
- ornate detail only in headers/cards
- no huge decorative panels blocking battle

## Economy Direction

MVP currencies:

- Gold: level upgrades
- Essence: rank/star upgrades later
- Shards: unlock heroes later

Prototype reward formula:

- clear wave: gold + small essence
- boss: higher essence + shard chance
- offline: gold based on highest cleared wave, capped 8h

Delay:

- paid currency
- stamina
- daily quests
- battle pass
- shop
- ad rewards

## Content Direction

The 40 characters are too many for first playable, but perfect for staged unlocks.

Launch content plan:

- Tier 0 prototype: 6 heroes
- Vertical slice: 12 heroes
- Demo: 20 heroes
- Full content pass: 40 heroes

Rarity distribution:

- S: late chase / boss unlock / premium story reward
- A: main progression anchors
- B/C: common team-build glue
- D: early unlock and specialist counters

Avoid building a gacha before the game is fun. Use deterministic unlocks first.

## Codex Execution Plan

### Phase 1: Create Godot Project + Importer

Goal: open Godot project and show one animated hero in an empty scene.

Tasks:

- create `godot/game-siam-idle/project.godot`
- copy only required first 6 hero sheets into `godot/game-siam-idle/assets/characters/GameSiam`
- create import script that reads metadata and generates `SpriteFrames`
- create `Unit.tscn` with `AnimatedSprite2D`
- create `Battle.tscn` with one hero playing `idle_south`
- run Godot headless version check and open project once

Acceptance:

- Godot opens project
- one character visible
- `idle_south` loops
- no art regenerated
- generated resources are deterministic

### Phase 2: Movement + Direction Resolver

Goal: one unit can walk toward a target and face correct 8-way direction.

Tasks:

- implement `direction_resolver.gd`
- map velocity vector to existing 8 directions
- switch `idle_*` / `walk_*`
- add debug target point

Acceptance:

- unit plays walk animation when moving
- returns to idle when stopped
- no wrong row mapping

### Phase 3: Auto-Combat Vertical Slice

Goal: 3v3 auto battle with win/loss.

Tasks:

- define hero stats for 6 heroes
- define enemy stats for 3 enemy types
- implement fixed tick combat
- implement nearest-target behavior
- implement basic attack and death state
- show HP bars

Acceptance:

- units acquire targets
- attacks reduce HP
- death animation plays
- battle ends with win/loss
- simulation can restart cleanly

### Phase 4: Formation + 5v5 Waves

Goal: player deploys 5 units and clears waves.

Tasks:

- create formation data
- create simple formation UI
- create wave definitions 1-20
- add battle speed toggle: 1x/2x
- add post-battle reward screen

Acceptance:

- 5 deployed units spawn in formation
- wave result gives rewards
- next wave loads

### Phase 5: Progression + Save

Goal: idle game loop exists.

Tasks:

- local save file
- gold upgrades
- highest wave
- offline reward calculation
- simple roster unlock flags

Acceptance:

- close/open keeps progress
- offline claim appears
- upgrades change battle outcome

### Phase 6: Expand Content

Goal: move from prototype to vertical slice.

Tasks:

- add 12 heroes
- add role tags
- add 3 enemy families
- add 1 boss
- add skill effects for the first 6 heroes

Acceptance:

- team composition matters
- boss tests tank/control/DPS
- no need to manually wire each sprite

### Phase 7: Playtest + Export

Goal: build a playable Windows prototype.

Tasks:

- install Godot 4.7 export templates
- add Windows export preset
- run smoke test
- record short gameplay clip
- tune first 10 minutes

Acceptance:

- exported `.exe` runs
- first battle starts within 30 seconds
- player understands upgrade -> battle -> reward loop without explanation wall

## Immediate Codex Run Command Set

When ready to implement Phase 1, Codex should do:

```powershell
$godot = "C:\Users\ADMIN\AppData\Local\Programs\Godot\4.7-stable\Godot_v4.7-stable_win64.exe"
& $godot --headless --version
```

Then create the project under:

```text
C:\Users\ADMIN\Documents\GAME IDLE\godot\game-siam-idle
```

Do not delete old Unity files during Phase 1. They are annoying, but not blocking. Archive cleanup is a separate task.

## Biggest Risks

Risk: trying to wire all 40 characters immediately.

Fix: import all metadata format support, but only make 6 playable first.

Risk: treating this like a spreadsheet idle game.

Fix: battle view is the product. The sprites must be visible and satisfying.

Risk: building gacha/economy before combat is fun.

Fix: deterministic unlock and local save only.

Risk: writing gameplay inside Godot node callbacks.

Fix: pure-ish simulation data + renderer bridge.

Risk: offline rewards inflate progression.

Fix: cap at 8h, reward from highest cleared wave, no simulated per-frame battle while offline.

Risk: old Unity project clutter.

Fix: create clean Godot subproject first, archive Unity later.

## What To Skip For Now

- C#/.NET Godot
- multiplayer
- PvP
- mobile export
- ads/IAP
- gacha
- equipment substats
- procedural maps
- full 40 hero balance
- new sprite generation
- complex skeletal/2D rigging
- rebuilding Unity integration

## Final Recommendation

Build the next milestone as:

> **A Godot 4.7 PC prototype where 6 GAME SIAM heroes auto-battle through 20 waves using the existing QC-passed sprites, with local idle rewards and upgrade progression.**

This uses the strongest asset already produced, keeps implementation small, and creates a playable thing fast enough to judge the game instead of the pipeline.
