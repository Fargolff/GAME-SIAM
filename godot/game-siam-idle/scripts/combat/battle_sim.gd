class_name BattleSim
extends RefCounted

const DirectionResolverScript := preload("res://scripts/presentation/direction_resolver.gd")
const HeroCatalogScript := preload("res://scripts/content/hero_catalog.gd")

const MAX_WAVE := HeroCatalogScript.MAX_CAMPAIGN_WAVE
const DEFAULT_FORMATION := HeroCatalogScript.DEFAULT_FORMATION
const PLAYER_SLOTS := [
	Vector2(470, 270),
	Vector2(470, 460),
	Vector2(300, 270),
	Vector2(275, 365),
	Vector2(300, 460),
]
const ENEMY_SLOTS := [
	Vector2(835, 255),
	Vector2(1015, 365),
	Vector2(835, 485),
	Vector2(990, 300),
	Vector2(990, 430),
]
# ponytail: readable clash spacing; keep combat tactics data-driven later.
const PLAYER_ENGAGE_SLOTS := [
	Vector2(560, 270),
	Vector2(560, 460),
	Vector2(460, 270),
	Vector2(430, 365),
	Vector2(460, 460),
]
const ENEMY_ENGAGE_SLOTS := [
	Vector2(735, 255),
	Vector2(880, 365),
	Vector2(735, 485),
	Vector2(855, 300),
	Vector2(855, 430),
]
const ARENA_MIN := Vector2(235, 245)
const ARENA_MAX := Vector2(1045, 500)
const ENGAGE_VERTICAL_OFFSETS := [-44.0, 44.0, -24.0, 24.0, 0.0]
const ENGAGE_FORWARD_OFFSETS := [0.0, 16.0, 8.0, 22.0, 12.0]
const ATTACK_SLOT_VERTICAL_OFFSETS := [0.0, -48.0, 48.0, -28.0, 28.0]
const ATTACK_SLOT_FORWARD_OFFSETS := [0.0, 8.0, 8.0, 18.0, 18.0]
const APPROACH_VERTICAL_OFFSETS := [-24.0, 24.0, -15.0, 15.0, 0.0]
const SEPARATION_RADIUS := 88.0
const SEPARATION_WEIGHT := 84.0
const PLAYER_MIN_SPACING := 62.0
const ENEMY_MIN_SPACING := 72.0
const OPPONENT_MIN_SPACING := 54.0
const LANE_DISTANCE_WEIGHT := 0.24
const RANGED_RANGE_THRESHOLD := 120.0
const RANGED_REACH_BONUS := 480.0
const RANGED_READY_RANGE_BUFFER := 10.0
const MELEE_REACH_PADDING := 5.0
const FIRST_SESSION_MILESTONE_REWARDS := {
	1: {"gold": 70, "essence": 0, "shards": 0},
	3: {"gold": 45, "essence": 1, "shards": 0},
	5: {"gold": 85, "essence": 2, "shards": 3},
	10: {"gold": 160, "essence": 4, "shards": 5},
}
var units: Array[Dictionary] = []
var elapsed := 0.0
var result := "running"

static func default_formation() -> Array:
	return DEFAULT_FORMATION.duplicate()

static func upgrade_cost(level: int) -> int:
	return 80 + max(1, level) * 45

static func reward_for_wave(wave_id: int) -> Dictionary:
	var safe_wave: int = clampi(wave_id, 1, MAX_WAVE)
	var reward := {
		"gold": 55 + safe_wave * 18,
		"essence": 2 + int(safe_wave / 4),
		"shards": 1 if safe_wave % 5 == 0 else 0,
	}
	if FIRST_SESSION_MILESTONE_REWARDS.has(safe_wave):
		var bonus: Dictionary = FIRST_SESSION_MILESTONE_REWARDS[safe_wave]
		reward["gold"] = int(reward["gold"]) + int(bonus["gold"])
		reward["essence"] = int(reward["essence"]) + int(bonus["essence"])
		reward["shards"] = int(reward["shards"]) + int(bonus["shards"])
	return reward

