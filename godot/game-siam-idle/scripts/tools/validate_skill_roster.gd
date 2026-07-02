extends SceneTree

const HeroCatalogScript := preload("res://scripts/content/hero_catalog.gd")
const BattleScript := preload("res://scripts/battle/battle.gd")

const REQUIRED_VFX := [
	BattleScript.VFX_SKILL_CHARGE_HAND,
	BattleScript.VFX_SKILL_RELEASE_FLASH,
	BattleScript.VFX_SKILL_PROJECTILE_TRAIL,
	BattleScript.VFX_SKILL_IMPACT_BURST_SHEET,
	BattleScript.VFX_SIGNATURE_GARUDA_WING,
	BattleScript.VFX_SIGNATURE_NAGA_SPIRAL,
	BattleScript.VFX_SIGNATURE_YAKSHA_STONE,
	BattleScript.VFX_SIGNATURE_KINNARI_BLOSSOM,
	BattleScript.VFX_SIGNATURE_TIGER_CLAW,
	BattleScript.VFX_SIGNATURE_HUMAN_ARROW_FAN,
	BattleScript.VFX_SIGNATURE_SPIRIT_WISP,
	BattleScript.VFX_SIGNATURE_ARROW_TRAJECTORY,
	BattleScript.VFX_SIGNATURE_NAGA_STORM,
	BattleScript.VFX_SIGNATURE_NAGA_BODY_STORM,
	BattleScript.VFX_SIGNATURE_AEGIS_SHIELD,
]

const MIN_PERSONAL_VFX_COVERAGE := 40
const V88_PERSONAL_MIN_REGENERATED := 40
const V89_PERSONAL_MIN_REGENERATED := 12
const V90_PERSONAL_MIN_REGENERATED := 8
const V91_PERSONAL_MIN_REGENERATED := 5
const V92_PERSONAL_MIN_REGENERATED := 2
const V93_PERSONAL_MIN_REGENERATED := 40
const V97_PERSONAL_MIN_REGENERATED := 10
const V98_PERSONAL_MIN_REGENERATED := 10
const V99_PERSONAL_MIN_REGENERATED := 3
const V100_PERSONAL_MIN_REGENERATED := 3
const V101_PERSONAL_MIN_REGENERATED := 2
const V102_PERSONAL_MIN_REGENERATED := 10
const V103_PERSONAL_MIN_REGENERATED := 10
const V104_PERSONAL_MIN_REGENERATED := 1

