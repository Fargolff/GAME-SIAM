extends SceneTree

const HeroCatalogScript := preload("res://scripts/content/hero_catalog.gd")

const ACTIONS := [
	"idle",
	"walk",
	"attack_01",
	"skill_01",
	"hurt",
	"death",
]

const LOOPING_ACTIONS := {
	"idle": true,
	"walk": true,
}

const ASSET_ROOT := "res://assets/characters/GameSiam"
const OUT_ROOT := "res://generated/spriteframes"

func _initialize() -> void:
	var failures: Array[String] = []
	var hero_ids := HeroCatalogScript.all_heroes()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_ROOT))
	for hero_id in hero_ids:
		var error := _build_hero(hero_id)
		if error != "":
			failures.append(error)

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("Generated SpriteFrames for %d GAME SIAM heroes." % hero_ids.size())
	quit(0)

func _build_hero(hero_id: String) -> String:
	var frames := SpriteFrames.new()
	for action in ACTIONS:
		var sheet_path := "%s/%s/%s-sheet-clean.png" % [ASSET_ROOT, hero_id, action]
		var metadata_path := "%s/%s/%s-metadata.json" % [ASSET_ROOT, hero_id, action]
		if not FileAccess.file_exists(sheet_path):
			return "Missing sheet: %s" % sheet_path
		if not FileAccess.file_exists(metadata_path):
			return "Missing metadata: %s" % metadata_path

		var texture := load(sheet_path) as Texture2D
		if texture == null:
			return "Unable to load texture: %s" % sheet_path

		var metadata := _read_json(metadata_path)
		if metadata.is_empty():
			return "Invalid metadata: %s" % metadata_path

		var cell := int(metadata.get("cell", 64))
		var rows_meta: Array = metadata.get("rows_meta", [])
		for row_meta in rows_meta:
			var direction := String(row_meta.get("direction", "south"))
			var row := int(row_meta.get("row", 0))
			var frame_count := int(row_meta.get("frames", metadata.get("columns", 6)))
			var animation := "%s_%s" % [action, direction]
			frames.add_animation(animation)
			frames.set_animation_loop(animation, LOOPING_ACTIONS.has(action))
			frames.set_animation_speed(animation, _animation_speed(action))
			for column in frame_count:
				var atlas := AtlasTexture.new()
				atlas.atlas = texture
				atlas.region = Rect2(column * cell, row * cell, cell, cell)
				frames.add_frame(animation, atlas)

	var out_path := "%s/%s.tres" % [OUT_ROOT, hero_id]
	var save_error := ResourceSaver.save(frames, out_path)
	if save_error != OK:
		return "Failed saving %s: %s" % [out_path, save_error]
	return ""

func _animation_speed(action: String) -> float:
	match action:
		"idle":
			return 6.0
		"walk":
			return 9.5
		"attack_01", "skill_01":
			return 12.5
		"hurt":
			return 13.0
		"death":
			return 9.0
	return 10.0

func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
