extends SceneTree

const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")
const HeroCatalogScript := preload("res://scripts/content/hero_catalog.gd")

func _initialize() -> void:
	var out_path := OS.get_environment("GAME_SIAM_CHARACTER_QC_JSON").strip_edges()
	if out_path == "":
		out_path = "user://character_baseline_qc.json"
	var hero_id := OS.get_environment("GAME_SIAM_CHARACTER_QC_HERO").strip_edges()
	if hero_id == "":
		hero_id = "A02_TIGER_PLOENGPAYAK"
	var tick_count := int(OS.get_environment("GAME_SIAM_CHARACTER_QC_TICKS"))
	if tick_count <= 0:
		tick_count = 260

	var sim := BattleSimScript.new()
	var base: Dictionary = HeroCatalogScript.base_stats_for(hero_id)
	var hp: int = max(2600, int(base.get("hp", 300)) * 8)
	var attack: int = max(12, int(base.get("attack", 24)))
	var defense: int = max(1, int(base.get("defense", 8)))
	var attack_range: float = float(base.get("range", 56.0))
	var cooldown: float = float(base.get("cooldown", 1.15))
	var move_speed: float = float(base.get("move_speed", 92.0))
	sim.elapsed = 0.0
	sim.result = "running"
	sim.units = [
		sim._unit("p1", "player", hero_id, Vector2(300, 365), Vector2(430, 365), hp, attack, defense, attack_range, cooldown, move_speed),
		sim._unit("e1", "enemy", hero_id, Vector2(990, 365), Vector2(855, 365), hp, attack, defense, attack_range, cooldown, move_speed),
	]

	var frames: Array[Dictionary] = []
	for i in range(tick_count):
		sim.tick(1.0 / 24.0)
		var units: Array[Dictionary] = []
		for unit in sim.units:
			var position: Vector2 = unit["position"]
			var velocity: Vector2 = unit["velocity"]
			units.append({
				"id": String(unit["id"]),
				"team": String(unit["team"]),
				"character_id": String(unit["character_id"]),
				"x": float(position.x),
				"y": float(position.y),
				"vx": float(velocity.x),
				"vy": float(velocity.y),
				"hp": int(unit["hp"]),
				"max_hp": int(unit["max_hp"]),
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
		push_error("Cannot write character baseline QC JSON: %s" % out_path)
		quit(1)
		return
	file.store_string(JSON.stringify({
		"hero_id": hero_id,
		"focus_ids": ["p1", "e1"],
		"ticks": tick_count,
		"frames": frames,
	}, "\t"))
	print("character_baseline_qc_json\t%s\tframes=%d\thero=%s" % [out_path, frames.size(), hero_id])
	quit(0)
