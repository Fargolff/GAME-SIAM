extends Node2D

const UnitScene := preload("res://scenes/battle/Unit.tscn")
const HeroCatalogScript := preload("res://scripts/content/hero_catalog.gd")

const PAGE_SIZE := 2
const PAGE_FRAMES := 300
const ROW_START_Y := 220.0
const ROW_GAP := 250.0

var heroes := _configured_heroes()
var page := 0
var page_frames := 0
var walkers: Array[Dictionary] = []

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.018, 0.028, 0.032, 1.0))
	_show_page(0)

func _process(_delta: float) -> void:
	page_frames += 1
	for walker in walkers:
		var unit: Node2D = walker["unit"]
		if not bool(unit.get("has_target")):
			var points: Array = walker["points"]
			walker["index"] = (int(walker["index"]) + 1) % points.size()
			unit.set_target(points[int(walker["index"])])
	if page_frames >= PAGE_FRAMES:
		page += 1
		var max_pages := int(OS.get_environment("GAME_SIAM_WALK_QC_MAX_PAGES"))
		if max_pages > 0 and page >= max_pages:
			get_tree().quit()
			return
		if page * PAGE_SIZE >= heroes.size():
			get_tree().quit()
			return
		_show_page(page)

func _show_page(next_page: int) -> void:
	page_frames = 0
	for child in get_children():
		child.queue_free()
	walkers.clear()
	_draw_guides()
	_add_label(Vector2(24, 16), "Walk QC %d/%d - actual Godot playback" % [next_page + 1, int(ceil(float(heroes.size()) / PAGE_SIZE))], 22, Color(1.0, 0.78, 0.35, 1.0))
	for i in range(PAGE_SIZE):
		var hero_index := next_page * PAGE_SIZE + i
		if hero_index >= heroes.size():
			break
		var y := ROW_START_Y + float(i) * ROW_GAP
		var left := Vector2(190, y)
		var right := Vector2(1090, y)
		var points := [
			right,
			Vector2(1120, y + 42),
			Vector2(1080, y + 84),
			left,
			Vector2(145, y - 42),
			Vector2(190, y - 84),
		]
		var unit := UnitScene.instantiate()
		unit.character_id = String(heroes[hero_index])
		unit.global_position = left
		unit.scale = Vector2(1.28, 1.28)
		var configured_speed := float(OS.get_environment("GAME_SIAM_WALK_QC_MOVE_SPEED"))
		unit.move_speed = configured_speed if configured_speed > 0.0 else 92.0
		add_child(unit)
		unit.get_node("HpBar").visible = false
		unit.get_node("DebugLabel").visible = false
		unit.set_target(points[0])
		walkers.append({"unit": unit, "points": points, "index": 0})
		_add_label(Vector2(24, y - 46), String(heroes[hero_index]), 20, Color(0.92, 0.88, 0.72, 1.0))

func _draw_guides() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.018, 0.028, 0.032, 1.0)
	bg.size = Vector2(1280, 720)
	add_child(bg)
	for i in range(PAGE_SIZE):
		var y := ROW_START_Y + float(i) * ROW_GAP
		var line := Line2D.new()
		line.width = 1.0
		line.default_color = Color(1.0, 0.72, 0.25, 0.18)
		line.points = PackedVector2Array([Vector2(150, y + 32), Vector2(1130, y + 32)])
		add_child(line)

func _add_label(position: Vector2, text: String, size: int, color: Color) -> void:
	var label := Label.new()
	label.position = position
	label.size = Vector2(360, 28)
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 3)
	add_child(label)

static func _configured_heroes() -> Array:
	var requested := OS.get_environment("GAME_SIAM_WALK_QC_HEROES").strip_edges()
	if requested == "":
		return HeroCatalogScript.all_heroes()
	var selected := []
	for part in requested.split(","):
		var hero_id := String(part).strip_edges()
		if hero_id != "":
			selected.append(hero_id)
	return selected
