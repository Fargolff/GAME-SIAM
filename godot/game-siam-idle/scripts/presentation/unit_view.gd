extends Node2D

const DirectionResolverScript := preload("res://scripts/presentation/direction_resolver.gd")
const WALK_DIRECTIONS := ["south", "south-east", "east", "north-east", "north", "north-west", "west", "south-west"]
const WALK_ANCHOR_STRENGTH := 0.78
const WALK_SPEED_REFERENCE := 132.0
const WALK_SPEED_SCALE_MIN := 0.62
const WALK_SPEED_SCALE_MAX := 0.94
const WALK_BOB_RATE_MIN := 3.1
const WALK_BOB_RATE_MAX := 4.9
const CHARACTER_WALK_SPEED_SCALE_MIN := {
	"S01_GARUDA_VAYUDEJ": 0.56,
	"B06_BEAST_SINGKHON": 0.78,
	"C01_HUMAN_JETSIAM": 0.44,
	"C02_KHACHASIH_LOHDIN": 0.56,
	"D05_VANARA_JUKJIK": 0.56,
}
const CHARACTER_WALK_SPEED_SCALE_MULTIPLIER := {
	"S01_GARUDA_VAYUDEJ": 0.90,
	"C01_HUMAN_JETSIAM": 0.72,
	"C02_KHACHASIH_LOHDIN": 0.94,
	"D05_VANARA_JUKJIK": 0.90,
}
const CHARACTER_WALK_BOB_PIXELS := {
	"S01_GARUDA_VAYUDEJ": 1.18,
	"C01_HUMAN_JETSIAM": 1.55,
	"C02_KHACHASIH_LOHDIN": 0.95,
	"D05_VANARA_JUKJIK": 1.05,
}
const CHARACTER_WALK_SWAY_PIXELS := {
	"S01_GARUDA_VAYUDEJ": 0.85,
	"C01_HUMAN_JETSIAM": 0.25,
	"C02_KHACHASIH_LOHDIN": 0.55,
	"D05_VANARA_JUKJIK": 0.70,
}
const SIDE_LOCKED_WALK_IDS := {
	"C01_HUMAN_JETSIAM": true,
}
const SIDE_LOCKED_ATTACK_IDS := {
	"S01_GARUDA_VAYUDEJ": true,
	"S02_NAGA_SASINAKA": true,
	"S03_YAKSHA_KRAIASURA": true,
	"A01_KINNARI_PIMPPRUEKSA": true,
	"A02_TIGER_PLOENGPAYAK": true,
	"A03_HUMAN_ARUNRAT": true,
	"A04_VANARA_KALAVANARA": true,
	"A05_MAKARA_MAKORNKRAM": true,
	"A06_SPIRIT_RAMPAN_MASK": true,
	"A07_HUMAN_CHANGJAKKAEW": true,
	"B01_GARUDA_MEKHAVI": true,
	"B03_YAKSHA_KHUNPHA": true,
	"B04_HUMAN_DARIN": true,
	"B06_BEAST_SINGKHON": true,
	"C01_HUMAN_JETSIAM": true,
	"C02_KHACHASIH_LOHDIN": true,
	"C05_VANARA_JORJAN": true,
	"C07_GARUDA_PEEKTHONG": true,
	"C08_CROCODILE_KUMPHIL": true,
	"D01_HUMAN_PHAIKLA": true,
	"D02_HUMAN_KHAMPAN": true,
	"D04_HUMAN_TAEMTHONG": true,
	"D05_VANARA_JUKJIK": true,
	"D07_GARUDA_LOMPEEK": true,
	"D08_HUMAN_THIWA": true,
	"D09_CONSTRUCT_SILADIN": true,
	"D10_SPIRIT_OUNRUEN": true,
}
const SLITHER_WALK_IDS := {
	"S02_NAGA_SASINAKA": true,
	"B02_NAGA_KLEDKRAM": true,
	"C06_NAGA_NILNATEE": true,
	"D06_NAGA_BUABUCHA": true,
}
const COMBAT_FRAME_SEQUENCE_OVERRIDES := {
	"D09_CONSTRUCT_SILADIN": {
		"attack_01": {
			"east": [1, 2, 3, 3, 2, 1],
			"west": [1, 2, 3, 3, 2, 1],
		},
		"skill_01": {
			"east": [1, 2, 3, 3, 2, 1],
			"west": [1, 2, 3, 3, 2, 1],
		},
	},
	"D02_HUMAN_KHAMPAN": {
		"attack_01": {
			"east": [0, 2, 2, 4, 5, 0],
			"west": [0, 2, 2, 4, 5, 0],
		},
		"skill_01": {
			"east": [0, 2, 2, 4, 5, 0],
			"west": [0, 2, 2, 4, 5, 0],
		},
	},
	"D04_HUMAN_TAEMTHONG": {
		"attack_01": {
			"east": [0, 2, 3, 4, 5, 0],
			"west": [0, 2, 3, 4, 5, 0],
		},
		"skill_01": {
			"east": [0, 2, 3, 4, 5, 0],
			"west": [0, 2, 3, 4, 5, 0],
		},
	},
}
const VICTORY_MOTION_SECONDS := 1.18
const HP_BAR_FRAME_IMAGEGEN := "res://assets/ui/generated/hp_bar_frame_imagegen_v37.png"
const HP_DEFAULT_ALPHA := 0.70
const HIT_REACTION_SECONDS := 0.16
const SKILL_HIT_REACTION_SECONDS := 0.28

