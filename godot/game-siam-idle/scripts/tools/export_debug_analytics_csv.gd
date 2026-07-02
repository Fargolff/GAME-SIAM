extends SceneTree

const AnalyticsClientScript := preload("res://scripts/telemetry/analytics_client.gd")

func _initialize() -> void:
	var count := AnalyticsClientScript.export_csv(
		AnalyticsClientScript.DEFAULT_EVENT_PATH,
		"user://analytics_events.csv"
	)
	print("Exported %d analytics events to user://analytics_events.csv" % count)
	quit(0)
