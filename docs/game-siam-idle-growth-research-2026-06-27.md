# GAME SIAM IDLE Growth Research: ไปทางไหนให้เข้าถึงง่ายและมีโอกาสบูม

Date: 2026-06-27

## คำตอบสั้น

ทิศทางที่ควรไปต่อคือ:

> **Godot 4.7, 2D idle auto-battler hero collector, PC/Steam demo first, mobile later, จุดขายคือ “จัดทีมตำนานสยาม 5 ตัวแล้วดูศึกอัตโนมัติแบบอ่านง่ายใน 30 วินาที”**

ไม่ควรเริ่มจาก mobile gacha เต็มระบบ แม้มันเข้าถึงคนเยอะกว่า เพราะทีมเล็กจะโดน live ops, retention, ads, store competition และ balance กินก่อนเกมสนุกจริง ควรเริ่มด้วย PC demo ที่ทำให้คนดูคลิปแล้วเข้าใจทันที จากนั้นค่อย port mobile เมื่อ loop พิสูจน์แล้ว.

## สิ่งที่โปรเจกต์มีจริงตอนนี้

จาก local audit:

- ตัวละครพร้อมใช้: `40`
- Spritesheets: `240`
- Metadata: `240`
- Asset size รวมเฉพาะ sheets: `42.17 MB`
- แต่ละตัวมี `6 actions x 8 directions`
- Actions: `idle`, `walk`, `attack_01`, `skill_01`, `hurt`, `death`
- QC handoff: PASS, 0 failures
- Engine ที่ลงแล้ว: Godot `4.7.stable.official.5b4e0cb0f`

ข้อได้เปรียบจริง:

- มีตัวละครเยอะพอสำหรับ collection/progression
- มี animation ครบพอสำหรับ battle view
- 8 ทิศทางเหมาะกับ top-down battlefield
- ธีมตำนานสยามแตกต่างจาก fantasy generic

ข้อจำกัดจริง:

- ยังไม่มี gameplay loop
- ยังไม่มี Godot project
- ยังไม่มี enemy/environment/UI/audio
- Sprite เป็น 64x64 pixel art ไม่ควรทำกล้องไกลเกินไป
- ถ้าทำ story/lore หนัก คนเข้าใหม่จะหลุดง่าย

## Research Snapshot

### Engine

Godot 4.7 stable เป็นเวอร์ชันปัจจุบันที่ลงไว้แล้ว และ workflow sprite sheet ของ Godot รองรับงานนี้โดยตรงผ่าน `AnimatedSprite2D`, `SpriteFrames`, และ `AtlasTexture`.

Implication:

- ใช้ GDScript ก่อน
- ไม่ต้องใช้ C#/.NET
- ไม่ต้อง split PNG เป็น 11,520 frame files
- สร้าง importer จาก metadata ได้

### Platform

ตลาด mobile ใหญ่กว่า แต่การจะ “บูม” บน mobile ต้องมี:

- retention tuning
- monetization
- live events
- paid UA
- store creative testing
- analytics
- ad network / IAP infrastructure

นี่หนักเกินไปสำหรับช่วงที่เกมยังไม่มี playable loop.

PC/Steam เหมาะกว่าในเฟสแรกเพราะ:

- demo-driven discovery ทำได้
- wishlist เป็น metric ชัด
- Next Fest เป็น milestone ชัด
- creator/YouTube/TikTok clip ส่งคนไป wishlist ได้
- ไม่ต้องมี monetization ตั้งแต่วันแรก

### Genre

Idle อย่างเดียวเข้าถึงง่าย แต่ไม่โชว์ asset พอ.

Auto-battler อย่างเดียวสนุก แต่ onboarding อาจยาก.

Hero collector อย่างเดียวจะกลายเป็นหน้าการ์ด/กาชาเร็วเกิน.

ส่วนผสมที่ดีที่สุดสำหรับ asset นี้:

> **Idle progression + auto-battle spectacle + light formation strategy + hero collection**

## Direction Scorecard

คะแนน 1-5 ยิ่งสูงยิ่งดี.

