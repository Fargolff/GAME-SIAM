# GAME IDLE Current Status

Date recovered: 2026-07-01

## Latest Known State

- Codex chat history before the update is not visible in the local thread list, but project files are intact.
- This folder is not a git repo, so status was recovered from file timestamps and QC reports.
- Latest active work: roster visual QC on `C01_HUMAN_JETSIAM`; v05 is now active.

## Project Status

- Roster QC: baseline/playable PASS, not final production polish.
- Aggregate roster score: 86/100 subagent, 88.08/100 average main score.
- Validators passed: 40/40 `validate_*_baseline.gd`, `validate_phase3.gd`, `validate_phase8.gd`, `validate_phase9.gd`, `validate_skill_roster.gd`.
- Personal attack/skill VFX: V103 PASS across all 40 heroes, subagent 95/100.
- S01 facing pilot: V104 PASS for east/west facing, but do not expand the S01 side-row approach to all 40 yet.

## Latest C01 Work

- `C01_HUMAN_JETSIAM` is currently `PASS_WITH_MINOR_WALK_ART_DEBT`.
- Main score: 90/100 for v05. No independent subagent score was run for v05.
- Fixed before v05: side-locked C01 combat walk, reduced walk jitter, cleaned green edge halo on C01 clean sheets.
- v05 patch: edited only active Godot walk east/west lower-leg pixels using a rejected imagegen candidate as motion source while preserving original upper body/head/shield/spear.
- Validators passed for v05: walk sheet validation, walk motion audit, Godot import, `validate_c01_baseline.gd`, and `validate_phase3.gd`.
- Keep v05 active for now.

## Latest C04 Visual Polish

- `C04_HUMAN_CHABA` is now `PASS_C04_RUNTIME_STAGING_POLISH`.
- Main visual score: 90/100 for v02. Subagent found C04 was the top queue blocker before the patch because the hibiscus VFX read as a floating caster badge.
- v02 patch is code-only in Godot runtime: added C04-only petal travel from caster to target and target-side blossom landing feedback while keeping the existing C04 V101 asset and validator runtime mode.
- Debug stdout in `battle.gd` is now guarded for the two visual-runtime print paths touched in this pass.
- Fresh runtime proof exists from a windowed Godot 4.7 showcase: 15 viewport frames plus full/zoom MP4 and contact sheets.
- Validators passed after v02: `validate_c04_baseline.gd`, `validate_phase3.gd`, `validate_phase9.gd`, `validate_skill_roster.gd`, `validate_phase8.gd` exit 0, `validate_phase10.gd` exit 0, `export_debug_analytics_csv.gd`, and `run_balance_sim.gd` exit 0. Phase 8/10 and balance sim still return empty stdout in this shell.

## Latest Fun Sprint 1

- First-session local prototype is now `PASS_WITH_QC_CAPTURE_CAVEAT`.
- Wave 1 reward now funds the first team upgrade immediately; waves 1/3/5/10 have milestone bonuses.
- Existing `hint_label` now shows short first-session goals, and ULT is faster with next-caster text on the button.
- Added `validate_first_session_fun.gd`; it now also guards the Next Wave double-advance regression found by subagent QC.
- Subagent P1 was fixed: clearing Wave 1 no longer lets the Next Wave path skip to Wave 3.
- Running battle UI full refresh is throttled to reduce stutter; the cooldown ring/skill focus still update every frame.
- Validators passed after the latest patch: `validate_first_session_fun.gd`, Phase 4/5/9, with Phase 8/10 exit 0 and empty stdout in this shell.
- Fresh windowed v04 evidence exists from isolated `GAME_SIAM_PROFILE_PATH` playtest frames. It reaches current_wave 6, highest_cleared 5, 4 shards, and starter heroes upgraded to Lv4. Caveat: the stutter seen during QC was from env-only PNG viewport capture, and audio timing was not captured.

## Latest Art Reboot

