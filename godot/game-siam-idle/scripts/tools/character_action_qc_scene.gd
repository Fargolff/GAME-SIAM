extends Node2D

const UnitScene := preload("res://scenes/battle/Unit.tscn")

const ACTIONS := ["idle", "walk", "attack_01", "skill_01", "hurt", "death"]
const DIRECTIONS := ["south", "south-east", "east", "north-east", "north", "north-west", "west", "south-west"]
const DEFAULT_HERO_ID := "S02_NAGA_SASINAKA"

var capture_frame_dir := ""
var capture_frame_index := 0
var hero_id := DEFAULT_HERO_ID

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.018, 0.028, 0.032, 1.0))
	hero_id = _configured_hero()
	capture_frame_dir = OS.get_environment("GAME_SIAM_ACTION_QC_FRAME_DIR")
	if capture_frame_dir.strip_edges() != "":
		DirAccess.make_dir_recursive_absolute(capture_frame_dir)
	_draw_background()
	_spawn_action_grid()
	call_deferred("_capture_sequence")

func _draw_background() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.018, 0.028, 0.032, 1.0)
	bg.size = Vector2(1280, 720)
	add_child(bg)
	_add_label(Vector2(24, 18), "%s action QC - actual Godot UnitScene playback" % hero_id, 23, Color(1.0, 0.80, 0.36, 1.0))
	for row in range(ACTIONS.size()):
		var y := 112.0 + float(row) * 96.0
		var line := Line2D.new()
		line.width = 1.0
		line.default_color = Color(1.0, 0.72, 0.25, 0.18)
		line.points = PackedVector2Array([Vector2(142, y + 32), Vector2(1228, y + 32)])
		add_child(line)
		_add_label(Vector2(24, y - 22), ACTIONS[row], 18, Color(0.92, 0.88, 0.72, 1.0))
	for col in range(DIRECTIONS.size()):
		_add_label(Vector2(108.0 + float(col) * 145.0, 54), String(DIRECTIONS[col]), 12, Color(0.72, 0.92, 1.0, 1.0))

func _spawn_action_grid() -> void:
	for row in range(ACTIONS.size()):
		for col in range(DIRECTIONS.size()):
			var action := String(ACTIONS[row])
			var direction := String(DIRECTIONS[col])
			var unit := UnitScene.instantiate()
			unit.character_id = hero_id
			unit.global_position = Vector2(130.0 + float(col) * 145.0, 112.0 + float(row) * 96.0)
			unit.scale = Vector2(0.82, 0.82)
			add_child(unit)
			unit.get_node("HpBar").visible = false
			unit.get_node("DebugLabel").visible = false
			unit.play(action, direction)

func _capture_sequence() -> void:
	var frames := int(OS.get_environment("GAME_SIAM_ACTION_QC_FRAMES"))
	if frames <= 0:
		frames = 18
	var interval := float(OS.get_environment("GAME_SIAM_ACTION_QC_INTERVAL"))
	if interval <= 0.0:
		interval = 1.0 / 12.0
	for _i in range(frames):
		await get_tree().process_frame
		if capture_frame_dir.strip_edges() != "":
			var image := get_viewport().get_texture().get_image()
			if image != null and not image.is_empty():
				image.save_png("%s/frame_%05d.png" % [capture_frame_dir, capture_frame_index])
				capture_frame_index += 1
		await get_tree().create_timer(interval).timeout
	if OS.get_environment("GAME_SIAM_ACTION_QC_QUIT") == "1":
		get_tree().quit()

static func _configured_hero() -> String:
	var requested := OS.get_environment("GAME_SIAM_ACTION_QC_HERO").strip_edges()
	return requested if requested != "" else DEFAULT_HERO_ID

func _add_label(position: Vector2, text: String, size: int, color: Color) -> void:
	var label := Label.new()
	label.position = position
	label.size = Vector2(430, 26)
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 3)
	add_child(label)