func _initialize() -> void:
	var failures: Array[String] = []
	var heroes := HeroCatalogScript.all_heroes()
	if heroes.size() != 40:
		failures.append("Expected 40 heroes, got %d." % heroes.size())
	if HeroCatalogScript.HERO_SKILL_NAMES.size() != heroes.size():
		failures.append("Every hero needs an explicit skill name.")
	var battle := BattleScript.new()
	battle.skill_focus_timer = 0.2
	if not battle._skill_focus_active():
		failures.append("Skill focus window must suppress non-skill VFX while active.")
	battle.skill_focus_timer = 0.0
	if battle._skill_focus_active():
		failures.append("Skill focus window must clear when timer reaches zero.")
	if battle._uses_impact_texture({"signature": "burst"}):
		failures.append("Runtime should not use legacy non-native impact textures.")
	var skill_ids := {}
	var profile_signatures := {}
	var template_signatures := {}
	var variant_indices := {}
	var personal_vfx_paths := {}
	var regenerated_v88_or_newer_count := 0
	var regenerated_v89_count := 0
	var regenerated_v90_count := 0
	var regenerated_v91_count := 0
	var regenerated_v92_count := 0
	var regenerated_v93_count := 0
	var regenerated_v97_count := 0
	var regenerated_v98_count := 0
	var regenerated_v99_count := 0
	var regenerated_v100_count := 0
	var regenerated_v101_count := 0
	var regenerated_v102_count := 0
	var regenerated_v103_count := 0
	var regenerated_v104_count := 0
	if BattleScript.PERSONAL_VFX_BY_HERO.size() < MIN_PERSONAL_VFX_COVERAGE:
		failures.append("Expected at least %d personal VFX mappings, got %d." % [MIN_PERSONAL_VFX_COVERAGE, BattleScript.PERSONAL_VFX_BY_HERO.size()])
	for mapped_hero in BattleScript.PERSONAL_VFX_BY_HERO.keys():
		var mapped_hero_id := String(mapped_hero)
		if not HeroCatalogScript.has_hero(mapped_hero_id):
			failures.append("Personal VFX mapping references unknown hero %s." % mapped_hero_id)
		var mapped_path := String(BattleScript.PERSONAL_VFX_BY_HERO[mapped_hero])
		if mapped_path.strip_edges() == "":
			failures.append("%s has empty personal VFX path." % mapped_hero_id)
		if personal_vfx_paths.has(mapped_path):
			failures.append("%s duplicates personal VFX asset path %s." % [mapped_hero_id, mapped_path])
		personal_vfx_paths[mapped_path] = mapped_hero_id
		if _is_vfx_version_at_least(mapped_path, 93):
			regenerated_v93_count += 1
		else:
			failures.append("%s must use an all-40 V93 personal VFX but maps to %s." % [mapped_hero_id, mapped_path.get_file()])
		if BattleScript.V88_REQUIRED_PERSONAL_VFX.has(mapped_hero_id):
			if not _is_vfx_version_at_least(mapped_path, 88):
				failures.append("%s must use a V88-or-newer personal VFX but maps to %s." % [mapped_hero_id, mapped_path.get_file()])
			else:
				regenerated_v88_or_newer_count += 1
		if BattleScript.V89_REQUIRED_PERSONAL_VFX.has(mapped_hero_id):
			if not _is_vfx_version_at_least(mapped_path, 89):
				failures.append("%s is in the V89 uniqueness-fix set but still maps to %s." % [mapped_hero_id, mapped_path.get_file()])
			else:
				regenerated_v89_count += 1
		if BattleScript.V90_REQUIRED_PERSONAL_VFX.has(mapped_hero_id):
			if not _is_vfx_version_at_least(mapped_path, 90):
				failures.append("%s is in the V90 family-overlap fix set but still maps to %s." % [mapped_hero_id, mapped_path.get_file()])
			else:
				regenerated_v90_count += 1
		if BattleScript.V91_REQUIRED_PERSONAL_VFX.has(mapped_hero_id):
			if not _is_vfx_version_at_least(mapped_path, 91):
				failures.append("%s is in the V91 combat-readability fix set but still maps to %s." % [mapped_hero_id, mapped_path.get_file()])
			else:
				regenerated_v91_count += 1
		if BattleScript.V92_REQUIRED_PERSONAL_VFX.has(mapped_hero_id):
			if not _is_vfx_version_at_least(mapped_path, 92):
				failures.append("%s is in the V92 arrow-readability fix set but still maps to %s." % [mapped_hero_id, mapped_path.get_file()])
			else:
				regenerated_v92_count += 1
		if BattleScript.V97_REQUIRED_PERSONAL_VFX.has(mapped_hero_id):
			if not _is_vfx_version_at_least(mapped_path, 97):
				failures.append("%s is in the V97 support/taunt/debuff readability fix set but still maps to %s." % [mapped_hero_id, mapped_path.get_file()])
			else:
				regenerated_v97_count += 1
		if BattleScript.V98_REQUIRED_PERSONAL_VFX.has(mapped_hero_id):
			if not _is_vfx_version_at_least(mapped_path, 98):
				failures.append("%s is in the V98 root/debuff/summon/heal readability fix set but still maps to %s." % [mapped_hero_id, mapped_path.get_file()])
			else:
				regenerated_v98_count += 1
		if BattleScript.V99_REQUIRED_PERSONAL_VFX.has(mapped_hero_id):
			if not _is_vfx_version_at_least(mapped_path, 99):
				failures.append("%s is in the V99 icon-readability fix set but still maps to %s." % [mapped_hero_id, mapped_path.get_file()])
			else:
				regenerated_v99_count += 1
		if BattleScript.V100_REQUIRED_PERSONAL_VFX.has(mapped_hero_id):
			if not _is_vfx_version_at_least(mapped_path, 100):
				failures.append("%s is in the V100 heal-role readability fix set but still maps to %s." % [mapped_hero_id, mapped_path.get_file()])
			else:
				regenerated_v100_count += 1
		if BattleScript.V101_REQUIRED_PERSONAL_VFX.has(mapped_hero_id):
			if not _is_vfx_version_at_least(mapped_path, 101):
				failures.append("%s is in the V101 support/heal runtime blocker fix set but still maps to %s." % [mapped_hero_id, mapped_path.get_file()])
			else:
				regenerated_v101_count += 1
		if BattleScript.V102_REQUIRED_PERSONAL_VFX.has(mapped_hero_id):
			if not _is_vfx_version_at_least(mapped_path, 102):
				failures.append("%s is in the V102 subagent-prioritized V93 blocker fix set but still maps to %s." % [mapped_hero_id, mapped_path.get_file()])
			else:
				regenerated_v102_count += 1
		if BattleScript.V103_REQUIRED_PERSONAL_VFX.has(mapped_hero_id):
			if not _is_vfx_version_at_least(mapped_path, 103):
				failures.append("%s is in the V103 remaining V93 replacement set but still maps to %s." % [mapped_hero_id, mapped_path.get_file()])
			else:
				regenerated_v103_count += 1
		if BattleScript.V104_REQUIRED_PERSONAL_VFX.has(mapped_hero_id):
			if not _is_vfx_version_at_least(mapped_path, 104):
				failures.append("%s is in the V104 one-character pilot set but still maps to %s." % [mapped_hero_id, mapped_path.get_file()])
			else:
				regenerated_v104_count += 1
	for default_hero in HeroCatalogScript.DEFAULT_FORMATION:
		if not BattleScript.PERSONAL_VFX_BY_HERO.has(default_hero):
			failures.append("%s is in default formation but has no personal VFX mapping." % default_hero)
	if regenerated_v88_or_newer_count < V88_PERSONAL_MIN_REGENERATED:
		failures.append("Expected at least %d personal VFX to be regenerated as V88-or-newer, got %d." % [V88_PERSONAL_MIN_REGENERATED, regenerated_v88_or_newer_count])
	if regenerated_v89_count < V89_PERSONAL_MIN_REGENERATED:
		failures.append("Expected at least %d V89 uniqueness-fix personal VFX, got %d." % [V89_PERSONAL_MIN_REGENERATED, regenerated_v89_count])
	if regenerated_v90_count < V90_PERSONAL_MIN_REGENERATED:
		failures.append("Expected at least %d V90 family-overlap personal VFX, got %d." % [V90_PERSONAL_MIN_REGENERATED, regenerated_v90_count])
	if regenerated_v91_count < V91_PERSONAL_MIN_REGENERATED:
		failures.append("Expected at least %d V91 combat-readability personal VFX, got %d." % [V91_PERSONAL_MIN_REGENERATED, regenerated_v91_count])
	if regenerated_v92_count < V92_PERSONAL_MIN_REGENERATED:
		failures.append("Expected at least %d V92 arrow-readability personal VFX, got %d." % [V92_PERSONAL_MIN_REGENERATED, regenerated_v92_count])
	if regenerated_v93_count < V93_PERSONAL_MIN_REGENERATED:
		failures.append("Expected all %d personal VFX to be regenerated as V93, got %d." % [V93_PERSONAL_MIN_REGENERATED, regenerated_v93_count])
	if regenerated_v97_count < V97_PERSONAL_MIN_REGENERATED:
		failures.append("Expected at least %d V97 support/taunt/debuff readability fixes, got %d." % [V97_PERSONAL_MIN_REGENERATED, regenerated_v97_count])
	if regenerated_v98_count < V98_PERSONAL_MIN_REGENERATED:
		failures.append("Expected at least %d V98 root/debuff/summon/heal readability fixes, got %d." % [V98_PERSONAL_MIN_REGENERATED, regenerated_v98_count])
	if regenerated_v99_count < V99_PERSONAL_MIN_REGENERATED:
		failures.append("Expected at least %d V99 icon-readability fixes, got %d." % [V99_PERSONAL_MIN_REGENERATED, regenerated_v99_count])
	if regenerated_v100_count < V100_PERSONAL_MIN_REGENERATED:
		failures.append("Expected at least %d V100 heal-role readability fixes, got %d." % [V100_PERSONAL_MIN_REGENERATED, regenerated_v100_count])
	if regenerated_v101_count < V101_PERSONAL_MIN_REGENERATED:
		failures.append("Expected at least %d V101 support/heal runtime blocker fixes, got %d." % [V101_PERSONAL_MIN_REGENERATED, regenerated_v101_count])
	if regenerated_v102_count < V102_PERSONAL_MIN_REGENERATED:
		failures.append("Expected at least %d V102 subagent-prioritized V93 blocker fixes, got %d." % [V102_PERSONAL_MIN_REGENERATED, regenerated_v102_count])
	if regenerated_v103_count < V103_PERSONAL_MIN_REGENERATED:
		failures.append("Expected at least %d V103 remaining V93 replacement fixes, got %d." % [V103_PERSONAL_MIN_REGENERATED, regenerated_v103_count])
	if regenerated_v104_count < V104_PERSONAL_MIN_REGENERATED:
		failures.append("Expected at least %d V104 one-character pilot personal VFX, got %d." % [V104_PERSONAL_MIN_REGENERATED, regenerated_v104_count])
	for hero_id in heroes:
		var template := HeroCatalogScript.skill_template_for(hero_id)
		var name := HeroCatalogScript.skill_name_for(hero_id).strip_edges()
		var skill_id := HeroCatalogScript.skill_id_for(hero_id)
		if not HeroCatalogScript.SKILL_TEMPLATES.has(template):
			failures.append("%s has unknown skill template %s." % [hero_id, template])
		if name == "":
			failures.append("%s has empty skill name." % hero_id)
		if name.length() > 22:
			failures.append("%s skill name is too long for battle banner: %s." % [hero_id, name])
		if skill_ids.has(skill_id):
			failures.append("%s duplicates skill id %s." % [hero_id, skill_id])
		skill_ids[skill_id] = true
		var profile: Dictionary = battle._skill_profile(hero_id)
		if BattleScript.PERSONAL_VFX_BY_HERO.has(hero_id):
			var personal_vfx := String(profile.get("personal_vfx", ""))
			if personal_vfx == "":
				failures.append("%s is mapped but has no runtime personal VFX key." % hero_id)
			if battle._personal_vfx_key_for_hero(hero_id) != personal_vfx:
				failures.append("%s personal VFX mapping differs between Battle constants and runtime profile." % hero_id)
		var variant_index := int(profile.get("variant_index", -1))
		if variant_index < 0 or variant_index >= heroes.size():
			failures.append("%s has invalid skill VFX variant index %d." % [hero_id, variant_index])
		if variant_indices.has(variant_index):
			failures.append("%s duplicates skill VFX variant index %d." % [hero_id, variant_index])
		variant_indices[variant_index] = true
		var runtime_signature := String(profile.get("signature", "")).strip_edges()
		if runtime_signature == "":
			failures.append("%s has no runtime skill VFX signature." % hero_id)
		if not template_signatures.has(template):
			template_signatures[template] = {}
		template_signatures[template][runtime_signature] = true
		var signature := _profile_signature(profile)
		if profile_signatures.has(signature):
			failures.append("%s duplicates a skill profile signature." % hero_id)
		profile_signatures[signature] = true
		var frames := load("res://generated/spriteframes/%s.tres" % hero_id) as SpriteFrames
		if frames == null or not frames.has_animation("skill_01_south"):
			failures.append("%s missing skill_01_south animation." % hero_id)
	battle.free()
	for path in REQUIRED_VFX:
		if not FileAccess.file_exists(path):
			failures.append("Missing skill VFX asset: %s" % path)
	for template in HeroCatalogScript.SKILL_TEMPLATES:
		if not template_signatures.has(template) or Dictionary(template_signatures[template]).is_empty():
			failures.append("Skill template %s has no runtime VFX signature coverage." % template)
	for index in range(heroes.size()):
		if not variant_indices.has(index):
			failures.append("Missing skill VFX variant index %d." % index)
	_validate_strip(BattleScript.VFX_SKILL_CHARGE_HAND, BattleScript.SKILL_CHARGE_HAND_FRAMES, "charge hand", failures)
	_validate_strip(BattleScript.VFX_SKILL_RELEASE_FLASH, BattleScript.SKILL_RELEASE_FLASH_FRAMES, "release flash", failures)
	_validate_strip(BattleScript.VFX_SKILL_PROJECTILE_TRAIL, BattleScript.SKILL_PROJECTILE_TRAIL_FRAMES, "projectile trail", failures)
	_validate_strip(BattleScript.VFX_SKILL_IMPACT_BURST_SHEET, BattleScript.SKILL_IMPACT_BURST_FRAMES, "impact burst", failures)
	_validate_static_vfx(BattleScript.VFX_SIGNATURE_GARUDA_WING, "garuda signature", failures)
	_validate_static_vfx(BattleScript.VFX_SIGNATURE_NAGA_SPIRAL, "naga signature", failures)
	_validate_static_vfx(BattleScript.VFX_SIGNATURE_YAKSHA_STONE, "yaksha signature", failures)
	_validate_static_vfx(BattleScript.VFX_SIGNATURE_KINNARI_BLOSSOM, "kinnari signature", failures)
	_validate_static_vfx(BattleScript.VFX_SIGNATURE_TIGER_CLAW, "tiger signature", failures)
	_validate_static_vfx(BattleScript.VFX_SIGNATURE_HUMAN_ARROW_FAN, "human arrow signature", failures)
	_validate_static_vfx(BattleScript.VFX_SIGNATURE_SPIRIT_WISP, "spirit signature", failures)
	_validate_static_vfx(BattleScript.VFX_SIGNATURE_ARROW_TRAJECTORY, "v62 arrow trajectory signature", failures)
	_validate_static_vfx(BattleScript.VFX_SIGNATURE_NAGA_STORM, "v62 naga storm signature", failures)
	_validate_strip(BattleScript.VFX_SIGNATURE_NAGA_BODY_STORM, 6, "v72 naga body storm signature", failures)
	_validate_static_vfx(BattleScript.VFX_SIGNATURE_AEGIS_SHIELD, "v62 aegis shield signature", failures)
	for path in personal_vfx_paths.keys():
		var hero_for_path := String(personal_vfx_paths[path])
		_validate_strip(String(path), BattleScript.PERSONAL_VFX_FRAMES, "%s personal VFX" % hero_for_path, failures, BattleScript.V88_REQUIRED_PERSONAL_VFX.has(hero_for_path) or BattleScript.V89_REQUIRED_PERSONAL_VFX.has(hero_for_path) or BattleScript.V90_REQUIRED_PERSONAL_VFX.has(hero_for_path) or BattleScript.V91_REQUIRED_PERSONAL_VFX.has(hero_for_path) or BattleScript.V92_REQUIRED_PERSONAL_VFX.has(hero_for_path) or BattleScript.V97_REQUIRED_PERSONAL_VFX.has(hero_for_path) or BattleScript.V98_REQUIRED_PERSONAL_VFX.has(hero_for_path) or BattleScript.V99_REQUIRED_PERSONAL_VFX.has(hero_for_path) or BattleScript.V100_REQUIRED_PERSONAL_VFX.has(hero_for_path) or BattleScript.V101_REQUIRED_PERSONAL_VFX.has(hero_for_path) or BattleScript.V102_REQUIRED_PERSONAL_VFX.has(hero_for_path) or BattleScript.V103_REQUIRED_PERSONAL_VFX.has(hero_for_path) or BattleScript.V104_REQUIRED_PERSONAL_VFX.has(hero_for_path))
	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return
	print("Skill roster validation passed: 40 unique personal skills, runtime VFX signatures, %d mapped personal attack/skill VFX strips, no mapped V93 baseline strips remain, 1 V104 S01 pilot, 10 V97 support/taunt/debuff readability fixes, 10 V98 root/debuff/summon/heal readability fixes, 3 V99 icon-readability fixes, 3 V100 heal-role fixes, 2 V101 support/heal runtime blocker fixes, 10 V102 subagent-prioritized V93 blocker fixes, 10 V103 remaining V93 replacement fixes, 40 V88-or-newer strips, 12 V89 uniqueness fixes, 8 V90 family-overlap fixes, 5 V91 combat-readability fixes, 2 V92 arrow-readability fixes, skill animations, v72/v62/v59 signature stamps, v53/v52/v51 native 64px runtime strips, oversized atlas/impact/cast textures disabled" % BattleScript.PERSONAL_VFX_BY_HERO.size())
	quit(0)