| Direction | เข้าถึงง่าย | โอกาสไวรัล | ใช้ asset คุ้ม | ทำ MVP ง่าย | ระยะยาว | คะแนนรวม |
|---|---:|---:|---:|---:|---:|---:|
| PC idle auto-battler hero collector | 4 | 4 | 5 | 4 | 4 | 21 |
| Mobile idle RPG/gacha | 5 | 3 | 5 | 2 | 5 | 20 |
| Survivor-like action roguelite | 4 | 5 | 3 | 3 | 4 | 19 |
| Tactical RPG/grid tactics | 2 | 3 | 5 | 2 | 4 | 16 |
| Lore/story collection game | 3 | 2 | 4 | 4 | 2 | 15 |

Winner: **PC idle auto-battler hero collector**

เหตุผล:

- คนเข้าใจในประโยคเดียว: “จัดทีมแล้วดูทีมสู้”
- ใช้ 40 ตัวละครได้จริง
- คลิปสั้นดูรู้เรื่อง: skill, boss, wipe, team comp
- MVP ทำได้โดยไม่ต้องมี content ใหม่เยอะ
- ขยายไป mobile ได้ถ้าพิสูจน์แล้ว

## Positioning ที่ควรใช้

อย่าขายว่า:

- “เกม RPG ตำนานไทยสุดลึก”
- “idle RPG มีระบบเยอะ”
- “gacha hero collector”

ควรขายว่า:

> **จัดทัพตำนานสยาม 5 ตัว แล้วดูพวกเขาฟาดศึกอัตโนมัติผ่าน wave และ boss**

ภาษาอังกฤษสำหรับ Steam:

> **Build a squad of Siamese mythic heroes, place them on the field, and watch them auto-battle through waves of monsters while your camp grows even offline.**

Tagline สั้น:

- “Mythic Siam auto-battles while you’re away.”
- “จัดทีมครั้งเดียว ศึกเดินต่อเอง.”
- “ตำนานสยาม ปะทะเวฟอสูร แบบ idle auto-battle.”

## ใครคือผู้เล่นแรก

### Persona 1: Casual idle player

ต้องการ:

- เปิดมาแล้วได้รางวัล
- อัปเกรดง่าย
- เลขขึ้นไว
- แพ้แล้วรู้ว่าต้องทำอะไร

อย่าให้:

- อ่าน lore ยาว
- เลือกของเยอะ
- formation ซับซ้อนตั้งแต่แรก

### Persona 2: Strategy-lite auto-battler player

ต้องการ:

- เปลี่ยนทีมแล้วผลต่าง
- tank/range/support อ่านออก
- boss บังคับให้จัดทีมใหม่

อย่าให้:

- ทุกตัวเป็น stat stick
- RNG ตัดสินมากเกิน

### Persona 3: Pixel art / mythology audience

ต้องการ:

- ตัวละครสวยและแตกต่าง
- ชื่อ/ธีมจำง่าย
- skill มีภาพจำ

อย่าให้:

- จอ battle ซูมไกลจนดูไม่ออก
- UI บัง animation

### Persona 4: Thai audience

ต้องการ:

- เห็นความเป็นสยามทันที
- ไม่รู้สึกเหมือนเกมตำรา
- แชร์คลิปแล้วเพื่อนเข้าใจ

อย่าให้:

- คำศัพท์ยากเกิน
- อ้างตำนานแบบจริงจังจนแตะยาก

## Pillars ของเกม

### 1. เห็นตัวละครสู้จริง

Battle view คือ product. ถ้าเปิดเกมแล้วเห็นแต่เมนู เกมเสียของ.

Rule:

- ภายใน 30 วินาทีแรก ผู้เล่นต้องเห็นทีมเดินและโจมตี
- ภายใน 2 นาทีแรก ผู้เล่นต้องชนะ wave แรก
- ภายใน 5 นาทีแรก ผู้เล่นต้องได้ upgrade แล้วเห็นผล

### 2. จัดทีมง่าย แต่มีผล

MVP formation:

- 5 slots
- front 2, back 3
- drag/drop หรือ click swap
- role icon ง่าย ๆ: tank, melee, ranged, mage, support

ยังไม่ต้องมี:

- equipment
- rune
- substat
- faction synergy ซ้อนหลายชั้น

### 3. Idle reward ต้องเป็นโบนัส ไม่ใช่เกมทั้งหมด

Offline reward ทำให้กลับมาเล่นง่าย แต่ห้ามแทนที่ combat.

Recommended:

- cap 8 hours
- reward based on highest cleared wave
- claim screen สั้นมาก
- หลัง claim ให้เสนอ upgrade ทันที