@export var character_id := "S01_GARUDA_VAYUDEJ"
@export var action := "idle"
@export var direction := "south"
@export var move_speed := 112.0
@export var arrive_distance := 4.0
@export var follow_speed := 16.0
@export var snap_distance := 92.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var debug_label: Label = $DebugLabel
@onready var hp_bar: ProgressBar = $HpBar

var target_position := Vector2.ZERO
var has_target := false
var sim_target_position := Vector2.ZERO
var has_sim_target := false
var base_tint := Color.WHITE
var shadow: Polygon2D
var hp_frame: Sprite2D
var walk_phase := 0.0
var base_sprite_scale := Vector2.ONE
var team := "player"
var walk_anchor_offsets := {}
var victory_motion_time := 0.0
var victory_motion_duration := 0.0
var victory_stagger := 0.0
var impact_flash_timer := 0.0
var impact_flash_duration := 0.0
var impact_recoil_offset := Vector2.ZERO

static var walk_anchor_cache := {}

func _ready() -> void:
	debug_label.visible = false
	base_sprite_scale = sprite.scale
	_create_shadow()
	_create_hp_frame()
	_style_hp_bar()
	set_focus_hp_alpha(HP_DEFAULT_ALPHA)
	_load_frames()
	play(action, direction)

func _process(delta: float) -> void:
	var previous_position := global_position
	if has_sim_target:
		if global_position.distance_to(sim_target_position) > snap_distance:
			global_position = sim_target_position
		else:
			var weight: float = clampf(delta * follow_speed, 0.0, 1.0)
			global_position = global_position.lerp(sim_target_position, weight)
		global_position = global_position.round()
		z_index = int(global_position.y)
	elif has_target:
		var to_target := target_position - global_position
		if to_target.length() <= arrive_distance:
			has_target = false
			play("idle", direction)
		else:
			var velocity := to_target.normalized() * move_speed
			global_position += velocity * delta
			play("walk", DirectionResolverScript.direction_for_vector(velocity, direction))
	var visual_velocity := (global_position - previous_position) / maxf(delta, 0.001)
	var impact_ratio := 0.0
	if impact_flash_timer > 0.0 and impact_flash_duration > 0.0:
		impact_ratio = clampf(impact_flash_timer / impact_flash_duration, 0.0, 1.0)
		impact_flash_timer = maxf(0.0, impact_flash_timer - delta)
	if victory_motion_time > 0.0:
		_update_victory_motion(delta)
	else:
		_update_sprite_motion(delta, visual_velocity, impact_ratio)
	if impact_ratio > 0.0:
		sprite.modulate = sprite.modulate.lerp(Color(1.0, 0.96, 0.66, 1.0), 0.62 * impact_ratio)

