extends SceneTree

const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")

func _initialize() -> void:
	var waves := [1, 7, 8, 10, 20]
	var report: Array[String] = []
	for wave in waves:
		report.append(_audit_wave(wave))
	print("\n".join(report))
	quit(0)

func _audit_wave(wave_id: int) -> String:
	var sim := BattleSimScript.new()
	sim.setup_wave(wave_id, BattleSimScript.default_formation(), {})
	var last_x_sign := {}
	var flips := {}
	var backward := {}
	var walk_samples := {}
	for i in range(360):
		sim.tick(0.1)
		for unit in sim.units:
			if not bool(unit["alive"]) or String(unit["state"]) != "walk":
				continue
			var unit_id := String(unit["id"])
			var velocity: Vector2 = unit["velocity"]
			if absf(velocity.x) < 8.0:
				continue
			var sign := 1 if velocity.x > 0.0 else -1
			walk_samples[unit_id] = int(walk_samples.get(unit_id, 0)) + 1
			if last_x_sign.has(unit_id) and int(last_x_sign[unit_id]) != sign:
				flips[unit_id] = int(flips.get(unit_id, 0)) + 1
			last_x_sign[unit_id] = sign
			if String(unit["team"]) == "player" and sign < 0:
				backward[unit_id] = int(backward.get(unit_id, 0)) + 1
			elif String(unit["team"]) == "enemy" and sign > 0:
				backward[unit_id] = int(backward.get(unit_id, 0)) + 1
		if sim.result != "running":
			break
	return "wave %d result=%s walk=%s flips=%s backward=%s" % [
		wave_id,
		sim.result,
		JSON.stringify(walk_samples),
		JSON.stringify(flips),
		JSON.stringify(backward),
	]
