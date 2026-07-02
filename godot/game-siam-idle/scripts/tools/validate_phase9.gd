extends SceneTree

const GameStringsScript := preload("res://scripts/meta/strings.gd")

const REQUIRED_STRING_KEYS := [
	"ready",
	"ready_status",
	"running",
	"players",
	"enemies",
	"defeat",
	"offline",
	"clear",
	"reward_line",
	"gacha",
	"settings",
	"retry",
	"restart",
	"start",
	"upgrade",
	"next",
	"pull_one",
	"pull_ten",
	"buy_premium",
	"english",
	"thai",
	"sound_on",
	"sound_off",
	"restore",
	"restore_pending",
	"notifications_later",
	"odds",
	"hint_start",
	"hint_loss",
	"hint_win",
]

func _initialize() -> void:
	var failures: Array[String] = []
	_validate_project_settings(failures)
	_validate_scene_layout(failures)
	_validate_strings(failures)

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("Phase 9 validation passed: landscape HUD, hidden drawers, touch controls, bilingual strings")
	quit(0)

func _validate_project_settings(failures: Array[String]) -> void:
	if int(ProjectSettings.get_setting("display/window/size/viewport_width")) != 1280:
		failures.append("Viewport width should stay 1280 for landscape baseline.")
	if int(ProjectSettings.get_setting("display/window/size/viewport_height")) != 720:
		failures.append("Viewport height should stay 720 for landscape baseline.")
	if int(ProjectSettings.get_setting("display/window/handheld/orientation")) != 0:
		failures.append("Handheld orientation should be landscape.")
	if String(ProjectSettings.get_setting("display/window/stretch/mode")) != "canvas_items":
		failures.append("Stretch mode should use canvas_items for mobile UI.")

func _validate_scene_layout(failures: Array[String]) -> void:
	var packed := load("res://scenes/battle/Battle.tscn") as PackedScene
	if packed == null:
		failures.append("Battle.tscn should load.")
		return
	var scene := packed.instantiate()

	var gacha_panel := scene.get_node_or_null("GachaPanel") as Control
	var settings_panel := scene.get_node_or_null("SettingsPanel") as Control
	if gacha_panel == null or settings_panel == null:
		failures.append("Battle scene should contain gacha and settings drawers.")
		return
	if gacha_panel.visible or settings_panel.visible:
		failures.append("Gacha and settings drawers should be hidden by default.")

	for path in ["GachaButton", "SettingsButton", "SpeedButton", "StartButton", "UpgradeButton", "NextWaveButton"]:
		var button := scene.get_node_or_null(path) as Button
		if button == null:
			failures.append("Missing button: %s" % path)
			continue
		if button.size.y < 44.0:
			failures.append("%s should be at least 44 px tall for touch." % path)

	for i in range(1, 6):
		var slot := scene.get_node_or_null("FormationBar/Slot%d" % i) as Button
		if slot == null:
			failures.append("Missing formation slot %d." % i)
			continue
		if slot.custom_minimum_size.y < 64.0:
			failures.append("Formation slot %d should be at least 64 px tall." % i)
	if not ResourceLoader.exists("res://assets/ui/generated/hp_bar_frame_imagegen_v37.png"):
		failures.append("Imagegen HP bar frame asset should exist.")
	var unit_scene := load("res://scenes/battle/Unit.tscn") as PackedScene
	if unit_scene == null:
		failures.append("Unit scene should load.")
	else:
		var unit := unit_scene.instantiate()
		var unit_debug := unit.get_node_or_null("DebugLabel") as Label
		var hp_bar := unit.get_node_or_null("HpBar") as ProgressBar
		if unit_debug == null or unit_debug.visible:
			failures.append("Unit debug labels should be hidden in playtest HUD.")
		if hp_bar == null or hp_bar.position.y >= 0.0:
			failures.append("Unit HP bar should sit above the sprite.")
		var hp_visual_size := hp_bar.size * hp_bar.scale
		if hp_visual_size.x < 64.0 or hp_visual_size.y < 7.0:
			failures.append("Unit HP bar should stay readable, got %.1fx%.1f." % [hp_visual_size.x, hp_visual_size.y])
		elif hp_visual_size.x > 72.0 or hp_visual_size.y > 11.0:
			failures.append("Unit HP bar should not dominate the 64px sprite, got %.1fx%.1f." % [hp_visual_size.x, hp_visual_size.y])
		unit.free()

	for child in scene.get_children():
		var control := child as Control
		if control == null or not control.visible:
			continue
		if child.name in ["Background", "TargetMarker"]:
			continue
		var top := control.position.y
		var bottom := control.position.y + control.size.y
		var left := control.position.x
		var right := control.position.x + control.size.x
		if top > 170.0 and bottom < 580.0 and left > 220.0 and right < 1060.0:
			failures.append("Visible HUD node %s sits inside protected battle center." % child.name)

	scene.free()

func _validate_strings(failures: Array[String]) -> void:
	for language in ["en", "th"]:
		for key in REQUIRED_STRING_KEYS:
			if GameStringsScript.text(key, language).strip_edges() == "":
				failures.append("Missing %s string for %s." % [language, key])
	if GameStringsScript.text("running", "en") == GameStringsScript.text("running", "th"):
		failures.append("Thai and English running strings should differ.")
