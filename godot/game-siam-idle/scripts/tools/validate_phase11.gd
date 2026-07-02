extends SceneTree

func _initialize() -> void:
	var failures: Array[String] = []
	_validate_project_android_settings(failures)
	_validate_export_presets(failures)
	_validate_export_outputs(failures)

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("Phase 11 validation passed: Android presets, APK/AAB outputs, mobile compression")
	quit(0)

func _validate_project_android_settings(failures: Array[String]) -> void:
	if not bool(ProjectSettings.get_setting("rendering/textures/vram_compression/import_etc2_astc")):
		failures.append("Android export requires ETC2/ASTC import enabled.")
	if String(ProjectSettings.get_setting("rendering/renderer/rendering_method")) != "mobile":
		failures.append("Android build should use mobile renderer.")

func _validate_export_presets(failures: Array[String]) -> void:
	var file := FileAccess.open("res://export_presets.cfg", FileAccess.READ)
	if file == null:
		failures.append("Missing export_presets.cfg.")
		return
	var source := file.get_as_text()
	var required := [
		"name=\"Android Debug APK\"",
		"name=\"Android Debug AAB\"",
		"package/unique_name=\"com.gamesiam.idle\"",
		"version/code=1",
		"version/name=\"0.1.0\"",
		"architectures/arm64-v8a=true",
		"architectures/x86=false",
		"permissions/internet=true",
		"gradle_build/export_format=0",
		"gradle_build/export_format=1",
		"gradle_build/use_gradle_build=true",
		"exclude_filter=\"exports/*,scripts/tools/*,tools/*,docs/*\"",
	]
	for needle in required:
		if not source.contains(needle):
			failures.append("export_presets.cfg missing %s." % needle)
	if not source.contains("keystore/release=\"\""):
		failures.append("Release keystore should remain empty until real signing is provided.")

func _validate_export_outputs(failures: Array[String]) -> void:
	var apk_path := "res://exports/android/game-siam-idle-debug.apk"
	var aab_path := "res://exports/android/game-siam-idle-debug.aab"
	if _file_size(apk_path) < 10_000_000:
		failures.append("Debug APK is missing or unexpectedly small.")
	if _file_size(aab_path) < 10_000_000:
		failures.append("Debug AAB is missing or unexpectedly small.")
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path("res://android/build")):
		failures.append("Android custom build template should exist for AAB exports.")

func _file_size(path: String) -> int:
	if not FileAccess.file_exists(path):
		return 0
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return 0
	return file.get_length()
