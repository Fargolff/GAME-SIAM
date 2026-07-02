extends SceneTree

const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")

func _initialize() -> void:
	var failures: Array[String] = []
	var formation := BattleSimScript.default_formation()
	var levels := {}
	for hero_id in formation:
		levels[hero_id] = 1

	var wave1 := _run_wave(1, formation, levels)
	if wave1["players"] != 5:
		failures.append("Wave 1 should spawn 5 player units.")
	if wave1["result"] != "players":
		failures.append("Wave 1 should be easy, got %s." % wave1["result"])

	var wave20_level1 := _run_wave(20, formation, levels)
	if wave20_level1["result"] != "enemies":
		failures.append("Wave 20 should block unupgraded team, got %s." % wave20_level1["result"])

	for hero_id in formation:
		levels[hero_id] = 8
	var wave20_upgraded := _run_wave(20, formation, levels)
	if wave20_upgraded["result"] != "players":
		failures.append("Wave 20 should clear after upgrades, got %s." % wave20_upgraded["result"])

	var reward := BattleSimScript.reward_for_wave(20)
	if int(reward["gold"]) <= 0 or int(reward["essence"]) <= 0 or int(reward["shards"]) <= 0:
		failures.append("Wave 20 reward should grant gold, essence, and shards.")

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("Phase 4 validation passed: wave1=%s wave20_l1=%s wave20_l8=%s" % [wave1["result"], wave20_level1["result"], wave20_upgraded["result"]])
	quit(0)

func _run_wave(wave_id: int, formation: Array, levels: Dictionary) -> Dictionary:
	var sim := BattleSimScript.new()
	sim.setup_wave(wave_id, formation, levels)
	for i in range(1600):
		sim.tick(0.1)
		if sim.result != "running":
			break

	var players := 0
	for unit in sim.units:
		if unit["team"] == "player":
			players += 1
	return {
		"result": sim.result,
		"players": players,
	}
