# GAME SIAM IDLE Runbook

## Paths

- Godot: `C:\Users\ADMIN\AppData\Local\Programs\Godot\4.7-stable\Godot_v4.7-stable_win64.exe`
- Project: `C:\Users\ADMIN\Documents\GAME IDLE\godot\game-siam-idle`
- Source sprites: `C:\Users\ADMIN\Documents\GAME IDLE\Assets\Art\Characters\GameSiam`

## Current Status

- Godot 4.7 standard build works.
- Phase 0-5 foundation is implemented with GDScript and local assets only.
- All 40 passed GAME SIAM heroes are copied into Godot runtime asset folders without regenerating source art.
- `Battle.tscn` runs a deterministic formation/wave battle loop with local profile save, upgrades, and offline rewards.
- JDK 17, Android Studio, Android SDK command-line tools, platform-tools, Android 36.1 platform, build-tools 36.1.0, Deno, Supabase CLI, and Godot 4.7 export templates are installed.
- Phase 6 backend deploy still needs a real Supabase project/login; local schema and pure economy checks run without an account.
- New visual assets for UI, backgrounds, icons, effects, and store materials should be generated with the Codex `imagegen` skill, then copied into the Godot project. Passed character sprite sheets remain source-of-truth assets and must not be regenerated unless explicitly requested.

## Project Skill Policy

- Always use `game-siam-idle-godot` for Godot project work.
- Use `game-character-sprites` for any character sprite creation, regeneration, edit, or sprite QC.
- Use `imagegen` for new raster UI, background, VFX, icon, button, store, or generated bitmap assets.
- Use subagents for independent QC when visual quality, movement feel, skill readability, or launch readiness is being judged.
- Asset replacement policy: if QC finds an asset off-style, blurry, cropped, too bright, placeholder-like, or not matching the 64px pixel-art Siam battle direction, regenerate that specific asset instead of preserving it. Use `game-character-sprites` for character sprites and `imagegen` for UI/VFX/background/button/store assets.
- After Codex restart, use the installed `gd-agentic-skills` Godot pack as task references. Start broad Godot work with `godot-master`, then load only the relevant specialist skills such as `godot-debugging-profiling`, `godot-testing-patterns`, `godot-combat-system`, `godot-2d-animation`, `godot-tweening`, `godot-ui-containers`, `godot-performance-optimization`, `godot-platform-mobile`, or `godot-export-builds`.
- Treat these Godot workflow tags as the project working stack: `using-godot-prompter`, `godot-project-setup`, `godot-brainstorming`, `godot-code-review`, `godot-debugging`, `godot-testing`, `scene-organization`, `state-machine`, `event-bus`, `component-system`, `resource-pattern`, `dependency-injection`, `player-controller`, `input-handling`, `ability-system`, `inventory-system`, `dialogue-system`, `save-load`, `ai-navigation`, `camera-system`, `audio-system`, `animation-system`, `tween-animation`, `godot-ui`, `hud-system`, `responsive-ui`, `localization`, `2d-essentials`, `3d-essentials`, `physics-system`, `shader-basics`, `particles-vfx`, `math-essentials`, `procedural-generation`, `multiplayer-basics`, `multiplayer-sync`, `dedicated-server`, `export-pipeline`, `godot-optimization`, `mobile-development`, `xr-development`, `multithreading`, `assets-pipeline`, `gdscript-patterns`, `gdscript-advanced`, `csharp-godot`, `csharp-signals`, `gdextension`, `addon-development`, `beehave`, `limboai`.
- Keep the installed `gd-agentic-skills` names available for routing after restart: `godot-master`, `godot-analyst`, `godot-auditor`, `godot-builder`, `godot-project-foundations`, `godot-project-templates`, `godot-composition`, `godot-composition-apps`, `godot-autoload-architecture`, `godot-signal-architecture`, `godot-resource-data-patterns`, `godot-scene-management`, `godot-gdscript-mastery`, `godot-debugging-profiling`, `godot-testing-patterns`, `godot-performance-optimization`, `godot-server-architecture`, `godot-2d-animation`, `godot-2d-physics`, `godot-characterbody-2d`, `godot-tilemap-mastery`, `godot-3d-lighting`, `godot-3d-materials`, `godot-3d-world-building`, `godot-physics-3d`, `godot-raycasting-queries`, `godot-shaders-basics`, `godot-particles`, `godot-ability-system`, `godot-ai-navigation`, `godot-animation-player`, `godot-animation-tree-mastery`, `godot-audio-systems`, `godot-camera-systems`, `godot-combat-system`, `godot-dialogue-system`, `godot-economy-system`, `godot-input-handling`, `godot-inventory-system`, `godot-navigation-pathfinding`, `godot-procedural-generation`, `godot-quest-system`, `godot-rpg-stats`, `godot-save-load-systems`, `godot-state-machine-advanced`, `godot-turn-system`, `godot-tweening`, `godot-ui-containers`, `godot-ui-rich-text`, `godot-ui-theming`, `godot-multiplayer-networking`, `godot-export-builds`, `godot-platform-desktop`, `godot-platform-mobile`, `godot-platform-web`, `godot-platform-console`, `godot-platform-vr`, `godot-adapt-2d-to-3d`, `godot-adapt-3d-to-2d`, `godot-adapt-desktop-to-mobile`, `godot-adapt-mobile-to-desktop`, `godot-adapt-single-to-multiplayer`, `godot-game-loop-collection`, `godot-game-loop-harvest`, `godot-game-loop-time-trial`, `godot-game-loop-waves`, `godot-mechanic-revival`, `godot-mechanic-secrets`, `godot-theme-easter`, `godot-genre-action-rpg`, `godot-genre-battle-royale`, `godot-genre-card-game`, `godot-genre-educational`, `godot-genre-fighting`, `godot-genre-horror`, `godot-genre-idle-clicker`, `godot-genre-metroidvania`, `godot-genre-moba`, `godot-genre-open-world`, `godot-genre-party`, `godot-genre-platformer`, `godot-genre-puzzle`, `godot-genre-racing`, `godot-genre-rhythm`, `godot-genre-roguelike`, `godot-genre-romance`, `godot-genre-rts`, `godot-genre-sandbox`, `godot-genre-shooter`, `godot-genre-shooter-fps`, `godot-genre-simulation`, `godot-genre-sports`, `godot-genre-stealth`, `godot-genre-survival`, `godot-genre-tower-defense`, `godot-genre-visual-novel`.
- Only install or apply a tag when it matches the current task; do not add addons, C#, XR, multiplayer, or server code speculatively.

