extends SceneTree

const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")
const HeroCatalogScript := preload("res://scripts/content/hero_catalog.gd")
const UnitViewScript := preload("res://scripts/presentation/unit_view.gd")

const HERO_ID := "A02_TIGER_PLOENGPAYAK"
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
	_check_controlled_melee_runtime(failures)
	if not failures.is_empty():
		for failure in failures:
			push_error(failure)
		quit(1)
		return
	print("validate_a02_baseline PASS")
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
	if not frames.get_animation_loop("walk_east"):
		failures.append("walk_east should loop")
	if frames.get_animation_loop("attack_01_east"):
		failures.append("attack_01_east should not loop")
	if frames.get_animation_loop("skill_01_east"):
		failures.append("skill_01_east should not loop")

func _check_controlled_melee_runtime(failures: Array[String]) -> void:
	var sim := BattleSimScript.new()
	var base: Dictionary = HeroCatalogScript.base_stats_for(HERO_ID)
	var hp: int = max(2600, int(base.get("hp", 300)) * 8)
	var attack: int = max(12, int(base.get("attack", 24)))
	var defense: int = max(1, int(base.get("defense", 8)))
	var attack_range: float = float(base.get("range", 56.0))
	var cooldown: float = float(base.get("cooldown", 1.15))
	var move_speed: float = float(base.get("move_speed", 92.0))
	sim.units = [
		sim._unit("p1", "player", HERO_ID, Vector2(300, 365), Vector2(430, 365), hp, attack, defense, attack_range, cooldown, move_speed),
		sim._unit("e1", "enemy", HERO_ID, Vector2(990, 365), Vector2(855, 365), hp, attack, defense, attack_range, cooldown, move_speed),
	]

	var attack_frames := 0
	var overreach_frames := 0
	var backward_walk_frames := 0
	var wrong_facing := ""
	var previous_x := {"p1": 300.0, "e1": 990.0}
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
				if distance > sim._attack_reach(unit) + 2.0:
					overreach_frames += 1
	if attack_frames <= 0:
		failures.append("A02 controlled melee duel did not produce attack frames.")
	if overreach_frames > 0:
		failures.append("A02 melee attack reads too far in %d frames." % overreach_frames)
	if backward_walk_frames > 0:
		failures.append("A02 walked backward during controlled approach in %d frames." % backward_walk_frames)
	if wrong_facing != "":
		failures.append("A02 melee facing should stay readable east/west, got %s." % wrong_facing)
