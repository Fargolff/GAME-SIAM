extends SceneTree

const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")
const UnitViewScript := preload("res://scripts/presentation/unit_view.gd")
const HeroCatalogScript := preload("res://scripts/content/hero_catalog.gd")

func _initialize() -> void:
	var first := _run_demo()
	var second := _run_demo()
	var failures: Array[String] = []

	if first["result"] != "players":
		failures.append("Expected players to win demo battle, got %s" % first["result"])
	if second["result"] != first["result"]:
		failures.append("Demo battle result is not deterministic.")
	if second["signature"] != first["signature"]:
		failures.append("Demo battle final HP signature is not deterministic.")
	_validate_movement_polish(failures)
	_validate_melee_reach(failures)
	_validate_all_hero_attack_ranges(failures)
	_validate_target_slot_reservation(failures)
	_validate_melee_walk_stability(failures)
	_validate_idle_follow_does_not_fake_walk(failures)
	_validate_walk_playback_speed(failures)
	_validate_attack_facing_contract(failures)
	_validate_victory_pose_contract(failures)
	_validate_hit_reaction_contract(failures)

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("Phase 3 battle validation passed: %s %s" % [first["result"], first["signature"]])
	quit(0)

func _validate_movement_polish(failures: Array[String]) -> void:
	var sim := BattleSimScript.new()
	sim.setup_wave(10, BattleSimScript.default_formation(), {})
	var min_player_spacing := INF
	var min_enemy_spacing := INF
	var min_opponent_spacing := INF
	var ranged_max_forward_px := 0.0
	var ranged_max_forward_id := ""
	var hit_delay_seen := false
	var previous_positions := {}
	var start_positions := {}
	var backward_samples := 0
	var max_backward_step := 0.0
	var s01_attack_overreach_frames := 0
	var s01_max_attack_distance := 0.0
	var s01_bad_attack_direction := ""
	for unit in sim.units:
		previous_positions[String(unit["id"])] = unit["position"]
		start_positions[String(unit["id"])] = unit["position"]
	for i in range(120):
		sim.tick(0.1)
		var by_id := {}
		for unit in sim.units:
			by_id[String(unit["id"])] = unit
		for unit in sim.units:
			var unit_id := String(unit["id"])
			var previous: Vector2 = previous_positions.get(unit_id, unit["position"])
			var current: Vector2 = unit["position"]
			previous_positions[unit_id] = current
			if unit["team"] == "player" and String(unit["state"]) == "walk":
				var dx := current.x - previous.x
				if dx < -0.35:
					backward_samples += 1
					max_backward_step = maxf(max_backward_step, absf(dx))
			if unit["team"] == "player" and float(unit["range"]) >= BattleSimScript.RANGED_RANGE_THRESHOLD:
				var start: Vector2 = start_positions.get(unit_id, current)
				var forward_px: float = current.x - start.x
				if forward_px > ranged_max_forward_px:
					ranged_max_forward_px = forward_px
					ranged_max_forward_id = String(unit["character_id"])
			if String(unit["character_id"]) == "S01_GARUDA_VAYUDEJ" and String(unit["state"]) == "attack_01":
				var readable_attack_direction := UnitViewScript.combat_readable_direction_for("S01_GARUDA_VAYUDEJ", "attack_01", String(unit["direction"]))
				if readable_attack_direction != "east" and readable_attack_direction != "west":
					s01_bad_attack_direction = readable_attack_direction
				var target_id := String(unit.get("target_id", ""))
				if by_id.has(target_id):
					var target: Dictionary = by_id[target_id]
					var attack_distance: float = current.distance_to(target["position"])
					s01_max_attack_distance = maxf(s01_max_attack_distance, attack_distance)
					if attack_distance > sim._attack_reach(unit) + 6.0:
						s01_attack_overreach_frames += 1
			if float(unit.get("last_hit_visual_delay", 0.0)) >= 0.11:
				hit_delay_seen = true
		for a in sim.units:
			if a["team"] != "player" or not bool(a["alive"]):
				continue
			for b in sim.units:
				if b == a or b["team"] != "player" or not bool(b["alive"]):
					continue
				min_player_spacing = minf(min_player_spacing, (a["position"] as Vector2).distance_to(b["position"]))
		for a in sim.units:
			if a["team"] != "enemy" or not bool(a["alive"]):
				continue
			for b in sim.units:
				if b == a or b["team"] != "enemy" or not bool(b["alive"]):
					continue
				min_enemy_spacing = minf(min_enemy_spacing, (a["position"] as Vector2).distance_to(b["position"]))
		for a in sim.units:
			if a["team"] != "player" or not bool(a["alive"]):
				continue
			for b in sim.units:
				if b["team"] != "enemy" or not bool(b["alive"]):
					continue
				min_opponent_spacing = minf(min_opponent_spacing, (a["position"] as Vector2).distance_to(b["position"]))
		if sim.result != "running":
			break
	if ranged_max_forward_px > 96.0:
		failures.append("Ranged player drifted too far forward: %s %.1f px." % [ranged_max_forward_id, ranged_max_forward_px])
	if min_player_spacing < 52.0:
		failures.append("Player formation overlapped too tightly: %.1f px." % min_player_spacing)
	if min_enemy_spacing < 58.0:
		failures.append("Enemy formation overlapped too tightly: %.1f px." % min_enemy_spacing)
	if min_opponent_spacing < 46.0:
		failures.append("Opposing units overlapped too tightly: %.1f px." % min_opponent_spacing)
	if backward_samples > 3:
		failures.append("Wave 10 melee walk has backward jitter samples: %d, max %.2f px." % [backward_samples, max_backward_step])
	if s01_attack_overreach_frames > 0:
		failures.append("S01 melee attack reads too far in %d frames, max %.1f px." % [s01_attack_overreach_frames, s01_max_attack_distance])
	if s01_bad_attack_direction != "":
		failures.append("S01 melee attack should read east/west on the horizontal field, got %s." % s01_bad_attack_direction)
	if not hit_delay_seen:
		failures.append("Normal attacks should expose a visual hit delay for impact sync.")