## Commands

```powershell
$godot = "C:\Users\ADMIN\AppData\Local\Programs\Godot\4.7-stable\Godot_v4.7-stable_win64.exe"
$project = "C:\Users\ADMIN\Documents\GAME IDLE\godot\game-siam-idle"

& $godot --headless --version
& $godot --headless --path $project --script res://scripts/tools/import_gamesiam_roster.gd
& $godot --headless --path $project --script res://scripts/tools/validate_phase1.gd
& $godot --headless --path $project --script res://scripts/tools/validate_phase2.gd
& $godot --headless --path $project --script res://scripts/tools/validate_phase3.gd
& $godot --headless --path $project --script res://scripts/tools/validate_phase4.gd
& $godot --headless --path $project --script res://scripts/tools/validate_phase5.gd
& $godot --headless --path $project --script res://scripts/tools/validate_phase6.gd
& $godot --headless --path $project --script res://scripts/tools/validate_phase7.gd
& $godot --headless --path $project --script res://scripts/tools/validate_phase8.gd
& $godot --headless --path $project --script res://scripts/tools/validate_phase9.gd
& $godot --headless --path $project --script res://scripts/tools/validate_phase10.gd
& $godot --headless --path $project --script res://scripts/tools/validate_phase11.gd
& $godot --headless --path $project --script res://scripts/tools/validate_phase12.gd
& $godot --headless --path $project --script res://scripts/tools/validate_phase13.gd
& $godot --headless --path $project --script res://scripts/tools/validate_phase14.gd
& $godot --headless --path $project --script res://scripts/tools/export_debug_analytics_csv.gd
& $godot --headless --path $project --script res://scripts/tools/run_balance_sim.gd
powershell -NoProfile -ExecutionPolicy Bypass -File "$project\tools\export_android_debug.ps1" -Format apk
powershell -NoProfile -ExecutionPolicy Bypass -File "$project\tools\export_android_debug.ps1" -Format aab
powershell -NoProfile -ExecutionPolicy Bypass -File "$project\tools\release_smoke.ps1"
& $godot --headless --path $project --quit-after 2
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\ADMIN\Documents\GAME IDLE\backend\supabase\validate_contract.ps1"
& "C:\Users\ADMIN\AppData\Local\Microsoft\WinGet\Packages\DenoLand.Deno_Microsoft.Winget.Source_8wekyb3d8bbwe\deno.exe" task --cwd "C:\Users\ADMIN\Documents\GAME IDLE\backend\supabase" test
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\ADMIN\Documents\GAME IDLE\godot\game-siam-idle\tools\check_toolchain.ps1"
& $godot --path $project
```

## Phase 1 Acceptance

- `generated/spriteframes/S01_GARUDA_VAYUDEJ.tres` exists.
- `Battle.tscn` displays one animated hero using `idle_south`.
- No source sprite art is regenerated or edited.
- Texture rendering uses nearest filtering.

## Phase 2 Acceptance