func play(next_action: String, next_direction: String) -> void:
	action = next_action
	direction = combat_readable_direction_for(character_id, action, next_direction)
	var animation := "%s_%s" % [action, direction]
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(animation):
		if sprite.animation != animation or not sprite.is_playing():
			sprite.play(animation)
			sprite.set_frame_and_progress(0, 0.0)
	else:
		push_warning("Missing animation: %s" % animation)

static func combat_readable_direction(next_action: String, next_direction: String) -> String:
	return combat_readable_direction_for("", next_action, next_direction)

static func combat_readable_direction_for(next_character_id: String, next_action: String, next_direction: String) -> String:
	if next_action == "walk" and SIDE_LOCKED_WALK_IDS.has(next_character_id):
		match next_direction:
			"east", "north-east", "south-east":
				return "east"
			"west", "north-west", "south-west":
				return "west"
			"north":
				return "south"
		return next_direction
	if not (next_action.begins_with("attack") or next_action.begins_with("skill")):
		return next_direction
	if SIDE_LOCKED_ATTACK_IDS.has(next_character_id):
		match next_direction:
			"east", "north-east", "south-east":
				return "east"
			"west", "north-west", "south-west":
				return "west"
			"north":
				return "south"
		return next_direction
	match next_direction:
		"east", "north-east":
			return "south-east"
		"west", "north-west":
			return "south-west"
		"north":
			return "south"
	return next_direction

static func combat_frame_sequence_for(next_character_id: String, next_action: String, next_direction: String) -> Array:
	var hero_overrides: Dictionary = COMBAT_FRAME_SEQUENCE_OVERRIDES.get(next_character_id, {})
	var action_overrides: Dictionary = hero_overrides.get(next_action, {})
	return action_overrides.get(next_direction, [])

func set_target(next_target: Vector2) -> void:
	target_position = next_target
	has_target = true

func sync_from_sim(unit: Dictionary) -> void:
	has_target = false
	var next_position: Vector2 = unit["position"]
	var visual_delta := next_position - global_position
	if not has_sim_target:
		global_position = next_position
		sim_target_position = next_position
		has_sim_target = true
	else:
		sim_target_position = next_position
	z_index = int(global_position.y)
	character_id = unit["character_id"]
	if sprite.sprite_frames == null:
		_load_frames()
	hp_bar.max_value = unit["max_hp"]
	hp_bar.value = unit["hp"]
	hp_bar.visible = bool(unit["alive"])
	if hp_frame != null:
		hp_frame.visible = hp_bar.visible
	if shadow != null:
		shadow.visible = bool(unit["alive"])
	var display_state := String(unit["state"])
	var display_direction := String(unit["direction"])
	display_state = display_state_for_sim_motion(display_state, visual_delta, bool(unit["alive"]))
	if bool(unit["alive"]) and display_state == "walk":
		var motion_vector: Vector2 = unit.get("velocity", visual_delta)
		if motion_vector.length() <= 2.0:
			motion_vector = visual_delta
		if motion_vector.length() > 2.0:
			display_direction = DirectionResolverScript.direction_for_vector(motion_vector, display_direction)
	play(display_state, display_direction)
	if not bool(unit["alive"]):
		sprite.modulate = Color(base_tint.r * 0.45, base_tint.g * 0.45, base_tint.b * 0.45, 0.24)
	elif String(unit["state"]) == "hurt":
		sprite.modulate = base_tint.lerp(Color(1.0, 0.94, 0.82, 1.0), 0.78)
	else:
		sprite.modulate = base_tint

func set_tint(color: Color) -> void:
	base_tint = color
	sprite.modulate = base_tint

