extends SceneTree

const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")

func _initialize() -> void:
	var out_path := OS.get_environment("GAME_SIAM_MOVEMENT_QC_JSON").strip_edges()
	if out_path == "":
		out_path = "user://movement_qc.json"
	var sim := BattleSimScript.new()
	sim.setup_wave(10, BattleSimScript.default_formation(), {})
	var frames: Array[Dictionary] = []
	for i in range(180):
		sim.tick(1.0 / 12.0)
		if i % 2 != 0:
			continue
		var units: Array[Dictionary] = []
		for unit in sim.units:
			units.append({
				"id": String(unit["id"]),
				"team": String(unit["team"]),
				"character_id": String(unit["character_id"]),
				"x": float((unit["position"] as Vector2).x),
				"y": float((unit["position"] as Vector2).y),
				"hp": int(unit["hp"]),
				"state": String(unit["state"]),
				"direction": String(unit["direction"]),
				"target_id": String(unit.get("target_id", "")),
				"range": float(unit["range"]),
				"attack_reach": sim._attack_reach(unit),
				"alive": bool(unit["alive"]),
			})
		frames.append({"frame": i, "result": sim.result, "units": units})
		if sim.result != "running":
			break
	var file := FileAccess.open(out_path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write movement QC JSON: %s" % out_path)
		quit(1)
		return
	file.store_string(JSON.stringify({"frames": frames}, "\t"))
	print("movement_qc_json\t%s\tframes=%d" % [out_path, frames.size()])
	quit(0)