func _validate_melee_reach(failures: Array[String]) -> void:
	var sim := BattleSimScript.new()
	sim.setup_demo()
	for unit in sim.units:
		if float(unit["range"]) >= BattleSimScript.RANGED_RANGE_THRESHOLD:
			continue
		var reach: float = sim._attack_reach(unit)
		var stop: float = sim._stopping_distance(unit)
		if reach > 84.0:
			failures.append("%s melee reach is too long: %.1f px." % [unit["character_id"], reach])
		if stop > 66.0:
			failures.append("%s melee stopping distance is too far: %.1f px." % [unit["character_id"], stop])

func _validate_all_hero_attack_ranges(failures: Array[String]) -> void:
	var sim := BattleSimScript.new()
	for hero_id in HeroCatalogScript.all_heroes():
		var unit := sim._leveled_player("p1", hero_id, Vector2(470, 365), Vector2(560, 365), 1)
		var base_range := float(unit["range"])
		var reach: float = sim._attack_reach(unit)
		if base_range < BattleSimScript.RANGED_RANGE_THRESHOLD:
			var stop: float = sim._stopping_distance(unit)
			if reach > base_range + 24.0:
				failures.append("%s melee reach has too much padding: base %.1f -> reach %.1f." % [hero_id, base_range, reach])
			if reach - stop > BattleSimScript.MELEE_REACH_PADDING + 0.1:
				failures.append("%s melee can read as hitting too far: stop %.1f reach %.1f." % [hero_id, stop, reach])
			if BattleSimScript.OPPONENT_MIN_SPACING > reach - 2.0:
				failures.append("%s melee spacing can push units out of reach: spacing %.1f reach %.1f." % [hero_id, BattleSimScript.OPPONENT_MIN_SPACING, reach])
		else:
			if reach < 590.0 or reach > 650.0:
				failures.append("%s ranged reach should stay in the firing band, got %.1f." % [hero_id, reach])

	var gate_sim := BattleSimScript.new()
	var melee := gate_sim._unit("p1", "player", "A04_VANARA_KALAVANARA", Vector2(570, 326), Vector2(560, 360), 120, 40, 10, 46.0, 1.0, 86.0)
	var enemy := gate_sim._unit("e1", "enemy", "A02_TIGER_PLOENGPAYAK", Vector2(650, 360), Vector2(735, 360), 120, 10, 8, 46.0, 1.0, 86.0)
	melee["attack_timer"] = 0.0
	enemy["attack_timer"] = 99.0
	gate_sim.units = [melee, enemy]
	gate_sim.tick(0.1)
	if int(enemy["hp"]) < 120:
		failures.append("Melee attacked before entering reach: distance %.1f reach %.1f." % [
			(melee["position"] as Vector2).distance_to(enemy["position"] as Vector2),
			gate_sim._attack_reach(melee),
		])