func display_state_for_sim_motion(sim_state: String, _visual_delta: Vector2, alive: bool) -> String:
	if not alive:
		return sim_state
	if sim_state == "walk":
		return "walk"
	return sim_state

func set_team(next_team: String) -> void:
	if team == next_team:
		return
	team = next_team
	base_tint = Color(1.0, 0.58, 0.58, 1.0) if team == "enemy" else Color.WHITE
	sprite.modulate = base_tint
	_style_hp_bar()

func set_focus_hp_alpha(alpha: float) -> void:
	var target_alpha := HP_DEFAULT_ALPHA if alpha >= 0.99 else alpha
	hp_bar.modulate.a = clampf(target_alpha, 0.0, 1.0)
	if hp_frame != null:
		hp_frame.modulate.a = hp_bar.modulate.a

func play_hit_reaction(source_position: Vector2, heavy := false) -> void:
	var away := global_position - source_position
	if away.length() <= 0.01:
		away = Vector2.RIGHT if team == "enemy" else Vector2.LEFT
	away = away.normalized()
	impact_flash_duration = SKILL_HIT_REACTION_SECONDS if heavy else HIT_REACTION_SECONDS
	impact_flash_timer = impact_flash_duration
	impact_recoil_offset = away * (12.0 if heavy else 5.5) + Vector2(0.0, -3.0 if heavy else -1.0)

func play_victory(stagger_index: int = 0) -> void:
	has_target = false
	has_sim_target = false
	victory_stagger = float(stagger_index) * 0.08
	victory_motion_duration = VICTORY_MOTION_SECONDS + victory_stagger
	victory_motion_time = victory_motion_duration
	hp_bar.visible = false
	if hp_frame != null:
		hp_frame.visible = false
	if shadow != null:
		shadow.visible = true
	var victory_direction := "south"
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation("skill_01_%s" % victory_direction):
		play("skill_01", victory_direction)
	elif sprite.sprite_frames != null and sprite.sprite_frames.has_animation("attack_01_%s" % victory_direction):
		play("attack_01", victory_direction)
	else:
		play("idle", victory_direction)
	sprite.frame = 0
	sprite.speed_scale = 0.86
	sprite.modulate = base_tint.lerp(Color(1.0, 0.92, 0.58, 1.0), 0.18)

func _load_frames() -> void:
	var path := "res://generated/spriteframes/%s.tres" % character_id
	var loaded_frames := load(path) as SpriteFrames
	if loaded_frames == null:
		push_error("Missing SpriteFrames resource: %s" % path)
		return
	sprite.sprite_frames = _frames_with_combat_curation(loaded_frames)
	walk_anchor_offsets = _walk_anchor_offsets_for(character_id)

func _frames_with_combat_curation(source_frames: SpriteFrames) -> SpriteFrames:
	var hero_overrides: Dictionary = COMBAT_FRAME_SEQUENCE_OVERRIDES.get(character_id, {})
	if hero_overrides.is_empty():
		return source_frames
	var curated := source_frames.duplicate(true) as SpriteFrames
	for action_name in hero_overrides.keys():
		var direction_overrides: Dictionary = hero_overrides[action_name]
		for direction_name in direction_overrides.keys():
			var animation := "%s_%s" % [String(action_name), String(direction_name)]
			if not curated.has_animation(animation):
				continue
			var original_count := curated.get_frame_count(animation)
			if original_count <= 0:
				continue
			var textures: Array[Texture2D] = []
			var durations: Array[float] = []
			for frame_index in direction_overrides[direction_name]:
				var safe_index := clampi(int(frame_index), 0, original_count - 1)
				textures.append(curated.get_frame_texture(animation, safe_index))
				durations.append(curated.get_frame_duration(animation, safe_index))
			while curated.get_frame_count(animation) > 0:
				curated.remove_frame(animation, 0)
			for i in range(textures.size()):
				curated.add_frame(animation, textures[i], durations[i])
	return curated

