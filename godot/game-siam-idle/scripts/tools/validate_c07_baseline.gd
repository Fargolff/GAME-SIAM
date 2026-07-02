extends SceneTree

const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")
const HeroCatalogScript := preload("res://scripts/content/hero_catalog.gd")
const UnitViewScript := preload("res://scripts/presentation/unit_view.gd")
const BattleSceneScript := preload("res://scripts/battle/battle.gd")

const HERO_ID := "C07_GARUDA_PEEKTHONG"

func _initialize() -> void:
	var failures: Array[String] = []
	_check_profile(failures)
	_check_mapping(failures)
	_check_ranged_runtime(failures)
	if not failures.is_empty():
		for failure in failures:
			push_error(failure)
		quit(1)
		return
	print("validate_c07_baseline PASS")
	quit(0)

func _check_profile(failures: Array[String]) -> void:
	if HeroCatalogScript.archetype_for(HERO_ID) != "ranger":
		failures.append("C07 should remain ranger.")
	if HeroCatalogScript.skill_template_for(HERO_ID) != "single_target_burst":
		failures.append("C07 should remain single_target_burst.")
	var battle := BattleSceneScript.new()
	var profile: Dictionary = battle._skill_profile(HERO_ID)
	var runtime_mode := battle._personal_vfx_runtime_mode(profile)
	battle.free()
	if String(profile.get("signature", "")) != "dart":
		failures.append("C07 should use dart signature from PEEKTHONG DART.")
	if not bool(profile.get("show_streak", false)):
		failures.append("C07 dart should keep projectile travel readability.")
	if String(profile.get("personal_vfx", "")) == "":
		failures.append("C07 should have personal peacock dart VFX.")
	if runtime_mode != "":
		failures.append("C07 should use generic dart travel unless promoted to a named runtime mode, got %s." % runtime_mode)

func _check_mapping(failures: Array[String]) -> void:
	if not UnitViewScript.SIDE_LOCKED_ATTACK_IDS.has(HERO_ID):
		failures.append("C07 should use side-locked rows for spear/dart readability.")
	for action in ["attack_01", "skill_01"]:
		_expect_direction(failures, action, "east", "east")
		_expect_direction(failures, action, "north-east", "east")
		_expect_direction(failures, action, "south-east", "east")
		_expect_direction(failures, action, "west", "west")
		_expect_direction(failures, action, "north-west", "west")
		_expect_direction(failures, action, "south-west", "west")

func _expect_direction(failures: Array[String], action: String, raw_direction: String, expected_direction: String) -> void:
	var actual := UnitViewScript.combat_readable_direction_for(HERO_ID, action, raw_direction)
	if actual != expected_direction:
		failures.append("%s %s mapped to %s, expected %s" % [action, raw_direction, actual, expected_direction])

func _check_ranged_runtime(failures: Array[String]) -> void:
	var sim := BattleSimScript.new()
	var base: Dictionary = HeroCatalogScript.base_stats_for(HERO_ID)
	var hp: int = max(2600, int(base.get("hp", 300)) * 8)
	sim.units = [
		sim._unit("p1", "player", HERO_ID, Vector2(300, 365), Vector2(430, 365), hp, int(base["attack"]), int(base["defense"]), float(base["range"]), float(base["cooldown"]), float(base["move_speed"])),
		sim._unit("e1", "enemy", HERO_ID, Vector2(990, 365), Vector2(855, 365), hp, int(base["attack"]), int(base["defense"]), float(base["range"]), float(base["cooldown"]), float(base["move_speed"])),
	]
	var attack_frames := 0
	var close_attack_frames := 0
	var overreach_frames := 0
	var backward_walk_frames := 0
	var wrong_facing := ""
	var first_x := {"p1": 300.0, "e1": 990.0}
	var previous_x := first_x.duplicate()
	var last_x := first_x.duplicate()
	for _i in range(260):
		sim.tick(1.0 / 24.0)
		var by_id := {}
		for unit in sim.units:
			by_id[String(unit["id"])] = unit
		for unit in sim.units:
			var unit_id := String(unit["id"])
			var forward_sign := 1.0 if String(unit["team"]) == "player" else -1.0
			var current_x: float = float((unit["position"] as Vector2).x)
			if String(unit["state"]) == "walk" and (current_x - float(previous_x[unit_id])) * forward_sign < -0.05:
				backward_walk_frames += 1
			previous_x[unit_id] = current_x
			last_x[unit_id] = current_x
			if String(unit["state"]) != "attack_01":
				continue
			attack_frames += 1
			var shown_direction := UnitViewScript.combat_readable_direction_for(HERO_ID, "attack_01", String(unit["direction"]))
			if not ["east", "west"].has(shown_direction):
				wrong_facing = shown_direction
			var target_id := String(unit.get("target_id", ""))
			if by_id.has(target_id):
				var target: Dictionary = by_id[target_id]
				var distance: float = (unit["position"] as Vector2).distance_to(target["position"] as Vector2)
				if distance < 590.0:
					close_attack_frames += 1
				if distance > sim._attack_reach(unit) + 6.0:
					overreach_frames += 1
	if attack_frames <= 0:
		failures.append("C07 controlled ranged duel did not produce attack frames.")
	if close_attack_frames > 0:
		failures.append("C07 ranger attacked too close in %d frames." % close_attack_frames)
	if overreach_frames > 0:
		failures.append("C07 ranged attack exceeds reach in %d frames." % overreach_frames)
	if backward_walk_frames > 0:
		failures.append("C07 walked backward during controlled ranged approach in %d frames." % backward_walk_frames)
	if wrong_facing != "":
		failures.append("C07 ranged facing should stay side readable, got %s." % wrong_facing)
	for unit_id in ["p1", "e1"]:
		var forward_delta: float = (float(last_x[unit_id]) - float(first_x[unit_id])) * (1.0 if unit_id == "p1" else -1.0)
		if forward_delta > 75.0:
			failures.append("C07 ranger walked too far before/while attacking: %s %.1f px" % [unit_id, forward_delta])
