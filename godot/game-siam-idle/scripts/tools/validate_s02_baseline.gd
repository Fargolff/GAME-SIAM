extends SceneTree

const UnitViewScript := preload("res://scripts/presentation/unit_view.gd")

const HERO_ID := "S02_NAGA_SASINAKA"
const REQUIRED_ANIMATIONS := [
	"walk_east",
	"walk_west",
	"walk_north",
	"walk_south-west",
	"attack_01_east",
	"attack_01_west",
	"skill_01_east",
	"skill_01_west",
]

func _initialize() -> void:
	var failures: Array[String] = []
	_check_direction_mapping(failures)
	_check_sprite_frames(failures)
	if not failures.is_empty():
		for failure in failures:
			push_error(failure)
		quit(1)
		return
	print("validate_s02_baseline PASS")
	quit(0)

func _check_direction_mapping(failures: Array[String]) -> void:
	_expect_direction(failures, "attack_01", "east", "east")
	_expect_direction(failures, "attack_01", "north-east", "east")
	_expect_direction(failures, "attack_01", "south-east", "east")
	_expect_direction(failures, "attack_01", "west", "west")
	_expect_direction(failures, "attack_01", "north-west", "west")
	_expect_direction(failures, "attack_01", "south-west", "west")
	_expect_direction(failures, "skill_01", "east", "east")
	_expect_direction(failures, "skill_01", "west", "west")
	var default_mapping := UnitViewScript.combat_readable_direction_for("B02_NAGA_KLEDKRAM", "attack_01", "east")
	if default_mapping != "south-east":
		failures.append("Default non-side-locked attack mapping changed: %s" % default_mapping)

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