func _style_hp_bar() -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.012, 0.010, 0.007, 0.14)
	background.border_width_left = 0
	background.border_width_top = 0
	background.border_width_right = 0
	background.border_width_bottom = 0
	background.corner_radius_top_left = 2
	background.corner_radius_top_right = 2
	background.corner_radius_bottom_left = 2
	background.corner_radius_bottom_right = 2
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.78, 0.07, 0.06, 1.0) if team == "enemy" else Color(0.92, 0.54, 0.12, 1.0)
	fill.border_color = Color(1.0, 0.54, 0.30, 0.42) if team == "enemy" else Color(1.0, 0.84, 0.34, 0.40)
	fill.border_width_top = 1
	fill.border_width_bottom = 1
	fill.corner_radius_top_left = 1
	fill.corner_radius_top_right = 1
	fill.corner_radius_bottom_left = 1
	fill.corner_radius_bottom_right = 1
	hp_bar.add_theme_stylebox_override("background", background)
	hp_bar.add_theme_stylebox_override("fill", fill)

func _create_hp_frame() -> void:
	var texture := load(HP_BAR_FRAME_IMAGEGEN) as Texture2D
	if texture == null:
		push_warning("Missing imagegen HP frame: %s" % HP_BAR_FRAME_IMAGEGEN)
		return
	hp_frame = Sprite2D.new()
	hp_frame.texture = texture
	var bar_size := hp_bar.size * hp_bar.scale
	var frame_size := bar_size + Vector2(12.0, 7.0)
	hp_frame.position = hp_bar.position + bar_size * 0.5
	hp_frame.scale = Vector2(frame_size.x / float(texture.get_width()), frame_size.y / float(texture.get_height()))
	hp_frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hp_frame.z_index = hp_bar.z_index - 1
	add_child(hp_frame)

func _create_shadow() -> void:
	shadow = Polygon2D.new()
	shadow.z_index = -2
	shadow.color = Color(0.0, 0.0, 0.0, 0.66)
	var points := PackedVector2Array()
	for i in range(18):
		var angle := TAU * float(i) / 18.0
		points.append(Vector2(cos(angle) * 36.0, 21.0 + sin(angle) * 10.0))
	shadow.polygon = points
	add_child(shadow)

func _update_sprite_motion(delta: float, visual_velocity: Vector2, impact_ratio := 0.0) -> void:
	var desired_offset := Vector2.ZERO
	var desired_scale := base_sprite_scale
	if action.begins_with("attack"):
		sprite.speed_scale = lerpf(sprite.speed_scale, 1.0, clampf(delta * 8.0, 0.0, 1.0))
		desired_offset = _direction_vector(direction) * 8.0
		desired_scale = base_sprite_scale * 1.035
	elif action.begins_with("skill"):
		sprite.speed_scale = lerpf(sprite.speed_scale, 1.0, clampf(delta * 8.0, 0.0, 1.0))
		desired_offset = _direction_vector(direction) * 5.0
		desired_scale = base_sprite_scale * 1.055
	elif action == "hurt":
		sprite.speed_scale = lerpf(sprite.speed_scale, 1.0, clampf(delta * 8.0, 0.0, 1.0))
		desired_offset = -_direction_vector(direction) * 6.0
		desired_scale = Vector2(base_sprite_scale.x * 1.055, base_sprite_scale.y * 0.955)
	elif action == "walk":
		var speed_ratio: float = walk_speed_scale_for_character(character_id, visual_velocity.length())
		sprite.speed_scale = lerpf(sprite.speed_scale, speed_ratio, clampf(delta * 7.0, 0.0, 1.0))
		walk_phase = fmod(walk_phase + delta * walk_bob_rate_for_speed_scale(speed_ratio), 1.0)
		var anchor := _current_walk_anchor_offset()
		desired_offset += Vector2(anchor.x * base_sprite_scale.x, anchor.y * base_sprite_scale.y) * WALK_ANCHOR_STRENGTH
		var character_bob: float = CHARACTER_WALK_BOB_PIXELS.get(character_id, 0.75)
		desired_offset.y -= absf(sin(walk_phase * TAU)) * character_bob
		var character_sway: float = CHARACTER_WALK_SWAY_PIXELS.get(character_id, 0.0)
		if character_sway > 0.0:
			desired_offset.x += sin(walk_phase * TAU) * character_sway * signf(_direction_vector(direction).x)
		if SLITHER_WALK_IDS.has(character_id):
			var slither_phase := walk_phase * TAU * 2.0
			desired_offset.x += sin(slither_phase) * 2.35 * base_sprite_scale.x
			desired_offset.y += cos(slither_phase) * 0.90 * base_sprite_scale.y
			desired_scale = Vector2(
				base_sprite_scale.x * (1.0 + absf(sin(slither_phase)) * 0.026),
				base_sprite_scale.y * (1.0 - absf(sin(slither_phase)) * 0.014)
			)
		else:
			desired_scale = Vector2(base_sprite_scale.x * 1.01, base_sprite_scale.y * 0.99)
	else:
		sprite.speed_scale = lerpf(sprite.speed_scale, 1.0, clampf(delta * 8.0, 0.0, 1.0))
		walk_phase = 0.0
	if impact_ratio > 0.0:
		desired_offset += impact_recoil_offset * impact_ratio
		desired_scale *= 1.0 + 0.065 * impact_ratio
	var weight: float = clampf(delta * 18.0, 0.0, 1.0)
	sprite.position = sprite.position.lerp(desired_offset, weight)
	sprite.scale = sprite.scale.lerp(desired_scale, weight)
	if shadow != null:
		var shadow_scale := Vector2.ONE
		if action == "walk":
			shadow_scale = Vector2(1.0 + absf(sin(walk_phase * TAU)) * 0.04, 1.0)
		shadow.scale = shadow.scale.lerp(shadow_scale, weight)

