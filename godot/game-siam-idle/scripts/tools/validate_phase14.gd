extends SceneTree

const DOCS := [
	"production_launch_runbook.md",
	"monitoring_checklist.md",
	"rollback_playbook.md",
	"release_notes_template.md",
	"migration_snapshot_guide.md",
]

func _initialize() -> void:
	var failures: Array[String] = []
	_validate_launch_docs(failures)
	_validate_release_smoke(failures)
	_validate_android_outputs(failures)

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("Phase 14 validation passed: production launch docs, rollback, smoke script")
	quit(0)

func _validate_launch_docs(failures: Array[String]) -> void:
	var docs_root := ProjectSettings.globalize_path("res://../../docs/launch")
	for doc_name in DOCS:
		var path := "%s/%s" % [docs_root, doc_name]
		if not FileAccess.file_exists(path):
			failures.append("Missing Phase 14 doc: %s" % doc_name)
			continue
		var text := _read_text(path)
		if text.length() < 200:
			failures.append("Phase 14 doc is unexpectedly short: %s" % doc_name)

	var runbook := _read_text("%s/production_launch_runbook.md" % docs_root)
	for required in ["Supabase prod health", "purchase validation", "final AAB", "Crash-free sessions"]:
		if not runbook.contains(required):
			failures.append("Production launch runbook missing %s." % required)

	var rollback := _read_text("%s/rollback_playbook.md" % docs_root)
	for required in ["Pause rollout", "Disable paid gacha", "purchase receipts"]:
		if not rollback.contains(required):
			failures.append("Rollback playbook missing %s." % required)

	var monitoring := _read_text("%s/monitoring_checklist.md" % docs_root)
	for required in ["Crashlytics", "Supabase", "Google Play", "purchase_success"]:
		if not monitoring.contains(required):
			failures.append("Monitoring checklist missing %s." % required)

func _validate_release_smoke(failures: Array[String]) -> void:
	var path := ProjectSettings.globalize_path("res://tools/release_smoke.ps1")
	if not FileAccess.file_exists(path):
		failures.append("Missing release_smoke.ps1.")
		return
	var text := _read_text(path)
	for required in ["validate_phase$phase.gd", "export_android_debug.ps1", "check_toolchain.ps1"]:
		if not text.contains(required):
			failures.append("release_smoke.ps1 missing %s." % required)

func _validate_android_outputs(failures: Array[String]) -> void:
	if _file_size("res://exports/android/game-siam-idle-debug.apk") < 10_000_000:
		failures.append("Debug APK should exist before launch smoke.")
	if _file_size("res://exports/android/game-siam-idle-debug.aab") < 10_000_000:
		failures.append("Debug AAB should exist before launch smoke.")

func _file_size(path: String) -> int:
	if not FileAccess.file_exists(path):
		return 0
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return 0
	return file.get_length()

func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()