func setup_demo() -> void:
	elapsed = 0.0
	result = "running"
	units = [
		_unit("p1", "player", "S03_YAKSHA_KRAIASURA", PLAYER_SLOTS[0], PLAYER_ENGAGE_SLOTS[0], 360, 24, 18, 46, 1.4, 80),
		_unit("p2", "player", "S01_GARUDA_VAYUDEJ", PLAYER_SLOTS[1], PLAYER_ENGAGE_SLOTS[1], 280, 36, 10, 56, 1.1, 100),
		_unit("p3", "player", "S02_NAGA_SASINAKA", PLAYER_SLOTS[3], PLAYER_ENGAGE_SLOTS[3], 220, 42, 8, 170, 1.6, 72),
		_unit("e1", "enemy", "A02_TIGER_PLOENGPAYAK", ENEMY_SLOTS[0], ENEMY_ENGAGE_SLOTS[0], 190, 26, 8, 46, 1.2, 92),
		_unit("e2", "enemy", "A03_HUMAN_ARUNRAT", ENEMY_SLOTS[1], ENEMY_ENGAGE_SLOTS[1], 160, 24, 6, 150, 1.4, 70),
		_unit("e3", "enemy", "A06_SPIRIT_RAMPAN_MASK", ENEMY_SLOTS[3], ENEMY_ENGAGE_SLOTS[3], 175, 22, 7, 135, 1.6, 66),
	]

func setup_wave(wave_id: int, formation: Array, hero_levels: Dictionary = {}) -> void:
	elapsed = 0.0
	result = "running"
	units = []

	var safe_wave: int = clampi(wave_id, 1, MAX_WAVE)
	var slot_count: int = min(5, formation.size())
	for slot in range(slot_count):
		var hero_id: String = String(formation[slot])
		if not HeroCatalogScript.has_hero(hero_id):
			continue
		var level: int = max(1, int(hero_levels.get(hero_id, 1)))
		var player_position: Vector2 = PLAYER_SLOTS[slot]
		units.append(_leveled_player("p%d" % (slot + 1), hero_id, player_position, PLAYER_ENGAGE_SLOTS[slot], level))

	var wave: Dictionary = HeroCatalogScript.campaign_wave(safe_wave)
	var enemy_count: int = int(wave["enemy_count"])
	var normal_enemy_count := enemy_count
	if safe_wave % 10 == 0:
		normal_enemy_count = mini(enemy_count, ENEMY_SLOTS.size() - 1)

	for i in range(normal_enemy_count):
		units.append(_enemy("e%d" % (i + 1), safe_wave, i, false))
	if safe_wave % 10 == 0:
		var boss_index: int = min(normal_enemy_count, ENEMY_SLOTS.size() - 1)
		units.append(_enemy("boss", safe_wave, boss_index, true))

