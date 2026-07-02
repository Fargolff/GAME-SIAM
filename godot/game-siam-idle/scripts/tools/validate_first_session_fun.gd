extends SceneTree

const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")
const LocalProfileScript := preload("res://scripts/meta/local_profile.gd")
const GameStringsScript := preload("res://scripts/meta/strings.gd")

const GOAL_KEYS := [
	"goal_clear_wave1",
	"goal_upgrade_ready",
	"goal_reach_wave5",
	"goal_reach_wave10",
	"goal_boss_wave10",
	"goal_claim_reward",
]

func _initialize() -> void:
	var failures: Array[String] = []
	_validate_reward_pacing(failures)
	_validate_fresh_upgrade_flow(failures)
	_validate_goal_strings(failures)
	_validate_battle_source(failures)

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("First-session fun validation passed: wave1 upgrade, wave5 shards, goal strings, ULT cadence, next-wave flow")
	quit(0)

func _validate_reward_pacing(failures: Array[String]) -> void:
	var wave1 := BattleSimScript.reward_for_wave(1)
	if int(wave1["gold"]) < BattleSimScript.upgrade_cost(1):
		failures.append("Wave 1 reward should fund the first team upgrade.")

	var wave3 := BattleSimScript.reward_for_wave(3)
	if int(wave3["gold"]) <= 55 + 3 * 18:
		failures.append("Wave 3 should include a first-session gold milestone.")

	var wave5 := BattleSimScript.reward_for_wave(5)
	if int(wave5["shards"]) < 4:
		failures.append("Wave 5 should grant bonus shards.")

	var wave10 := BattleSimScript.reward_for_wave(10)
	if int(wave10["shards"]) < 6:
		failures.append("Wave 10 boss should grant a larger shard bonus.")

func _validate_fresh_upgrade_flow(failures: Array[String]) -> void:
	var profile := LocalProfileScript.default_data(1000)
	LocalProfileScript.clear_wave(profile, 1, 1001)
	if int(profile["gold"]) < BattleSimScript.upgrade_cost(1):
		failures.append("Fresh profile should afford upgrade after clearing wave 1.")
	if not LocalProfileScript.upgrade_team(profile, 1002):
		failures.append("Fresh profile should upgrade successfully after wave 1.")
	if LocalProfileScript.team_level(profile) != 2:
		failures.append("First upgrade should raise team level to 2.")

	var wave5_profile := LocalProfileScript.default_data(2000)
	var reward := {}
	for wave_id in range(1, 6):
		reward = LocalProfileScript.clear_wave(wave5_profile, wave_id, 2000 + wave_id)
	if int(reward["shards"]) < 4 or int(wave5_profile["shards"]) < 4:
		failures.append("Clearing through wave 5 should award the shard milestone.")

func _validate_goal_strings(failures: Array[String]) -> void:
	for key in GOAL_KEYS:
		for language in ["en", "th"]:
			var text := GameStringsScript.text(key, language).strip_edges()
			if text == "" or text == key:
				failures.append("%s goal string is missing for %s." % [key, language])

func _validate_battle_source(failures: Array[String]) -> void:
	var file := FileAccess.open("res://scripts/battle/battle.gd", FileAccess.READ)
	if file == null:
		failures.append("Could not read battle.gd for first-session source scan.")
		return
	var source := file.get_as_text()
	if not source.contains("skill_cooldown_seconds := 2.6"):
		failures.append("Default ULT cooldown should be 2.6 seconds.")
	if not source.contains("GAME_SIAM_SKILL_TEST_COOLDOWN\", 2.6"):
		failures.append("ULT cooldown env fallback should be 2.6 seconds.")
	if not source.contains("skill_cooldown = 0.25"):
		failures.append("Wave start should prime ULT cooldown at 0.25 seconds.")
	if not source.contains("_next_skill_caster_id"):
		failures.append("ULT button should identify the next caster.")
	if source.contains("LocalProfileScript.save_profile(profile, profile_path)\n\t_load_from_profile()"):
		failures.append("Wave clear should not reload profile before the player presses Next Wave.")
	if not source.contains("var next_wave := int(profile.get(\"current_wave\", current_wave + 1))"):
		failures.append("Next Wave should read the profile's post-clear current_wave.")
	if not source.contains("if next_wave <= current_wave:"):
		failures.append("Next Wave should guard stale profile current_wave values.")
	if not source.contains("current_wave = mini(next_wave, BattleSimScript.MAX_WAVE)"):
		failures.append("Next Wave should clamp the next wave to the campaign limit.")