- Full visual reboot v200 is started but runtime assets are untouched.
- S01 pilot workspace exists under `run/art-reboot-2026-07-01/pilot/S01_GARUDA_VAYUDEJ`.
- No art reboot pilot row is accepted yet. `S01_GARUDA_VAYUDEJ` walk south candidate2 passes sheet geometry and motion audit with 0 warnings, but is rejected because it drifts into a different character identity.
- Candidate1 was rejected because the normalized row read as side/diagonal instead of front-facing south.
- Added `tools/art_reboot_normalize_strip.py` for fixed-cell normalization of imagegen strip candidates.
- Added `tools/art_reboot_audit_assets.py`; baseline audit now covers `battle.gd` plus `Battle.tscn` and found 76 active asset references, 0 missing imports, 0 missing active files, and 40 duplicated VFX version groups to archive only after replacements pass.
- Added `tools/art_reboot_audit_characters.py`; contract audit found 40 hero dirs, 40 generated SpriteFrames, all 6 action sheets per hero at 384x512, and 0 errors.
- Added `tools/art_reboot_validate_status.py` to keep manifest/status evidence aligned with the corrected identity gate.
- Added `tools/art_reboot_visual_100_gate.py`; current result is `VISUAL_100_BLOCKED` with 8 blocker groups: art manifest not pass, 0 validated accepted rows, 40/40 characters below literal 100, hard evidence limitations, 55 active VFX not `_v200`, VFX lacking accepted candidate evidence, UI/background lacking accepted v200 evidence, and UI/background lacking accepted candidate evidence. The gate now also writes Candidate Review Gate and Asset Candidate Gate sections, so S01 candidate2 is rejected on `reference_identity` and VFX/UI/background cannot inflate accepted progress without same-size, style, readability, alpha-edge, non-legacy, and runtime evidence checks.
- Added `tools/art_reboot_sync_asset_candidates.py` and `run/art-reboot-2026-07-01/asset_candidates_v200.json`; it tracks inactive candidate-only coverage for 55 active VFX assets, 9 active generated UI textures/icons, and 1 active battlefield background. Current accepted counts are 0/55, 0/9, and 0/1.
- Added `tools/art_reboot_run_baseline_validators.ps1`; latest baseline validation evidence passed 54 commands with per-command stdout/stderr logs, including art reboot audits, `import_gamesiam_roster.gd`, Phase 3/8/9/10, `validate_skill_roster.gd`, `validate_first_session_fun.gd`, analytics CSV export, balance sim, and all 40 `validate_???_baseline.gd` validators. `art_reboot_visual_100_gate.py` expected-failed with exit 1 and is counted as pass for the baseline batch.
- Added `tools/visual_100_final_capture.ps1` for the final post-implementation runtime proof pass; do not count old captures as final Visual 100 evidence. Its baseline validator glob is fixed to `validate_???_baseline.gd` and asserts exactly 40 validators.
- Added direct visual eye QC evidence under `run/visual-eye-qc-2026-07-01`: current runtime is playable at 1280x720, but Visual 100 still fails because S01 candidate2 visually drifts from the current Garuda identity and behaves like an icon-like front pose rather than an accepted walk row.
- Do not replace runtime character/VFX/UI/background assets until the pilot gate is complete.

## Next Work

1. Do not expand the v05 hybrid leg patch to all heroes.
2. Continue art reboot gate: fix S01 identity-locked generation first, then finish S01 full character, then S02 and C09. Only expand to all 40 after all three pilot heroes are >=92/100.
3. For true final C01 polish, replace v05 only with a fully identity-locked authored east/west walk row.
4. Continue fun sprint only if first-session testers still feel low agency; otherwise continue the fixed visual polish queue:
   `C09_KINNARI_KAEWKANGSADAN`, `D04_HUMAN_TAEMTHONG`, `D09_CONSTRUCT_SILADIN`, `B02_NAGA_KLEDKRAM`, `C08_CROCODILE_KUMPHIL`.

## Evidence

- Roster summary: `run/roster-qc-2026-07-01/roster_qc_summary_2026-07-01.md`
- C01 v05 verdict: `run/roster-qc-2026-07-01/C01_HUMAN_JETSIAM/C01_v05_visual_qc_verdict.md`
- C01 v05 manifest: `run/roster-qc-2026-07-01/C01_HUMAN_JETSIAM/C01_polish_v05_manifest.json`
- C01 v04 verdict: `run/roster-qc-2026-07-01/C01_HUMAN_JETSIAM/C01_v04_visual_qc_verdict.md`
- C04 v02 manifest: `run/roster-qc-2026-07-01/C04_HUMAN_CHABA/C04_baseline_v02_manifest.json`
- C04 v02 full playback: `run/roster-qc-2026-07-01/C04_HUMAN_CHABA/C04_skill_showcase_full_v02.mp4`
- C04 v02 zoom contact sheet: `run/roster-qc-2026-07-01/C04_HUMAN_CHABA/C04_skill_showcase_zoom_contact_v02.png`
- Fun Sprint 1 manifest: `run/first-session-fun-2026-07-01/fun_sprint_1_manifest.json`
- Fun Sprint 1 ready hint: `run/first-session-fun-2026-07-01/frames_ready_hint_v02/frame_00001.png`
- Fun Sprint 1 loop playback: `run/first-session-fun-2026-07-01/first_session_loop_v04.mp4`
- Fun Sprint 1 loop contact sheet: `run/first-session-fun-2026-07-01/first_session_loop_contact_v04.png`
- Art reboot v200 manifest: `run/art-reboot-2026-07-01/art_reboot_v200_manifest.json`
- Art reboot S01 pilot manifest: `run/art-reboot-2026-07-01/pilot/S01_GARUDA_VAYUDEJ/run-manifest.json`
- Art reboot S01 rejected candidate contact: `run/art-reboot-2026-07-01/pilot/S01_GARUDA_VAYUDEJ/64/qa/walk-south-candidate2-contact.png`
- Art reboot character contract audit: `run/art-reboot-2026-07-01/character_asset_contract_audit_v200.json`
- Art reboot Visual 100 gate report: `run/art-reboot-2026-07-01/visual_100_gate_report.md`
- Art reboot asset candidate manifest: `run/art-reboot-2026-07-01/asset_candidates_v200.json`
- Art reboot baseline validation summary: `run/art-reboot-2026-07-01/baseline-validation/baseline_validation_summary.md`
- Visual eye QC verdict: `run/visual-eye-qc-2026-07-01/visual_eye_qc_verdict.md`
- Visual 100 final capture script: `godot/game-siam-idle/tools/visual_100_final_capture.ps1`
- V103 VFX QC: `run/runtime-qc-2026-06-30/v103-skill-vfx-qc-2026-07-01.md`
- S01 V104 facing QC: `run/vfx-v104/s01-v104-facing-qc-2026-07-01.md`