func tick(delta: float) -> void:
	if result != "running":
		return

	elapsed += delta
	for unit in units:
		if not bool(unit["alive"]):
			continue
		unit["attack_timer"] = maxf(0.0, float(unit["attack_timer"]) - delta)
		unit["forced_timer"] = maxf(0.0, float(unit["forced_timer"]) - delta)
		if float(unit["forced_timer"]) <= 0.0:
			if String(unit["state"]) != "walk":
				unit["state"] = "idle"
			var current_velocity: Vector2 = unit["velocity"]
			unit["velocity"] = current_velocity.move_toward(Vector2.ZERO, 260.0 * delta)

	for unit in units:
		if not bool(unit["alive"]) or float(unit["forced_timer"]) > 0.0:
			continue
		var target := _best_enemy(unit)
		if target.is_empty():
			unit["target_id"] = ""
			continue
		unit["target_id"] = String(target["id"])

		var to_target: Vector2 = target["position"] - unit["position"]
		unit["direction"] = DirectionResolverScript.direction_for_vector(to_target, String(unit["direction"]))
		var attack_range: float = _attack_reach(unit)
		var ready_attack_range: float = _attack_ready_range(unit, attack_range)
		var visual_distance_to_target: float = to_target.length()
		var combat_distance_to_target: float = _combat_distance(unit, target)
		var engage_goal := _engage_goal(unit, target, attack_range)
		var is_ranged := _is_ranged(unit)
		var distance_to_goal: float = unit["position"].distance_to(engage_goal)
		var personal_space: Vector2 = _separation_offset(unit)
		var crowded := personal_space.length() > 7.0
		var stopping_distance := _stopping_distance(unit)
		var out_of_attack_reach := combat_distance_to_target > ready_attack_range
		var wants_melee_slot := not is_ranged and distance_to_goal > 34.0 and visual_distance_to_target > stopping_distance + 14.0
		var wants_range_band := is_ranged and out_of_attack_reach
		var should_reposition := out_of_attack_reach or wants_range_band or wants_melee_slot or (crowded and float(unit["attack_timer"]) > 0.18)
		if should_reposition and visual_distance_to_target > 0.0:
			_advance_unit(unit, target, engage_goal, ready_attack_range, personal_space, delta)
		elif float(unit["attack_timer"]) <= 0.0:
			_attack(unit, target)
		else:
			unit["state"] = "idle"
			var current_velocity: Vector2 = unit["velocity"]
			unit["velocity"] = current_velocity.move_toward(Vector2.ZERO, 420.0 * delta)

	_resolve_ally_spacing()
	_resolve_opponent_spacing()
	_resolve_result()

func _attack(attacker: Dictionary, target: Dictionary) -> void:
	var to_target: Vector2 = target["position"] - attacker["position"]
	if to_target.length_squared() > 0.0001:
		attacker["direction"] = DirectionResolverScript.direction_for_vector(_readable_attack_direction_vector(attacker, target), String(attacker["direction"]))
	var damage: int = maxi(1, int(round(float(attacker["attack"]) - float(target["defense"]) * 0.35)))
	target["hp"] = maxi(0, int(target["hp"]) - damage)
	attacker["attack_timer"] = attacker["cooldown"]
	attacker["state"] = "attack_01"
	attacker["forced_timer"] = 0.45
	target["state"] = "hurt"
	target["forced_timer"] = 0.28
	target["last_hit_visual_delay"] = 0.22 if _is_ranged(attacker) else 0.11
	target["last_hit_from_position"] = attacker["position"]
	target["last_hit_is_ranged"] = _is_ranged(attacker)
	target["last_hit_attacker_id"] = attacker["character_id"]
	var recoil: Vector2 = (target["position"] - attacker["position"]).normalized()
	target["position"] = _clamp_to_arena(target["position"] + recoil * (5.0 if _is_ranged(attacker) else 1.0))
	if int(target["hp"]) <= 0:
		target["alive"] = false
		target["state"] = "death"
		target["forced_timer"] = 99.0

func _best_enemy(unit: Dictionary) -> Dictionary:
	var best := {}
	var best_score := INF
	for candidate in units:
		if candidate["team"] == unit["team"] or not bool(candidate["alive"]):
			continue
		var score := _target_score(unit, candidate)
		if score < best_score:
			best_score = score
			best = candidate
	return best

func _target_score(unit: Dictionary, candidate: Dictionary) -> float:
	var unit_position: Vector2 = unit["position"]
	var candidate_position: Vector2 = candidate["position"]
	var distance: float = unit_position.distance_to(candidate_position)
	var lane_gap: float = absf(float(unit["engage_position"].y) - float(candidate["engage_position"].y))
	var pressure: int = _target_pressure(unit, candidate)
	var front_bias: float = candidate_position.x if String(unit["team"]) == "player" else 1280.0 - candidate_position.x
	var score: float = distance * 0.82 + lane_gap * 1.58 + front_bias * 0.36 + float(pressure) * 360.0
	if String(unit.get("target_id", "")) == String(candidate["id"]):
		score -= 75.0
	return score

