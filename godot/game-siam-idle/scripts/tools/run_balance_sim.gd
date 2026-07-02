extends SceneTree

const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")

func _initialize() -> void:
	var output_path := "user://balance_sim.csv"
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write balance simulation CSV.")
		quit(1)
		return

	file.store_line("wave,result,duration_seconds,player_alive,enemy_alive,team_level")
	var formation := BattleSimScript.default_formation()
	for wave_id in range(1, BattleSimScript.MAX_WAVE + 1):
		var team_level: int = max(1, int(wave_id / 4) + 1)
		var levels := {}
		for hero_id in formation:
			levels[hero_id] = team_level
		var sim := BattleSimScript.new()
		sim.setup_wave(wave_id, formation, levels)
		var ticks := 0
		for i in range(1800):
			ticks = i + 1
			sim.tick(0.1)
			if sim.result != "running":
				break
		var alive := _alive_counts(sim.units)
		file.store_line("%d,%s,%.1f,%d,%d,%d" % [
			wave_id,
			sim.result,
			ticks * 0.1,
			alive["players"],
			alive["enemies"],
			team_level,
		])

	print("Wrote balance simulation to %s" % output_path)
	quit(0)

func _alive_counts(units: Array[Dictionary]) -> Dictionary:
	var players := 0
	var enemies := 0
	for unit in units:
		if not bool(unit["alive"]):
			continue
		if unit["team"] == "player":
			players += 1
		elif unit["team"] == "enemy":
			enemies += 1
	return {"players": players, "enemies": enemies}