func _update_victory_motion(delta: float) -> void:
	victory_motion_time = maxf(0.0, victory_motion_time - delta)
	var elapsed := maxf(0.0, victory_motion_duration - victory_motion_time - victory_stagger)
	var active_ratio := clampf(elapsed / maxf(VICTORY_MOTION_SECONDS, 0.001), 0.0, 1.0)
	var pulse := absf(sin(active_ratio * TAU * 2.0))
	var lift := -4.0 - pulse * 7.0
	var weight: float = clampf(delta * 16.0, 0.0, 1.0)
	sprite.speed_scale = lerpf(sprite.speed_scale, 0.82, weight)
	sprite.position = sprite.position.lerp(Vector2(0.0, lift), weight)
	sprite.scale = sprite.scale.lerp(base_sprite_scale * (1.03 + pulse * 0.035), weight)
	if shadow != null:
		shadow.scale = shadow.scale.lerp(Vector2(1.05 + pulse * 0.08, 0.96), weight)
	if victory_motion_time <= 0.0:
		sprite.modulate = base_tint
		sprite.position = sprite.position.lerp(Vector2.ZERO, weight)
		sprite.scale = sprite.scale.lerp(base_sprite_scale, weight)

static func walk_speed_scale_for(visual_speed: float) -> float:
	return walk_speed_scale_for_character("", visual_speed)

static func walk_speed_scale_for_character(next_character_id: String, visual_speed: float) -> float:
	# ponytail: runtime throttle; regenerate only specific weak rows if this still reads badly.
	var min_scale: float = CHARACTER_WALK_SPEED_SCALE_MIN.get(next_character_id, WALK_SPEED_SCALE_MIN)
	var multiplier: float = CHARACTER_WALK_SPEED_SCALE_MULTIPLIER.get(next_character_id, 1.0)
	return clampf((visual_speed / WALK_SPEED_REFERENCE) * multiplier, min_scale, WALK_SPEED_SCALE_MAX)

static func walk_bob_rate_for_speed_scale(speed_scale: float) -> float:
	var ratio := inverse_lerp(WALK_SPEED_SCALE_MIN, WALK_SPEED_SCALE_MAX, speed_scale)
	return lerpf(WALK_BOB_RATE_MIN, WALK_BOB_RATE_MAX, clampf(ratio, 0.0, 1.0))