func _validate_target_slot_reservation(failures: Array[String]) -> void:
	var sim := BattleSimScript.new()
	sim.units = [
		sim._unit("p1", "player", "S03_YAKSHA_KRAIASURA", Vector2(505, 330), Vector2(560, 300), 300, 8, 18, 46.0, 1.6, 78.0),
		sim._unit("p2", "player", "A04_VANARA_KALAVANARA", Vector2(500, 365), Vector2(560, 365), 260, 8, 10, 46.0, 1.4, 86.0),
		sim._unit("p3", "player", "S01_GARUDA_VAYUDEJ", Vector2(505, 400), Vector2(560, 430), 240, 8, 10, 56.0, 1.3, 92.0),
		sim._unit("e1", "enemy", "A02_TIGER_PLOENGPAYAK", Vector2(705, 365), Vector2(735, 365), 2200, 1, 8, 46.0, 99.0, 1.0),
	]
	for i in range(90):
		sim.tick(0.1)
	var ys: Array[float] = []
	var min_spacing := INF
	for unit in sim.units:
		if unit["team"] != "player" or not bool(unit["alive"]):
			continue
		ys.append(float((unit["position"] as Vector2).y))
		for other in sim.units:
			if other == unit or other["team"] != "player" or not bool(other["alive"]):
				continue
			min_spacing = minf(min_spacing, (unit["position"] as Vector2).distance_to(other["position"] as Vector2))
		if String(unit.get("target_id", "")) != "e1":
			failures.append("%s did not keep the shared target reservation." % unit["id"])
	if ys.size() == 3:
		ys.sort()
		var spread := ys[2] - ys[0]
		if spread < 74.0:
			failures.append("Melee target slots are too collapsed: y spread %.1f px." % spread)
	if min_spacing < 56.0:
		failures.append("Melee target slots overlap too tightly: %.1f px." % min_spacing)

func _validate_melee_walk_stability(failures: Array[String]) -> void:
	var sim := BattleSimScript.new()
	sim.units = [
		sim._unit("p1", "player", "S03_YAKSHA_KRAIASURA", Vector2(500, 330), Vector2(560, 300), 500, 8, 18, 46.0, 1.6, 78.0),
		sim._unit("p2", "player", "A04_VANARA_KALAVANARA", Vector2(500, 365), Vector2(560, 365), 500, 8, 10, 46.0, 1.4, 86.0),
		sim._unit("p3", "player", "S01_GARUDA_VAYUDEJ", Vector2(500, 400), Vector2(560, 430), 500, 8, 10, 56.0, 1.3, 92.0),
		sim._unit("e1", "enemy", "A02_TIGER_PLOENGPAYAK", Vector2(705, 365), Vector2(735, 365), 3200, 1, 8, 46.0, 99.0, 1.0),
	]
	var previous_positions := {}
	for unit in sim.units:
		previous_positions[String(unit["id"])] = unit["position"]
	var backward_samples := 0
	var max_backward_step := 0.0
	for i in range(140):
		sim.tick(0.05)
		for unit in sim.units:
			var unit_id := String(unit["id"])
			var previous: Vector2 = previous_positions[unit_id]
			var current: Vector2 = unit["position"]
			previous_positions[unit_id] = current
			if unit["team"] != "player" or not bool(unit["alive"]):
				continue
			var dx := current.x - previous.x
			if String(unit["state"]) == "walk" and dx < -0.2:
				backward_samples += 1
				max_backward_step = maxf(max_backward_step, absf(dx))
	if backward_samples > 2:
		failures.append("Melee walk has backward jitter samples: %d, max %.2f px." % [backward_samples, max_backward_step])

