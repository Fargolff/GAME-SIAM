class_name AnalyticsClient
extends RefCounted

const DEFAULT_EVENT_PATH := "user://analytics_events.jsonl"
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

var event_path := DEFAULT_EVENT_PATH
var session_id := ""
var enabled := true

func configure(next_event_path := DEFAULT_EVENT_PATH) -> void:
	event_path = next_event_path
	session_id = "session_%d" % Time.get_unix_time_from_system()

func log_event(event_name: String, params: Dictionary = {}) -> void:
	if not enabled:
		return
	if not REQUIRED_EVENTS.has(event_name):
		push_warning("Unknown analytics event: %s" % event_name)
	var event := {
		"event": event_name,
		"ts": int(Time.get_unix_time_from_system()),
		"sessionId": session_id,
		"params": params,
	}
	_append_json_line(event_path, event)

static func read_events(path: String = DEFAULT_EVENT_PATH) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	if not FileAccess.file_exists(path):
		return events
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return events
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line == "":
			continue
		var parsed = JSON.parse_string(line)
		if typeof(parsed) == TYPE_DICTIONARY:
			events.append(parsed as Dictionary)
	return events

static func export_csv(source_path: String = DEFAULT_EVENT_PATH, output_path: String = "user://analytics_events.csv") -> int:
	var events := read_events(source_path)
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write analytics CSV: %s" % output_path)
		return 0
	file.store_line("ts,session_id,event,params_json")
	for event in events:
		file.store_line(",".join([
			_csv_value(str(event.get("ts", 0))),
			_csv_value(String(event.get("sessionId", ""))),
			_csv_value(String(event.get("event", ""))),
			_csv_value(JSON.stringify(event.get("params", {}))),
		]))
	return events.size()

static func _append_json_line(path: String, event: Dictionary) -> void:
	var mode := FileAccess.READ_WRITE if FileAccess.file_exists(path) else FileAccess.WRITE
	var file := FileAccess.open(path, mode)
	if file == null:
		push_error("Cannot write analytics event: %s" % path)
		return
	if mode == FileAccess.READ_WRITE:
		file.seek_end()
	file.store_line(JSON.stringify(event))

static func _csv_value(value: String) -> String:
	return "\"%s\"" % value.replace("\"", "\"\"")