- `direction_resolver.gd` maps Godot vectors into the eight asset directions.
- `Unit.tscn` switches `idle_*` and `walk_*` based on movement direction.
- `validate_phase2.gd` covers all eight direction fixtures plus zero-vector fallback.

## Phase 3 Acceptance

- `battle_sim.gd` is a deterministic pure simulation layer, separate from scene nodes.
- Demo combat supports 3 player units vs 3 enemies, nearest-target selection, cooldown attacks, HP, hurt, death, and win/loss result.
- `Battle.tscn` visualizes the simulation through reusable `Unit.tscn` instances.
- `validate_phase3.gd` verifies same-seed deterministic results.

## Phase 4 Acceptance

- Formation uses five active hero slots: front 2 and back 3.
- Tap two formation buttons to swap positions and restart the current wave.
- Wave data is generated for waves 1-20, with boss waves on 10 and 20.
- Battle speed toggles between 1x and 2x.
- Clear rewards grant gold, essence, and shards; one-tap upgrade spends gold and changes battle outcomes.
- `validate_phase4.gd` verifies wave 1 is easy, wave 20 blocks an unupgraded team, and wave 20 clears after upgrades.

## Phase 5 Acceptance

- Local profile saves to `user://profile.json`.
- Profile tracks roster unlocks, hero level/star/shard data, currencies, current wave, and highest cleared wave.
- Offline reward is capped at 8 hours and scales from highest cleared wave.
- Clear rewards are granted once per new highest wave.
- One-tap team upgrade persists and changes battle outcomes.
- Minimal Thai/English string table exists in `scripts/meta/strings.gd`.
- `validate_phase5.gd` verifies save/load, offline cap, one-time clear reward, upgrade impact, and bilingual strings.

## Android Prerequisites For Later

- JDK: `C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot`
- Android SDK: `C:\Users\ADMIN\AppData\Local\Android\Sdk`
- Godot export templates: `C:\Users\ADMIN\AppData\Roaming\Godot\export_templates\4.7.stable`
- Android Studio: `C:\Program Files\Android\Android Studio`
- Configure keystore and Google Play package id.

## Phase 6 Partial Backend Contract

- `backend/supabase/migrations/0001_economy.sql` defines the required 13 economy tables.
- RLS is enabled for every table.
- Client-facing select policies exist for owned/profile-safe reads.
- Economy writes are intentionally left for Edge Functions using service role.
- Idempotency constraints exist for battle starts, battle finishes, gacha pulls, and Google purchase tokens.
- `backend/supabase/validate_contract.ps1` verifies the local SQL contract.
- `backend/supabase/functions/_shared/economy.ts` contains pure economy rules for idempotent battle rewards, offline rewards, purchase grants, and ledger tracing.
- Edge Function entrypoints exist for `get_profile`, `sync_client_state`, `start_battle`, `finish_battle`, `claim_offline_reward`, `upgrade_hero`, `get_gacha_banner`, `pull_gacha`, `validate_google_purchase`, and `grant_purchase`.
- Godot client wrapper exists at `scripts/backend/economy_client.gd` and builds POST requests for all 10 Edge Functions.
- `deno task test` under `backend/supabase` verifies duplicate battle finish, duplicate purchase token, offline reward cap, backward clock handling, ledger write, and basic Edge Function flows.
- `validate_phase6.gd` verifies Godot client request URLs, headers, method, and payload shape.
- Not complete until Supabase project/login exists and Edge Functions are deployed against Postgres.

## Phase 7 Partial Gacha / Billing Contract

- Backend gacha pool includes all 40 GAME SIAM heroes.
- Published launch odds are S 2%, A 8%, B 25%, C 35%, D 30%.
- Backend gacha supports 1x and 10x pulls, 10-pull A+ guarantee, pity at 80 pulls, duplicate request idempotency, and duplicate hero shard conversion.
- Purchase grant remains server-side and idempotent by purchase token.
- Godot battle scene exposes odds text, Pull 1, Pull 10, and Buy Premium buttons.
- `PurchaseClient` keeps pending local purchase tokens for resume and forwards them to `grant_purchase`.
- `validate_phase7.gd` verifies gacha request payloads, odds endpoint, pending purchase resume, and purchase grant request shape.
- Not complete until a real Godot Google Play Billing plugin is wired and receipts are validated by Google Play Developer API credentials.

## Phase 8 Content Pool Contract

- `scripts/content/hero_catalog.gd` defines the 40-hero launch pool, 8 shared role/stat archetypes, 8 shared skill behavior templates, 5 enemy families, and 100 campaign waves.
- `scripts/tools/import_gamesiam_roster.gd` imports all 40 heroes from metadata into generated `SpriteFrames` resources.
- `BattleSim.MAX_WAVE` is 100 and uses catalog archetype stats instead of per-hero custom stat code.
- All 40 heroes are present under `assets/characters/GameSiam` with 6 final clean sheets and 6 metadata files each.
- `validate_phase8.gd` verifies all 40 generated `SpriteFrames`, archetype/skill coverage, boss waves every 10 waves, all enemy families, and a 1-100 wave no-softlock smoke pass.