func _validate_strip(path: String, frames: int, label: String, failures: Array[String], strict_visual := false) -> void:
	var texture := load(path) as Texture2D
	if texture == null:
		failures.append("%s strip cannot be loaded: %s" % [label, path])
		return
	if texture.get_width() % frames != 0:
		failures.append("%s strip width must divide into %d equal frames." % [label, frames])
		return
	var frame_width := texture.get_width() / frames
	if frame_width != 64 or texture.get_height() != 64:
		failures.append("%s strip must be native 64x64 frames, got %dx%d." % [label, frame_width, texture.get_height()])
		return
	_validate_strip_visuals(texture, frames, label, failures, strict_visual)

func _validate_strip_visuals(texture: Texture2D, frames: int, label: String, failures: Array[String], strict_visual: bool) -> void:
	var image := texture.get_image()
	if image == null:
		failures.append("%s strip image data cannot be inspected." % label)
		return
	var active_frames := 0
	var moving_intervals := 0
	var max_bbox_w := 0
	var max_bbox_h := 0
	for frame in range(frames):
		var min_x := 64
		var min_y := 64
		var max_x := -1
		var max_y := -1
		var coverage := 0
		for y in range(64):
			for x in range(64):
				var color := image.get_pixel(frame * 64 + x, y)
				if color.a > 0.5:
					coverage += 1
					min_x = mini(min_x, x)
					min_y = mini(min_y, y)
					max_x = maxi(max_x, x)
					max_y = maxi(max_y, y)
		if coverage > 0:
			active_frames += 1
			max_bbox_w = maxi(max_bbox_w, max_x - min_x + 1)
			max_bbox_h = maxi(max_bbox_h, max_y - min_y + 1)
	for frame in range(frames - 1):
		var changed_pixels := 0
		for y in range(64):
			for x in range(64):
				var a := image.get_pixel(frame * 64 + x, y)
				var b := image.get_pixel((frame + 1) * 64 + x, y)
				if absf(a.a - b.a) > 0.5 or absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > 0.28:
					changed_pixels += 1
		if changed_pixels >= 42:
			moving_intervals += 1
	var min_w := 20
	var min_h := 14
	var min_active := 4
	var min_motion := 3
	if strict_visual:
		min_w = 30
		min_h = 24
		min_active = 5
		min_motion = 4
	if active_frames < min_active:
		failures.append("%s strip has too few active frames: %d/%d." % [label, active_frames, frames])
	if max_bbox_w < min_w or max_bbox_h < min_h:
		failures.append("%s strip visual bbox is too small for runtime readability: %dx%d." % [label, max_bbox_w, max_bbox_h])
	if moving_intervals < min_motion:
		failures.append("%s strip motion is too weak: %d moving intervals." % [label, moving_intervals])