### 4. Clip-worthy moments

เกมจะบูมได้ง่ายขึ้นถ้ามีโมเมนต์ที่ตัดเป็นคลิป 8-15 วินาที:

- S rank skill wipe
- boss เกือบชนะแล้วทีมพลิกกลับ
- formation ผิดแล้วละลาย
- ตัวละครไทย mythic แปลกตา
- “ก่อน/หลังอัปเกรด” เห็นชัด

## Recommended First Playable

ชื่อ milestone:

> **First 10-Minute Demo**

Scope:

- 6 heroes
- 5 deployed units
- 20 waves
- 1 boss
- 3 enemy archetypes
- local save
- offline reward
- speed 1x/2x
- upgrade level
- simple formation

Do not include:

- gacha
- shop
- ads
- PvP
- daily quests
- 40 hero balancing
- equipment
- complex story mode

## First 6 Heroes

Use:

- `S01_GARUDA_VAYUDEJ` - premium vanguard / iconic S rank
- `S02_NAGA_SASINAKA` - control mage
- `S03_YAKSHA_KRAIASURA` - tank / boss anchor
- `A02_TIGER_PLOENGPAYAK` - melee assassin
- `A03_HUMAN_ARUNRAT` - ranged DPS
- `A06_SPIRIT_RAMPAN_MASK` - debuff support

Why:

- ครบ role
- visual variety สูง
- มี S-rank spectacle
- ทดสอบ battle system ได้โดยไม่ต้อง import ทั้ง 40 แบบ playable

## Combat MVP

Core battle:

- Team size: 5
- Enemy count: 3-8 per wave
- View: top-down 2D
- Movement: simple steering toward target
- Direction: 8-way from velocity
- Targeting: nearest enemy
- Attack: cooldown-based
- Skill: auto-cast on cooldown
- Death: play death animation and remove/disable collider

Stats:

```text
hp
attack
defense
attack_range
attack_cooldown
move_speed
skill_cooldown
role
```

Damage formula:

```text
damage = max(1, attack - defense * 0.35) * multiplier
```

This is boring on purpose. Balance can happen after the first loop exists.

## Viral / Marketing Plan

### Phase A: Proof Clips

Before store page:

- 10 clips of hero skills
- 5 clips of formation changes
- 3 clips of boss fights
- 1 clip: “we made 40 Siam mythic heroes”

Clip rules:

- 8-15 seconds
- show gameplay in first 1 second
- no long intro logo
- one caption only
- skill/boss/reward must be readable without sound

### Phase B: Steam Page

Steam page should not wait for full game.

Needed:

- title capsule
- 5 screenshots
- 1 gameplay trailer, 30-45 seconds
- short description focused on player verbs
- tags around idle, auto battler, strategy, pixel art, RPG
- demo build once first 10-minute loop is stable

Wishlist goal before broader push:

- internal small goal: 500
- healthy demo signal: 2,000+
- serious Next Fest prep: 7,000-10,000+

These are not magic thresholds, just practical signal bands.

### Phase C: Creator Angle

Content hooks:

- “Thai mythology auto-battler”
- “40 hand-QC’d pixel heroes”
- “Can this formation beat wave 20?”
- “Pick my team: Garuda, Naga, Yaksha, Tiger, Spirit”

Avoid:

- devlog only about pipeline
- lore narration before gameplay
- UI-only economy screenshots

## Accessibility / Mass Appeal Rules

เข้าถึงง่าย means:

- first click starts battle
- roles are icon-based
- upgrades are one button
- failure tells player one clear next action
- battle outcome is readable
- no opening wall of text
- no 12 currencies
- no hidden formulas in UI

Opening flow:

1. Start
2. See 3 heroes already deployed
3. Press Battle
4. Win wave 1
5. Claim gold
6. Upgrade one hero
7. Win wave 2 faster
8. Unlock formation slot

No lore prompt before this.

## Thai Myth Direction

Use inspiration, not homework.

Good:

- Garuda as mobile vanguard
- Naga as water/control mage
- Yaksha as tank
- Kinnari as agile aerial/support
- Spirit as curse/debuff
- Construct as summon/engineer

Avoid:

- requiring players to know mythology
- long Sanskrit/Pali-heavy naming in UI
- real religious framing
- political/historical specificity

UI naming:

- Keep character ID internal.
- Display short readable names.
- Put detailed lore in optional Codex/Archive.

