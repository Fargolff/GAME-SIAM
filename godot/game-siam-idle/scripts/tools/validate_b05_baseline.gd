extends SceneTree

const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")
const HeroCatalogScript := preload("res://scripts/content/hero_catalog.gd")
const UnitViewScript := preload("res://scripts/presentation/unit_view.gd")
const BattleSceneScript := preload("res://scripts/battle/battle.gd")

const HERO_ID := "B05_KINNARA_RAVIKAN"

func _initialize() -> void:
	var failures: Array[String] = []
	_check_profile(failures)
	_check_mapping(failures)
	_check_ranged_support_runtime(failures)
	if not failures.is_empty():
		for failure in failures:
			push_error(failure)
		quit(1)
		return
	print("validate_b05_baseline PASS")
	quit(0)

func _check_profile(failures: Array[String]) -> void:
	if HeroCatalogScript.archetype_for(HERO_ID) != "support":
		failures.append("B05 should remain support.")
	if HeroCatalogScript.skill_template_for(HERO_ID) != "shield_heal":
		failures.append("B05 should remain shield_heal.")
	var battle := BattleSceneScript.new()
	var profile: Dictionary = battle._skill_profile(HERO_ID)
	battle.free()
	if String(profile.get("signature", "")) != "blossom":
		failures.append("B05 should use blossom support signature.")
	if bool(profile.get("show_streak", true)):
		failures.append("B05 support skill should not use the generic projectile streak.")
	if String(profile.get("personal_vfx", "")) == "":
		failures.append("B05 should have personal music-wave VFX.")

func _check_mapping(failures: Array[String]) -> void:
	if UnitViewScript.SIDE_LOCKED_ATTACK_IDS.has(HERO_ID):
		failures.append("B05 should use readable front-diagonal support rows, not side-locked melee rows.")
	_expect_direction(failures, "attack_01", "east", "south-east")
	_expect_direction(failures, "skill_01", "east", "south-east")
	_expect_direction(failures, "attack_01", "west", "south-west")
	_expect_direction(failures, "skill_01", "west", "south-west")

func _expect_direction(failures: Array[String], action: String, raw_direction: String, expected_direction: String) -> void:
	var actual := UnitViewScript.combat_readable_direction_for(HERO_ID, action, raw_direction)
	if actual != expected_direction:
		failures.append("%s %s mapped to %s, expected %s" % [action, raw_direction, actual, expected_direction])

func _check_ranged_support_runtime(failures: Array[String]) -> void:
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
			var target_id := String(unit.get("target_id", ""))
			if by_id.has(target_id):
				var target: Dictionary = by_id[target_id]
				var distance: float = (unit["position"] as Vector2).distance_to(target["position"] as Vector2)
				if distance > sim._attack_reach(unit) + 2.0:
					overreach_frames += 1
				if distance < 500.0:
					close_attack_frames += 1
	if attack_frames <= 0:
		failures.append("B05 controlled support duel did not produce attack frames.")
	if close_attack_frames > 0:
		failures.append("B05 support attack happened too close in %d frames." % close_attack_frames)
	if overreach_frames > 0:
		failures.append("B05 support attack exceeds reach in %d frames." % overreach_frames)
	if backward_walk_frames > 0:
		failures.append("B05 walked backward during controlled approach in %d frames." % backward_walk_frames)
	for unit_id in ["p1", "e1"]:
		var forward_delta: float = (float(last_x[unit_id]) - float(first_x[unit_id])) * (1.0 if unit_id == "p1" else -1.0)
		if forward_delta > 120.0:
			failures.append("B05 support moved too far before/while attacking: %s %.1f px" % [unit_id, forward_delta])
