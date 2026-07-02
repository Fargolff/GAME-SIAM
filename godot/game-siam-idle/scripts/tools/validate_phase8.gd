extends SceneTree

const HeroCatalogScript := preload("res://scripts/content/hero_catalog.gd")
const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")

const ACTIONS := [
	"idle",
	"walk",
	"attack_01",
	"skill_01",
	"hurt",
	"death",
]

const DIRECTIONS := [
	"south",
	"south-east",
	"east",
	"north-east",
	"north",
	"north-west",
	"west",
	"south-west",
]

func _initialize() -> void:
	var failures: Array[String] = []
	var hero_ids := HeroCatalogScript.all_heroes()

	if hero_ids.size() != 40:
		failures.append("Hero catalog should contain 40 heroes, got %d." % hero_ids.size())
	if BattleSimScript.MAX_WAVE != 100:
		failures.append("BattleSim.MAX_WAVE should be 100 for launch pool campaign.")

	_validate_spriteframes(hero_ids, failures)
	_validate_catalog_contract(hero_ids, failures)
	_validate_campaign_contract(failures)
	_validate_wave_smoke(failures)

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("Phase 8 validation passed: 40 heroes, 8 archetypes, 100 waves, no-softlock smoke")
	quit(0)

func _validate_spriteframes(hero_ids: Array[String], failures: Array[String]) -> void:
	for hero_id in hero_ids:
		for action in ACTIONS:
			var sheet_path := "res://assets/characters/GameSiam/%s/%s-sheet-clean.png" % [hero_id, action]
			var metadata_path := "res://assets/characters/GameSiam/%s/%s-metadata.json" % [hero_id, action]
			if not FileAccess.file_exists(sheet_path):
				failures.append("Missing sheet: %s" % sheet_path)
			if not FileAccess.file_exists(metadata_path):
				failures.append("Missing metadata: %s" % metadata_path)

		var frames_path := "res://generated/spriteframes/%s.tres" % hero_id
		var frames := load(frames_path) as SpriteFrames
		if frames == null:
			failures.append("Missing SpriteFrames: %s" % frames_path)
			continue

		for action in ACTIONS:
			for direction in DIRECTIONS:
				var animation := "%s_%s" % [action, direction]
				if not frames.has_animation(animation):
					failures.append("%s missing %s" % [hero_id, animation])
				elif frames.get_frame_count(animation) != 6:
					failures.append("%s %s expected 6 frames, got %d" % [hero_id, animation, frames.get_frame_count(animation)])

func _validate_catalog_contract(hero_ids: Array[String], failures: Array[String]) -> void:
	var archetypes_seen := {}
	var skills_seen := {}
	for hero_id in hero_ids:
		var archetype := HeroCatalogScript.archetype_for(hero_id)
		var skill := HeroCatalogScript.skill_template_for(hero_id)
		if not HeroCatalogScript.ARCHETYPES.has(archetype):
			failures.append("%s has unknown archetype %s." % [hero_id, archetype])
		if not HeroCatalogScript.SKILL_TEMPLATES.has(skill):
			failures.append("%s has unknown skill template %s." % [hero_id, skill])
		var skill_name := HeroCatalogScript.skill_name_for(hero_id).strip_edges()
		if skill_name == "":
			failures.append("%s has empty skill name." % hero_id)
		elif skill_name.length() > 22:
			failures.append("%s skill name is too long for the battle banner: %s." % [hero_id, skill_name])
		archetypes_seen[archetype] = true
		skills_seen[skill] = true
	if HeroCatalogScript.HERO_SKILL_NAMES.size() != hero_ids.size():
		failures.append("Every hero should have an explicit skill name.")

	for archetype in HeroCatalogScript.ARCHETYPES:
		if not archetypes_seen.has(archetype):
			failures.append("Archetype is unused: %s" % archetype)
	for skill in HeroCatalogScript.SKILL_TEMPLATES:
		if not skills_seen.has(skill):
			failures.append("Skill template is unused: %s" % skill)

func _validate_campaign_contract(failures: Array[String]) -> void:
	var families_seen := {}
	for wave_id in range(1, 101):
		var wave: Dictionary = HeroCatalogScript.campaign_wave(wave_id)
		if bool(wave["boss"]) != (wave_id % 10 == 0):
			failures.append("Wave %d boss flag mismatch." % wave_id)
		families_seen[String(wave["enemy_family"])] = true
		if int(wave["enemy_count"]) < 3 or int(wave["enemy_count"]) > 5:
			failures.append("Wave %d enemy count out of range." % wave_id)

	for family in HeroCatalogScript.ENEMY_FAMILIES:
		if not families_seen.has(family):
			failures.append("Enemy family is unused: %s" % family)

func _validate_wave_smoke(failures: Array[String]) -> void:
	var formation := BattleSimScript.default_formation()
	for wave_id in range(1, 101):
		var levels := {}
		for hero_id in formation:
			levels[hero_id] = max(1, int(wave_id / 4) + 1)
		var sim := BattleSimScript.new()
		sim.setup_wave(wave_id, formation, levels)
		for i in range(1800):
			sim.tick(0.1)
			if sim.result != "running":
				break
		if sim.result == "running":
			failures.append("Wave %d did not resolve within smoke budget." % wave_id)
			return