func _combat_distance(unit: Dictionary, target: Dictionary) -> float:
	var delta: Vector2 = target["position"] - unit["position"]
	if not _is_ranged(unit):
		return delta.length()
	return absf(delta.x) + absf(delta.y) * LANE_DISTANCE_WEIGHT

func _target_pressure(unit: Dictionary, candidate: Dictionary) -> int:
	var pressure := 0
	var candidate_id := String(candidate["id"])
	for other in units:
		if other == unit or other["team"] != unit["team"] or not bool(other["alive"]):
			continue
		if String(other.get("target_id", "")) == candidate_id:
			pressure += 1
	return pressure

func _attack_reach(unit: Dictionary) -> float:
	var base_range := float(unit["range"])
	if base_range >= RANGED_RANGE_THRESHOLD:
		return base_range + RANGED_REACH_BONUS
	return _stopping_distance(unit) + MELEE_REACH_PADDING

func _attack_ready_range(unit: Dictionary, attack_range: float) -> float:
	if _is_ranged(unit):
		return maxf(RANGED_RANGE_THRESHOLD, attack_range - RANGED_READY_RANGE_BUFFER)
	return attack_range

func _is_ranged(unit: Dictionary) -> bool:
	return float(unit["range"]) >= RANGED_RANGE_THRESHOLD

func _advance_unit(unit: Dictionary, target: Dictionary, engage_goal: Vector2, attack_range: float, separation: Vector2, delta: float) -> void:
	var distance_to_target: float = unit["position"].distance_to(target["position"])
	var move_goal := _approach_goal(unit, engage_goal, distance_to_target, attack_range)
	separation.y *= 0.92
	move_goal += separation
	move_goal.y = lerpf(move_goal.y, float(unit["engage_position"].y), 0.48)
	move_goal = _limit_goal_to_reach(move_goal, target["position"], attack_range * 0.96)
	move_goal = _clamp_to_arena(move_goal)

	var to_goal: Vector2 = move_goal - unit["position"]
	var forward_sign := 1.0 if String(unit["team"]) == "player" else -1.0
	if to_goal.x * forward_sign < 0.0:
		to_goal.x = 0.0
	var arrival_threshold := 2.0 if attack_range < 180.0 else 5.0
	if to_goal.length() <= arrival_threshold:
		unit["state"] = "idle"
		var idle_velocity: Vector2 = unit["velocity"]
		unit["velocity"] = idle_velocity.move_toward(Vector2.ZERO, 420.0 * delta)
		return

	var speed: float = maxf(float(unit["move_speed"]) * 1.06, 76.0)
	var speed_scale: float = clampf(to_goal.length() / 96.0, 0.28, 1.0)
	var desired_velocity := to_goal.normalized() * speed * speed_scale
	var current_velocity: Vector2 = unit["velocity"]
	var next_velocity: Vector2 = current_velocity.lerp(desired_velocity, clampf(delta * 5.2, 0.0, 1.0))
	if next_velocity.length() < 12.0:
		next_velocity = desired_velocity.normalized() * minf(desired_velocity.length(), 12.0)
	var step := next_velocity.normalized() * minf(next_velocity.length() * delta, to_goal.length())
	unit["position"] = _clamp_to_arena(unit["position"] + step)
	unit["velocity"] = step / maxf(delta, 0.001)
	unit["state"] = "walk"
	unit["direction"] = DirectionResolverScript.direction_for_vector(_readable_walk_direction_vector(unit, target, unit["velocity"]), String(unit["direction"]))

