extends SceneTree

const EconomyClientScript := preload("res://scripts/backend/economy_client.gd")

func _initialize() -> void:
	var failures: Array[String] = []
	var client := EconomyClientScript.new()
	client.configure("https://gamesiam.example.supabase.co/", "anon-key", "access-token")

	if not client.is_configured():
		failures.append("EconomyClient should be configured with Supabase URL and anon key.")
	if client.is_live_configured():
		failures.append("Placeholder Supabase config should not count as live backend config.")

	if EconomyClientScript.REQUIRED_FUNCTIONS.size() != 10:
		failures.append("EconomyClient should expose 10 Phase 6 functions.")

	var url := client.function_url("start_battle")
	if url != "https://gamesiam.example.supabase.co/functions/v1/start_battle":
		failures.append("Function URL format mismatch: %s" % url)

	var request: Dictionary = client.start_battle("profile-1", "req-1", 7, ["S01_GARUDA_VAYUDEJ"])
	if int(request["method"]) != HTTPClient.METHOD_POST:
		failures.append("EconomyClient requests should use POST.")
	if not (request["headers"] as PackedStringArray).has("apikey: anon-key"):
		failures.append("EconomyClient should include apikey header.")
	if not (request["headers"] as PackedStringArray).has("Authorization: Bearer access-token"):
		failures.append("EconomyClient should include bearer header.")

	var body = JSON.parse_string(request["body"])
	if typeof(body) != TYPE_DICTIONARY:
		failures.append("EconomyClient body should be JSON dictionary.")
	elif body["profileId"] != "profile-1" or int(body["waveId"]) != 7:
		failures.append("start_battle payload mismatch.")

	for function_name in EconomyClientScript.REQUIRED_FUNCTIONS:
		if client.function_url(function_name) == "":
			failures.append("Missing function URL for %s" % function_name)

	var live_client := EconomyClientScript.new()
	live_client.configure("https://gamesiam.supabase.co", "eyJhbGciOiJIUzI1NiJ9.real-ish-anon-key")
	if not live_client.is_live_configured():
		failures.append("Non-placeholder Supabase config should count as live backend config.")

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("Phase 6 Godot client validation passed: 10 Edge Function requests")
	quit(0)
