extends SceneTree

const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")
const LocalProfileScript := preload("res://scripts/meta/local_profile.gd")
const GameStringsScript := preload("res://scripts/meta/strings.gd")

func _initialize() -> void:
	var failures: Array[String] = []
	var profile: Dictionary = LocalProfileScript.default_data(1000)

	profile["highest_cleared"] = 5
	profile["last_seen"] = 1000
	var offline: Dictionary = LocalProfileScript.claim_offline_reward(profile, 1000 + 10 * 60 * 60)
	if int(offline["seconds"]) != LocalProfileScript.OFFLINE_CAP_SECONDS:
		failures.append("Offline reward should cap at 8 hours.")
	if int(offline["gold"]) <= 0:
		failures.append("Offline reward should grant gold from highest cleared wave.")

	var reward1: Dictionary = LocalProfileScript.clear_wave(profile, 6, 2000)
	var reward2: Dictionary = LocalProfileScript.clear_wave(profile, 6, 2001)
	if int(reward1["gold"]) <= 0 or int(reward2["gold"]) != 0:
		failures.append("Wave clear reward should grant once per new highest wave.")

	var save_path := "user://phase5_profile_test.json"
	LocalProfileScript.save_profile(profile, save_path)
	var loaded: Dictionary = LocalProfileScript.load_profile(save_path, 3000)
	if int(loaded["highest_cleared"]) != int(profile["highest_cleared"]):
		failures.append("Saved profile should load highest cleared wave.")
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))

	var low_levels: Dictionary = LocalProfileScript.hero_levels(profile)
	var wave20_low: Dictionary = _run_wave(20, profile["formation"] as Array, low_levels)
	profile["gold"] = 10000
	for i in range(7):
		LocalProfileScript.upgrade_team(profile, 4000 + i)
	var high_levels: Dictionary = LocalProfileScript.hero_levels(profile)
	var wave20_high: Dictionary = _run_wave(20, profile["formation"] as Array, high_levels)
	if wave20_low["result"] != "enemies" or wave20_high["result"] != "players":
		failures.append("Upgrades should change wave 20 battle result.")

	if GameStringsScript.text("running", "th") == GameStringsScript.text("running", "en"):
		failures.append("Thai and English strings should differ.")

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("Phase 5 validation passed: save/offline/upgrade/localization")
	quit(0)

func _run_wave(wave_id: int, formation: Array, levels: Dictionary) -> Dictionary:
	var sim := BattleSimScript.new()
	sim.setup_wave(wave_id, formation, levels)
	for i in range(1600):
		sim.tick(0.1)
		if sim.result != "running":
			break
	return {"result": sim.result}