func _engage_goal(unit: Dictionary, target: Dictionary, attack_range: float) -> Vector2:
	var slot := _unit_slot_index(unit)
	var side := -1.0 if String(unit["team"]) == "player" else 1.0
	var side_distance: float = _stopping_distance(unit) if attack_range < 180.0 else clampf(_stopping_distance(unit), 270.0, 360.0)
	var slot_forward := float(ENGAGE_FORWARD_OFFSETS[slot % ENGAGE_FORWARD_OFFSETS.size()])
	var slot_y := float(ENGAGE_VERTICAL_OFFSETS[slot % ENGAGE_VERTICAL_OFFSETS.size()])
	if attack_range < 180.0:
		var attack_slot := _attack_slot_index(unit, target)
		slot_forward = float(ATTACK_SLOT_FORWARD_OFFSETS[attack_slot % ATTACK_SLOT_FORWARD_OFFSETS.size()])
		slot_y = float(ATTACK_SLOT_VERTICAL_OFFSETS[attack_slot % ATTACK_SLOT_VERTICAL_OFFSETS.size()])
	var x_offset: float = side * clampf(side_distance + slot_forward, 58.0, attack_range * 0.94)
	var max_lane_offset := 44.0 if attack_range < 180.0 else 88.0
	var y_offset: float = clampf(slot_y, -max_lane_offset, max_lane_offset)
	var goal: Vector2 = target["position"] + Vector2(x_offset, y_offset)
	var lane_weight := 0.18 if attack_range < 180.0 else 0.52
	goal.y = lerpf(goal.y, float(unit["engage_position"].y), lane_weight)
	return _clamp_to_arena(goal)

func _attack_slot_index(unit: Dictionary, target: Dictionary) -> int:
	var index := 0
	var target_id := String(target["id"])
	for other in units:
		if other == unit:
			return index
		if other["team"] != unit["team"] or not bool(other["alive"]):
			continue
		if String(other.get("target_id", "")) == target_id:
			index += 1
	return index

func _approach_goal(unit: Dictionary, engage_goal: Vector2, distance_to_target: float, attack_range: float) -> Vector2:
	var far_weight: float = clampf((distance_to_target - attack_range - 70.0) / 260.0, 0.0, 1.0)
	if far_weight <= 0.0:
		return engage_goal
	var slot := _unit_slot_index(unit)
	var lane_y: float = float(unit["engage_position"].y) + float(APPROACH_VERTICAL_OFFSETS[slot % APPROACH_VERTICAL_OFFSETS.size()])
	var lane_goal := Vector2(
		lerpf(float(unit["position"].x), engage_goal.x, 0.70),
		lerpf(lane_y, engage_goal.y, 0.35)
	)
	return engage_goal.lerp(lane_goal, far_weight * 0.65)

func _separation_offset(unit: Dictionary) -> Vector2:
	var offset := Vector2.ZERO
	var unit_position: Vector2 = unit["position"]
	for other in units:
		if other == unit or not bool(other["alive"]):
			continue
		var other_position: Vector2 = other["position"]
		var away := unit_position - other_position
		var distance := away.length()
		var radius := SEPARATION_RADIUS if other["team"] == unit["team"] else SEPARATION_RADIUS * 0.94
		if distance > 0.01 and distance < radius:
			var strength := (radius - distance) / radius
			var team_weight := 1.0 if other["team"] == unit["team"] else 0.5
			offset += away.normalized() * strength * SEPARATION_WEIGHT * team_weight
	return offset

func _resolve_ally_spacing() -> void:
	for i in range(units.size()):
		var a := units[i]
		if not bool(a["alive"]):
			continue
		for j in range(i + 1, units.size()):
			var b := units[j]
			if String(a["team"]) != String(b["team"]) or not bool(b["alive"]):
				continue
			var a_position: Vector2 = a["position"]
			var b_position: Vector2 = b["position"]
			var away := a_position - b_position
			var distance := away.length()
			var minimum_spacing := ENEMY_MIN_SPACING if String(a["team"]) == "enemy" else PLAYER_MIN_SPACING
			if distance >= minimum_spacing:
				continue
			if distance <= 0.01:
				away = Vector2(0.0, -1.0 if _unit_slot_index(a) < _unit_slot_index(b) else 1.0)
				distance = 1.0
			var correction := away.normalized() * ((minimum_spacing - distance) * 0.54)
			correction.x *= 0.24
			correction.y *= 1.30
			var a_delta := _non_backward_spacing_delta(a, correction)
			var b_delta := _non_backward_spacing_delta(b, -correction)
			a["position"] = _clamp_to_arena(a_position + a_delta)
			b["position"] = _clamp_to_arena(b_position + b_delta)