func _validate_static_vfx(path: String, label: String, failures: Array[String]) -> void:
	var texture := load(path) as Texture2D
	if texture == null:
		failures.append("%s texture cannot be loaded: %s" % [label, path])
		return
	if texture.get_width() != 64 or texture.get_height() != 64:
		failures.append("%s texture must be native 64x64, got %dx%d." % [label, texture.get_width(), texture.get_height()])

func _is_vfx_version_at_least(path: String, min_version: int) -> bool:
	var file_name := path.get_file()
	var marker := file_name.rfind("_v")
	if marker < 0:
		return false
	var suffix := file_name.substr(marker + 2, file_name.length() - marker - 2)
	if suffix.ends_with(".png"):
		suffix = suffix.substr(0, suffix.length() - 4)
	return int(suffix) >= min_version

func _profile_signature(profile: Dictionary) -> String:
	var tint: Color = profile["tint"]
	return "%s|%s|%.2f|%d|%.1f|%.2f|%.1f|%.1f|%.1f|%.2f|%s" % [
		profile["cast_texture"],
		profile["impact_texture"],
		float(profile["damage_multiplier"]),
		int(profile["flat_damage"]),
		float(profile["radius"]),
		float(profile["delay"]),
		float(profile["cast_size"]),
		float(profile["release_size"]),
		float(profile["impact_size"]),
		float(profile["impact_rotation"]),
		tint.to_html(false),
	]
