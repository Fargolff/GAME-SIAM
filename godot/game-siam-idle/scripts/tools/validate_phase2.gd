extends SceneTree

const DirectionResolverScript := preload("res://scripts/presentation/direction_resolver.gd")

func _initialize() -> void:
	var checks := {
		"east": Vector2.RIGHT,
		"south-east": Vector2(1, 1),
		"south": Vector2.DOWN,
		"south-west": Vector2(-1, 1),
		"west": Vector2.LEFT,
		"north-west": Vector2(-1, -1),
		"north": Vector2.UP,
		"north-east": Vector2(1, -1),
	}

	var failures: Array[String] = []
	for expected in checks:
		var actual: String = DirectionResolverScript.direction_for_vector(checks[expected])
		if actual != expected:
			failures.append("Expected %s, got %s" % [expected, actual])

	if DirectionResolverScript.direction_for_vector(Vector2.ZERO, "west") != "west":
		failures.append("Zero vector did not preserve fallback direction.")

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("Phase 2 direction validation passed.")
	quit(0)
