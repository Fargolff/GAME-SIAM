extends SceneTree

const GameStringsScript := preload("res://scripts/meta/strings.gd")

const DOCS := [
	"privacy_policy_draft.md",
	"google_play_data_safety_inputs.md",
	"store_listing_en.md",
	"store_listing_th.md",
	"gameplay_trailer_script_30s.md",
	"release_checklist.md",
	"compliance_sources.md",
]

func _initialize() -> void:
	var failures: Array[String] = []
	_validate_docs(failures)
	_validate_in_game_compliance_paths(failures)
	_validate_strings(failures)

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("Phase 12 validation passed: launch docs, odds, support, account deletion path")
	quit(0)

func _validate_docs(failures: Array[String]) -> void:
	var docs_root := ProjectSettings.globalize_path("res://../../docs/launch")
	for doc_name in DOCS:
		var path := "%s/%s" % [docs_root, doc_name]
		if not FileAccess.file_exists(path):
			failures.append("Missing launch doc: %s" % doc_name)
			continue
		var text := _read_text(path)
		if text.length() < 200:
			failures.append("Launch doc is unexpectedly short: %s" % doc_name)

	var privacy := _read_doc("privacy_policy_draft.md")
	for required in ["[OWNER LEGAL NAME]", "[SUPPORT EMAIL]", "Account Deletion", "Randomized Purchases"]:
		if not privacy.contains(required):
			failures.append("Privacy draft missing %s." % required)

	var data_safety := _read_doc("google_play_data_safety_inputs.md")
	for required in ["Supabase", "Firebase", "Purchase history", "Deletion"]:
		if not data_safety.contains(required):
			failures.append("Data safety draft missing %s." % required)

	var checklist := _read_doc("release_checklist.md")
	for required in ["Privacy policy URL live", "Paid gacha disabled", "Release keystore"]:
		if not checklist.contains(required):
			failures.append("Release checklist missing %s." % required)

	var sources := _read_doc("compliance_sources.md")
	for url in [
		"https://support.google.com/googleplay/android-developer/answer/10787469",
		"https://support.google.com/googleplay/android-developer/answer/10144311",
		"https://support.google.com/googleplay/android-developer/answer/9858738",
		"https://docs.godotengine.org/en/latest/tutorials/export/exporting_for_android.html",
	]:
		if not sources.contains(url):
			failures.append("Compliance sources missing %s." % url)

func _validate_in_game_compliance_paths(failures: Array[String]) -> void:
	var packed := load("res://scenes/battle/Battle.tscn") as PackedScene
	if packed == null:
		failures.append("Battle scene should load.")
		return
	var scene := packed.instantiate()
	for node_path in [
		"GachaPanel/OddsLabel",
		"SettingsPanel/SupportButton",
		"SettingsPanel/DeleteAccountButton",
	]:
		if scene.get_node_or_null(node_path) == null:
			failures.append("Battle scene missing %s." % node_path)
	scene.free()

func _validate_strings(failures: Array[String]) -> void:
	for language in ["en", "th"]:
		for key in ["odds", "support", "support_pending", "delete_account", "account_deletion_pending"]:
			if GameStringsScript.text(key, language).strip_edges() == "":
				failures.append("Missing %s string for %s." % [language, key])

func _read_doc(doc_name: String) -> String:
	var docs_root := ProjectSettings.globalize_path("res://../../docs/launch")
	return _read_text("%s/%s" % [docs_root, doc_name])

func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()