## Phase 9 Mobile UI Contract

- Battle scene remains landscape-first at 1280x720 with canvas stretch and mobile renderer.
- Persistent HUD keeps the battle center clear: top status, lower hint, bottom battle buttons, and 5-slot formation bar.
- Gacha and settings surfaces are hidden by default and opened from compact top buttons.
- Settings includes language toggle, sound toggle, notifications placeholder, and account restore placeholder.
- Thai/English strings cover the visible battle, gacha, settings, and onboarding hint text.
- `validate_phase9.gd` verifies portrait settings, hidden drawers, tap-sized controls, protected battle center, and bilingual string coverage.

## Phase 10 Analytics / Balance Contract

- `scripts/telemetry/analytics_client.gd` defines the launch metric event contract and writes a local JSONL queue until Firebase is wired.
- Battle flow logs tutorial start, first battle start/win, first upgrade, wave start/clear/fail, offline claim, gacha view/pull, and purchase start/success/fail events.
- `export_debug_analytics_csv.gd` exports `user://analytics_events.jsonl` to `user://analytics_events.csv`.
- `run_balance_sim.gd` simulates waves 1-100 and writes `user://balance_sim.csv`.
- `validate_phase10.gd` verifies the required event list, local queue, CSV exporter, battle hook references, and 100-wave balance no-softlock pass.
- Firebase Analytics and Crashlytics remain pending until a Firebase project config and Godot Android plugin path are provided.

## Phase 11 Android Export Contract

- `export_presets.cfg` defines `Android Debug APK` and `Android Debug AAB` presets with package id `com.gamesiam.idle`, version `0.1.0` / code `1`, arm64-v8a only, and Internet/network permissions.
- `tools/export_android_debug.ps1` exports debug APK or AAB with Godot headless.
- Godot editor settings now point Android export to JDK 17 and the Android SDK; debug signing uses the local Godot debug keystore.
- Android ETC2/ASTC texture import is enabled in `project.godot`.
- Local outputs:
  - `exports/android/game-siam-idle-debug.apk`
  - `exports/android/game-siam-idle-debug.aab`
- APK signature verification passed with Android build-tools `apksigner` using v2/v3 schemes.
- AAB zip structure contains `BundleConfig.pb`, `base/manifest/AndroidManifest.xml`, and arm64 native libraries.
- `validate_phase11.gd` verifies Android project settings, preset contract, generated APK/AAB sizes, and Android custom build template presence.
- Remaining user/device tasks: real release keystore, package ownership in Google Play Console, upload/internal track, emulator/real-device install smoke, and prod/staging backend env switching.

## Phase 12 Compliance / Store Prep Contract

- Launch prep docs live in `C:\Users\ADMIN\Documents\GAME IDLE\docs\launch`.
- Included drafts: privacy policy, Google Play data safety inputs, English store listing, Thai store listing, 30-second trailer script, release checklist, and compliance source links.
- Battle settings drawer includes support and account deletion placeholder paths.
- Gacha drawer keeps randomized odds visible before pull.
- `validate_phase12.gd` verifies launch docs, required placeholders, official source links, odds path, support path, account deletion path, and bilingual strings.
- Remaining user/legal tasks: publish privacy URL, provide support email, provide deletion URL/workflow, complete Google Play Data Safety, complete IARC, approve legal copy, and upload final store assets.

## Phase 13 Closed Test / Soft Launch Contract

- `scripts/config/environment.gd` defines dev/staging/prod placeholders for Supabase URL, anon key, and tester feedback form URL.
- Battle settings drawer includes a feedback button that surfaces the active environment feedback URL.
- Launch docs include closed test plan, soft launch plan, tester feedback form template, and staging config notes.
- `run_balance_sim.gd` remains the nightly/local balance simulation entrypoint.
- `validate_phase13.gd` verifies environment config, feedback path, bilingual feedback strings, and closed-test/soft-launch docs.
- Remaining user/test tasks: create actual feedback form, deploy staging backend, create Google Play closed testing track, invite 20-50 testers, collect feedback, and decide whether data will be wiped before soft launch.

## Phase 14 Production Launch Prep Contract

- Launch docs include production launch runbook, monitoring checklist, rollback playbook, release notes template, and migration snapshot guide.
- `tools/release_smoke.ps1` runs validators 1-14, toolchain check, and Android debug APK/AAB exports.
- `validate_phase14.gd` verifies production launch docs, rollback/monitoring content, release smoke script, and Android debug outputs.
- Actual production launch remains blocked until real Google Play, Supabase, Firebase, release signing, privacy/support/deletion, and purchase validation credentials exist.
