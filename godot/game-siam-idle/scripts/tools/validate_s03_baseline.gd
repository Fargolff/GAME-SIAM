extends SceneTree

const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")
const UnitViewScript := preload("res://scripts/presentation/unit_view.gd")

const HERO_ID := "S03_YAKSHA_KRAIASURA"
const REQUIRED_ANIMATIONS := [
	"walk_east",
	"walk_west",
	"attack_01_east",
	"attack_01_west",
	"skill_01_east",
	"skill_01_west",
]

func _initialize() -> void:
	var failures: Array[String] = []
	_check_direction_mapping(failures)
	_check_sprite_frames(failures)
	_check_runtime_melee_readability(failures)
	if not failures.is_empty():
		for failure in failures:
			push_error(failure)
		quit(1)
		return
	print("validate_s03_baseline PASS")
	quit(0)

func _check_direction_mapping(failures: Array[String]) -> void:
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

func _check_sprite_frames(failures: Array[String]) -> void:
	var frames := load("res://generated/spriteframes/%s.tres" % HERO_ID) as SpriteFrames
	if frames == null:
		failures.append("Missing generated SpriteFrames for %s" % HERO_ID)
		return
	for animation in REQUIRED_ANIMATIONS:
		if not frames.has_animation(animation):
			failures.append("Missing animation: %s" % animation)
			continue
		if frames.get_frame_count(animation) != 6:
			failures.append("%s has %d frames, expected 6" % [animation, frames.get_frame_count(animation)])
	if frames.get_animation_loop("attack_01_east"):
		failures.append("attack_01_east should not loop")
	if not frames.get_animation_loop("walk_east"):
		failures.append("walk_east should loop")

func _check_runtime_melee_readability(failures: Array[String]) -> void:
	var sim := BattleSimScript.new()
	sim.setup_wave(10, BattleSimScript.default_formation(), {})
	var by_id := {}
	var attack_frames := 0
	var overreach_frames := 0
	var max_attack_distance := 0.0
	var wrong_facing := ""
	for i in range(180):
		sim.tick(1.0 / 12.0)
		by_id.clear()
		for unit in sim.units:
			by_id[String(unit["id"])] = unit
		for unit in sim.units:
			if String(unit["character_id"]) != HERO_ID:
				continue
			if String(unit["state"]) == "walk" and String(unit["team"]) == "player" and String(unit["direction"]) == "west":
				wrong_facing = "walk_west"
			if String(unit["state"]) != "attack_01":
				continue
			attack_frames += 1
			var shown_direction := UnitViewScript.combat_readable_direction_for(HERO_ID, "attack_01", String(unit["direction"]))
			if shown_direction != "east" and shown_direction != "west":
				wrong_facing = shown_direction
			var target_id := String(unit.get("target_id", ""))
			if by_id.has(target_id):
				var target: Dictionary = by_id[target_id]
				var distance: float = (unit["position"] as Vector2).distance_to(target["position"] as Vector2)
				max_attack_distance = maxf(max_attack_distance, distance)
				if distance > sim._attack_reach(unit) + 2.0:
					overreach_frames += 1
		if sim.result != "running":
			break
	if attack_frames <= 0:
		failures.append("S03 did not produce melee attack frames in wave 10.")
	if overreach_frames > 0:
		failures.append("S03 melee attack reads too far in %d frames, max %.1f px." % [overreach_frames, max_attack_distance])
	if wrong_facing != "":
		failures.append("S03 melee facing should stay readable east/west, got %s." % wrong_facing)