## Roadmap For Codex

### Run 1: Godot Project Skeleton

Deliverable:

- clean Godot project under `godot/game-siam-idle`
- one battle scene
- one visible animated hero

Codex tasks:

- create Godot folders
- copy first 6 hero sheets and metadata
- create minimal `project.godot`
- create importer script or Python generator for `.tres` resources
- create `Battle.tscn`
- verify Godot opens headless

### Run 2: SpriteFrames Importer

Deliverable:

- all animations for first 6 heroes exist as `SpriteFrames`
- animation names follow `action_direction`

Acceptance:

- no manual slicing
- row order matches metadata
- idle/walk loop
- attack/skill/hurt/death non-loop

### Run 3: Unit Movement

Deliverable:

- one unit moves to target point
- 8-way direction animation works

Acceptance:

- south/east/north/west readable
- no wrong row
- idle resumes when stopped

### Run 4: 3v3 Auto Battle

Deliverable:

- battle sim
- HP bars
- target acquisition
- attack/death

Acceptance:

- fight resolves to win/loss
- restarting battle works

### Run 5: 5-unit Formation + 20 Waves

Deliverable:

- first playable loop
- wave progression
- rewards

Acceptance:

- player can clear wave 1-5 without understanding everything
- wave 20 boss blocks weak team

### Run 6: Save + Idle Rewards

Deliverable:

- local save
- offline reward
- upgrades

Acceptance:

- close/reopen preserves state
- upgrade changes battle outcome

### Run 7: Store/Clip Package

Deliverable:

- 10 screenshots/clips
- Steam capsule direction
- trailer beats

Acceptance:

- someone can understand the game from 30 seconds of footage

## What To Build First In Godot

First scene should be:

- no title screen
- no lore
- no world map
- one battlefield
- one hero idling
- then one hero walking
- then 3v3 battle

Why:

Every non-battle screen before battle is risk. The battle view is the proof.

## Feature Cut List

Skip now:

- full 40 hero gameplay
- gacha
- monetization
- account login
- cloud save
- PvP
- guilds
- daily missions
- equipment
- talent trees
- cinematic story
- procedural campaign map
- mobile UI polish
- localization beyond basic English/Thai strings

Add when:

- 10-minute loop retains tester interest
- players ask for more team variety
- battle readable at 1x/2x
- upgrade loop feels meaningful

## Success Metrics For Prototype

Internal playtest:

- time to first battle: under 30 seconds
- time to first upgrade: under 3 minutes
- time to understand win/loss: under 5 minutes
- player can describe the game in one sentence
- tester wants to try a different formation

Public demo:

- screenshots read as game, not tool
- 30-second clip explains loop
- comments mention characters/formation/boss, not confusion
- wishlist or follow action available

## Final Recommendation

Build this:

> **A 10-minute PC demo where players deploy 5 Siam mythic heroes, watch them auto-battle waves, upgrade after wins, claim idle rewards, and hit a boss that makes formation matter.**

This is the shortest path that uses the 40-character asset advantage, stays approachable, and has the best chance to produce shareable clips.

## Sources

- Godot Windows download: https://godotengine.org/download/windows/
- Godot 4.7 stable archive: https://godotengine.org/download/archive/4.7-stable/
- Godot AnimatedSprite2D docs: https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html
- Godot SpriteFrames docs: https://docs.godotengine.org/en/4.7/classes/class_spriteframes.html
- Godot 2D sprite animation docs: https://docs.godotengine.org/en/4.7/tutorials/2d/2d_sprite_animation.html
- Godot export docs: https://docs.godotengine.org/en/latest/tutorials/export/exporting_projects.html
- SteamDB Auto Battler tag: https://steamdb.info/tag/1084988/
- Steamworks Steam Next Fest docs: https://partner.steamgames.com/doc/marketing/upcoming_events/nextfest
- Steamworks wishlists docs: https://partner.steamgames.com/doc/marketing/wishlist
- Newzoo PC & Console Gaming Report 2026 page: https://newzoo.com/resources/trend-reports/the-pc-console-gaming-report-2026
- Newzoo global games market Q2 2026 blog: https://newzoo.com/resources/blog/global-games-market-q2-2026
- Sensor Tower State of Mobile Gaming 2026 report page: https://sensortower.com/blog/state-of-mobile-gaming-2026