func _resolve_opponent_spacing() -> void:
	for i in range(units.size()):
		var a := units[i]
		if not bool(a["alive"]):
			continue
		for j in range(i + 1, units.size()):
			var b := units[j]
			if String(a["team"]) == String(b["team"]) or not bool(b["alive"]):
				continue
			var a_position: Vector2 = a["position"]
			var b_position: Vector2 = b["position"]
			var away := a_position - b_position
			var distance := away.length()
			if distance >= OPPONENT_MIN_SPACING:
				continue
			if distance <= 0.01:
				away = Vector2(-1.0 if String(a["team"]) == "player" else 1.0, 0.0)
				distance = 1.0
			var correction := away.normalized() * ((OPPONENT_MIN_SPACING - distance) * 0.46)
			if absf(correction.y) < 1.0:
				var vertical_sign := -1.0 if _unit_slot_index(a) <= _unit_slot_index(b) else 1.0
				correction.y = vertical_sign * maxf(absf(correction.x) * 0.85, 2.0)
			correction.x *= 0.18
			correction.y *= 1.24
			var a_delta := _non_backward_spacing_delta(a, correction)
			var b_delta := _non_backward_spacing_delta(b, -correction)
			a["position"] = _clamp_to_arena(a_position + a_delta)
			b["position"] = _clamp_to_arena(b_position + b_delta)

func _stopping_distance(unit: Dictionary) -> float:
	if _is_ranged(unit):
		return 342.0
	if String(unit["character_id"]) == "B04_HUMAN_DARIN":
		return 62.0
	match HeroCatalogScript.archetype_for(String(unit["character_id"])):
		"guardian":
			return 62.0
		"vanguard":
			return 58.0
		"skirmisher":
			return 54.0
	return 56.0

func _limit_goal_to_reach(goal: Vector2, target_position: Vector2, max_distance: float) -> Vector2:
	var from_target := goal - target_position
	if max_distance < 180.0:
		from_target.x = clampf(from_target.x, -max_distance, max_distance)
		from_target.y = clampf(from_target.y, -44.0, 44.0)
		if from_target.length() > max_distance:
			from_target = from_target.normalized() * max_distance
		return target_position + from_target
	if from_target.length() > max_distance:
		return target_position + from_target.normalized() * max_distance
	return goal

func _readable_walk_direction_vector(unit: Dictionary, target: Dictionary, velocity: Vector2) -> Vector2:
	if velocity.length_squared() <= 0.001:
		return target["position"] - unit["position"]
	var forward_sign := 1.0 if String(unit["team"]) == "player" else -1.0
	var readable := velocity
	if readable.x * forward_sign < 0.0:
		readable.x = forward_sign * absf(readable.x) * 0.35
	elif absf(readable.x) < 18.0:
		readable.x = forward_sign * 18.0
	return readable

func _readable_attack_direction_vector(unit: Dictionary, target: Dictionary) -> Vector2:
	var readable: Vector2 = target["position"] - unit["position"]
	var forward_sign := 1.0 if String(unit["team"]) == "player" else -1.0
	if readable.x * forward_sign < 0.0 or absf(readable.x) < 18.0:
		readable.x = forward_sign * maxf(absf(readable.x), 32.0)
	readable.y *= 0.22
	return readable