func _current_walk_anchor_offset() -> Vector2:
	var offsets: Array = walk_anchor_offsets.get(direction, [])
	if offsets.is_empty():
		return Vector2.ZERO
	return offsets[clampi(sprite.frame, 0, offsets.size() - 1)]

static func _walk_anchor_offsets_for(hero_id: String) -> Dictionary:
	if walk_anchor_cache.has(hero_id):
		return walk_anchor_cache[hero_id]
	var result := {}
	var sheet_path := "res://assets/characters/GameSiam/%s/walk-sheet-clean.png" % hero_id
	var texture := load(sheet_path) as Texture2D
	if texture == null:
		walk_anchor_cache[hero_id] = result
		return result
	var image := texture.get_image()
	if image == null:
		walk_anchor_cache[hero_id] = result
		return result
	var metadata := _read_json("res://assets/characters/GameSiam/%s/walk-metadata.json" % hero_id)
	var rows_meta: Array = metadata.get("rows_meta", [])
	var cell := int(metadata.get("cell", 64))
	for row_meta in rows_meta:
		var direction_name := String(row_meta.get("direction", "south"))
		if not WALK_DIRECTIONS.has(direction_name):
			continue
		var row := int(row_meta.get("row", 0))
		var frame_count := int(row_meta.get("frames", 6))
		var boxes: Array[Rect2i] = []
		for column in range(frame_count):
			boxes.append(_alpha_bbox(image, Rect2i(column * cell, row * cell, cell, cell)))
		result[direction_name] = _offsets_from_boxes(boxes)
	walk_anchor_cache[hero_id] = result
	return result

static func _offsets_from_boxes(boxes: Array[Rect2i]) -> Array[Vector2]:
	var bottoms: Array[float] = []
	var centers: Array[float] = []
	for box in boxes:
		if box.size == Vector2i.ZERO:
			continue
		bottoms.append(float(box.position.y + box.size.y))
		centers.append(float(box.position.x) + float(box.size.x) * 0.5)
	var ref_bottom := _median(bottoms)
	var ref_center := _median(centers)
	var offsets: Array[Vector2] = []
	for box in boxes:
		if box.size == Vector2i.ZERO:
			offsets.append(Vector2.ZERO)
			continue
		var bottom := float(box.position.y + box.size.y)
		var center := float(box.position.x) + float(box.size.x) * 0.5
		offsets.append(Vector2(
			clampf(ref_center - center, -4.0, 4.0),
			clampf(ref_bottom - bottom, -4.0, 5.0)
		))
	return offsets

static func _alpha_bbox(image: Image, rect: Rect2i) -> Rect2i:
	var min_x := rect.size.x
	var min_y := rect.size.y
	var max_x := -1
	var max_y := -1
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			if image.get_pixel(x, y).a <= 0.01:
				continue
			var local_x := x - rect.position.x
			var local_y := y - rect.position.y
			min_x = mini(min_x, local_x)
			min_y = mini(min_y, local_y)
			max_x = maxi(max_x, local_x)
			max_y = maxi(max_y, local_y)
	if max_x < min_x or max_y < min_y:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)

static func _median(values: Array[float]) -> float:
	if values.is_empty():
		return 0.0
	values.sort()
	var mid := values.size() / 2
	if values.size() % 2 == 1:
		return values[mid]
	return (values[mid - 1] + values[mid]) * 0.5

static func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _direction_vector(next_direction: String) -> Vector2:
	match next_direction:
		"east":
			return Vector2.RIGHT
		"west":
			return Vector2.LEFT
		"north":
			return Vector2.UP
		"south":
			return Vector2.DOWN
		"north-east":
			return Vector2(1, -1).normalized()
		"north-west":
			return Vector2(-1, -1).normalized()
		"south-east":
			return Vector2(1, 1).normalized()
		"south-west":
			return Vector2(-1, 1).normalized()
	return Vector2.ZERO
