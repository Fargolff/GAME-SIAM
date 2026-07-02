extends SceneTree

const GameEnvironmentScript := preload("res://scripts/config/environment.gd")
const GameStringsScript := preload("res://scripts/meta/strings.gd")

const REQUIRED_DOCS := [
	"closed_test_plan.md",
	"soft_launch_plan.md",
	"tester_feedback_form_template.md",
	"staging_config.md",
]

func _initialize() -> void:
	var failures: Array[String] = []
	_validate_environment_config(failures)
	_validate_feedback_path(failures)
	_validate_docs(failures)

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("Phase 13 validation passed: environment config, feedback path, closed-test docs")
	quit(0)

func _validate_environment_config(failures: Array[String]) -> void:
	for environment_name in ["dev", "staging", "prod"]:
		var config := GameEnvironmentScript.config(environment_name)
		for key in ["supabase_url", "supabase_anon_key", "feedback_url"]:
			if not config.has(key) or String(config[key]).strip_edges() == "":
				failures.append("%s environment missing %s." % [environment_name, key])
		if not String(config["feedback_url"]).begins_with("https://forms.gle/"):
			failures.append("%s feedback URL should be a forms.gle placeholder or real URL." % environment_name)
	if GameEnvironmentScript.current_name() != "dev":
		failures.append("Default environment should stay dev until closed test config is real.")

func _validate_feedback_path(failures: Array[String]) -> void:
	var packed := load("res://scenes/battle/Battle.tscn") as PackedScene
	if packed == null:
		failures.append("Battle scene should load.")
		return
	var scene := packed.instantiate()
	if scene.get_node_or_null("SettingsPanel/FeedbackButton") == null:
		failures.append("Battle settings should include FeedbackButton.")
	scene.free()

	for language in ["en", "th"]:
		for key in ["feedback", "feedback_pending"]:
			if GameStringsScript.text(key, language).strip_edges() == "":
				failures.append("Missing %s string for %s." % [language, key])

func _validate_docs(failures: Array[String]) -> void:
	var docs_root := ProjectSettings.globalize_path("res://../../docs/launch")
	for doc_name in REQUIRED_DOCS:
		var path := "%s/%s" % [docs_root, doc_name]
		if not FileAccess.file_exists(path):
			failures.append("Missing Phase 13 doc: %s" % doc_name)
			continue
		var text := _read_text(path)
		if text.length() < 200:
			failures.append("Phase 13 doc is unexpectedly short: %s" % doc_name)

	var closed := _read_text("%s/closed_test_plan.md" % docs_root)
	for required in ["20-50 testers", "purchase", "D1 retention", "feedback form"]:
		if not closed.contains(required):
			failures.append("Closed test plan missing %s." % required)

	var soft := _read_text("%s/soft_launch_plan.md" % docs_root)
	for required in ["Thailand", "Stop Conditions", "paid user acquisition"]:
		if not soft.contains(required):
			failures.append("Soft launch plan missing %s." % required)

func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()
