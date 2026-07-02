extends SceneTree

const AnalyticsClientScript := preload("res://scripts/telemetry/analytics_client.gd")
const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")

const REQUIRED_EVENTS := [
	"tutorial_start",
	"first_battle_start",
	"first_battle_win",
	"first_upgrade",
	"wave_start",
	"wave_clear",
	"wave_fail",
	"offline_claim",
	"gacha_view",
	"gacha_pull",
	"purchase_start",
	"purchase_success",
	"purchase_fail",
]

func _initialize() -> void:
	var failures: Array[String] = []
	_validate_event_contract(failures)
	_validate_csv_export(failures)
	_validate_balance_sim(failures)
	_validate_battle_hooks(failures)

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("Phase 10 validation passed: analytics contract, CSV exporter, balance simulation")
	quit(0)

func _validate_event_contract(failures: Array[String]) -> void:
	for event_name in REQUIRED_EVENTS:
		if not AnalyticsClientScript.REQUIRED_EVENTS.has(event_name):
			failures.append("AnalyticsClient missing required event: %s" % event_name)

func _validate_csv_export(failures: Array[String]) -> void:
	var path := "user://phase10_events.jsonl"
	var csv_path := "user://phase10_events.csv"
	_remove_user_file(path)
	_remove_user_file(csv_path)

	var analytics := AnalyticsClientScript.new()
	analytics.configure(path)
	for event_name in REQUIRED_EVENTS:
		analytics.log_event(event_name, {"phase": 10})

	var events := AnalyticsClientScript.read_events(path)
	if events.size() != REQUIRED_EVENTS.size():
		failures.append("Expected %d analytics events, got %d." % [REQUIRED_EVENTS.size(), events.size()])
	var exported := AnalyticsClientScript.export_csv(path, csv_path)
	if exported != REQUIRED_EVENTS.size():
		failures.append("Expected %d exported events, got %d." % [REQUIRED_EVENTS.size(), exported])
	if not FileAccess.file_exists(csv_path):
		failures.append("Analytics CSV should exist.")

	_remove_user_file(path)
	_remove_user_file(csv_path)

func _validate_balance_sim(failures: Array[String]) -> void:
	var formation := BattleSimScript.default_formation()
	for wave_id in range(1, BattleSimScript.MAX_WAVE + 1):
		var team_level: int = max(1, int(wave_id / 4) + 1)
		var levels := {}
		for hero_id in formation:
			levels[hero_id] = team_level
		var sim := BattleSimScript.new()
		sim.setup_wave(wave_id, formation, levels)
		for i in range(1800):
			sim.tick(0.1)
			if sim.result != "running":
				break
		if sim.result == "running":
			failures.append("Balance sim wave %d did not resolve." % wave_id)
			return

func _validate_battle_hooks(failures: Array[String]) -> void:
	var script := FileAccess.open("res://scripts/battle/battle.gd", FileAccess.READ)
	if script == null:
		failures.append("Could not read battle.gd for analytics hook scan.")
		return
	var source := script.get_as_text()
	for event_name in REQUIRED_EVENTS:
		if not source.contains("\"%s\"" % event_name):
			failures.append("battle.gd does not reference analytics event %s." % event_name)
	if source.contains("\"purchase_success\"") and source.contains("\"local_pending\""):
		failures.append("battle.gd should not log purchase_success for locally pending purchase requests.")

func _remove_user_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
