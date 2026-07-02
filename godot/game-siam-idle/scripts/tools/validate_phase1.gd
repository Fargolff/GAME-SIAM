extends SceneTree

const HERO_IDS := [
	"S01_GARUDA_VAYUDEJ",
	"S02_NAGA_SASINAKA",
	"S03_YAKSHA_KRAIASURA",
	"A02_TIGER_PLOENGPAYAK",
	"A03_HUMAN_ARUNRAT",
	"A06_SPIRIT_RAMPAN_MASK",
]

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
	for hero_id in HERO_IDS:
		var path := "res://generated/spriteframes/%s.tres" % hero_id
		var frames := load(path) as SpriteFrames
		if frames == null:
			failures.append("Missing SpriteFrames: %s" % path)
			continue
		for action in ACTIONS:
			for direction in DIRECTIONS:
				var animation := "%s_%s" % [action, direction]
				if not frames.has_animation(animation):
					failures.append("%s missing %s" % [hero_id, animation])
				elif frames.get_frame_count(animation) != 6:
					failures.append("%s %s expected 6 frames, got %d" % [hero_id, animation, frames.get_frame_count(animation)])

	if not FileAccess.file_exists("res://scenes/battle/Battle.tscn"):
		failures.append("Missing Battle.tscn")

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("Phase 1 validation passed for %d heroes." % HERO_IDS.size())
	quit(0)