func _validate_idle_follow_does_not_fake_walk(failures: Array[String]) -> void:
	var unit_view := UnitViewScript.new()
	if not unit_view.has_method("display_state_for_sim_motion"):
		failures.append("UnitView needs display_state_for_sim_motion to keep idle smoothing from faking walk.")
		unit_view.free()
		return
	var display_state: String = unit_view.display_state_for_sim_motion("idle", Vector2(8, 0), true)
	if display_state != "idle":
		failures.append("UnitView promoted idle smoothing delta to %s animation." % display_state)
	display_state = unit_view.display_state_for_sim_motion("walk", Vector2(8, 0), true)
	if display_state != "walk":
		failures.append("UnitView should still show walk when sim state is walk, got %s." % display_state)
	unit_view.free()

func _validate_walk_playback_speed(failures: Array[String]) -> void:
	var normal_scale: float = UnitViewScript.walk_speed_scale_for(96.0)
	var fast_scale: float = UnitViewScript.walk_speed_scale_for(168.0)
	if normal_scale > 0.76:
		failures.append("Walk playback too fast at normal speed: %.2f." % normal_scale)
	if fast_scale > 0.95:
		failures.append("Walk playback cap too fast: %.2f." % fast_scale)

func _validate_attack_facing_contract(failures: Array[String]) -> void:
	if UnitViewScript.combat_readable_direction("skill_01", "east") != "south-east":
		failures.append("Skill east should use south-east on the horizontal battlefield to avoid back-facing attacks.")
	if UnitViewScript.combat_readable_direction_for("S01_GARUDA_VAYUDEJ", "skill_01", "east") != "east":
		failures.append("S01 skill east must stay on the true east row; south-east reads like a wrong-facing cast for this pilot.")
	if UnitViewScript.combat_readable_direction_for("S01_GARUDA_VAYUDEJ", "attack_01", "west") != "west":
		failures.append("S01 attack west must stay on the true west row for one-character pilot QC.")
	if UnitViewScript.combat_readable_direction("attack_01", "west") != "south-west":
		failures.append("Attack west should use south-west on the horizontal battlefield to avoid back-facing attacks.")
	if UnitViewScript.combat_readable_direction("walk", "east") != "east":
		failures.append("Walk direction should not be remapped by combat-facing polish.")
	var sim := BattleSimScript.new()
	var attacker := sim._unit("p1", "player", "S01_GARUDA_VAYUDEJ", Vector2(590, 360), Vector2(560, 360), 120, 20, 8, 56.0, 1.0, 92.0)
	var target := sim._unit("e1", "enemy", "A02_TIGER_PLOENGPAYAK", Vector2(650, 360), Vector2(735, 360), 120, 10, 8, 46.0, 1.0, 86.0)
	attacker["direction"] = "west"
	sim._attack(attacker, target)
	if String(attacker["direction"]) != "east":
		failures.append("BattleSim attack must face target at attack frame, got %s." % attacker["direction"])

func _validate_victory_pose_contract(failures: Array[String]) -> void:
	var unit := UnitViewScript.new()
	if not unit.has_method("play_victory"):
		failures.append("UnitView must expose play_victory for win action playback.")
	if UnitViewScript.VICTORY_MOTION_SECONDS < 1.0:
		failures.append("Victory pose is too short to read: %.2f seconds." % UnitViewScript.VICTORY_MOTION_SECONDS)
	unit.free()

func _validate_hit_reaction_contract(failures: Array[String]) -> void:
	var unit := UnitViewScript.new()
	if not unit.has_method("play_hit_reaction"):
		failures.append("UnitView must expose play_hit_reaction so VFX impacts connect to targets.")
	if UnitViewScript.SKILL_HIT_REACTION_SECONDS < 0.24:
		failures.append("Skill hit reaction is too short to read: %.2f seconds." % UnitViewScript.SKILL_HIT_REACTION_SECONDS)
	unit.free()

func _run_demo() -> Dictionary:
	var sim := BattleSimScript.new()
	sim.setup_demo()
	for i in range(600):
		sim.tick(0.1)
		if sim.result != "running":
			break

	var hp_parts: Array[String] = []
	for unit in sim.units:
		hp_parts.append("%s:%d" % [unit["id"], unit["hp"]])
	return {
		"result": sim.result,
		"signature": ",".join(hp_parts),
	}