func _non_backward_spacing_delta(unit: Dictionary, delta: Vector2) -> Vector2:
	if String(unit["state"]) != "walk":
		return delta
	var forward_sign := 1.0 if String(unit["team"]) == "player" else -1.0
	if delta.x * forward_sign < 0.0:
		delta.x = 0.0
	return delta

func _clamp_to_arena(position: Vector2) -> Vector2:
	return Vector2(
		clampf(position.x, ARENA_MIN.x, ARENA_MAX.x),
		clampf(position.y, ARENA_MIN.y, ARENA_MAX.y)
	)

func _unit_slot_index(unit: Dictionary) -> int:
	var unit_id := String(unit["id"])
	if unit_id == "boss":
		return 4
	if unit_id.length() < 2:
		return 0
	var index: int = int(unit_id.substr(1, unit_id.length() - 1)) - 1
	if index < 0:
		return 0
	return index

func _resolve_result() -> void:
	var player_alive := false
	var enemy_alive := false
	for unit in units:
		player_alive = player_alive or (unit["team"] == "player" and bool(unit["alive"]))
		enemy_alive = enemy_alive or (unit["team"] == "enemy" and bool(unit["alive"]))
	if not enemy_alive:
		result = "players"
	elif not player_alive:
		result = "enemies"

func _unit(id: String, team: String, character_id: String, position: Vector2, engage_position: Vector2, hp: int, attack: int, defense: int, attack_range: float, cooldown: float, move_speed: float) -> Dictionary:
	return {
		"id": id,
		"team": team,
		"character_id": character_id,
		"position": position,
		"engage_position": engage_position,
		"hp": hp,
		"max_hp": hp,
		"attack": attack,
		"defense": defense,
		"range": attack_range,
		"cooldown": cooldown,
		"move_speed": move_speed,
		"attack_timer": 0.4,
		"forced_timer": 0.0,
		"state": "idle",
		"direction": "south" if team == "player" else "west",
		"velocity": Vector2.ZERO,
		"target_id": "",
		"last_hit_visual_delay": 0.12,
		"last_hit_from_position": position,
		"last_hit_is_ranged": false,
		"last_hit_attacker_id": "",
		"alive": true,
	}

func _leveled_player(id: String, character_id: String, position: Vector2, engage_position: Vector2, level: int) -> Dictionary:
	var base: Dictionary = HeroCatalogScript.base_stats_for(character_id)
	var bonus: int = level - 1
	return _unit(
		id,
		"player",
		character_id,
		position,
		engage_position,
		int(base["hp"]) + bonus * 54,
		int(base["attack"]) + bonus * 12,
		int(base["defense"]) + bonus * 4,
		float(base["range"]),
		float(base["cooldown"]),
		float(base["move_speed"])
	)

func _enemy(id: String, wave_id: int, index: int, boss: bool) -> Dictionary:
	var modifier: Dictionary = HeroCatalogScript.enemy_family_modifier(wave_id)
	var hp: int = 95 + wave_id * 22 + index * 18
	var attack: int = 14 + wave_id * 2 + index * 2
	var defense: int = 5 + int(wave_id * 0.8)
	var attack_range: float = 46.0
	var cooldown: float = 1.35
	if index % 3 == 1:
		attack_range = 150.0
		cooldown = 1.55
	if boss:
		hp = 360 + wave_id * 58
		attack = 28 + wave_id * 4
		defense = 14 + int(wave_id * 1.3)
		attack_range = 56.0
		cooldown = 1.2

	return _unit(
		id,
		"enemy",
		HeroCatalogScript.enemy_skin_for_wave(wave_id, index),
		Vector2(ENEMY_SLOTS[index % ENEMY_SLOTS.size()]),
		Vector2(ENEMY_ENGAGE_SLOTS[index % ENEMY_ENGAGE_SLOTS.size()]),
		int(round(float(hp) * float(modifier["hp"]))),
		int(round(float(attack) * float(modifier["attack"]))),
		int(round(float(defense) * float(modifier["defense"]))),
		attack_range,
		cooldown,
		78.0
	)
