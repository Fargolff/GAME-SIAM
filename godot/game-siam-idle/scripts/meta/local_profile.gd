class_name LocalProfile
extends RefCounted

const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")
const HeroCatalogScript := preload("res://scripts/content/hero_catalog.gd")

const PROFILE_VERSION := 2
const SAVE_PATH := "user://profile.json"
const OFFLINE_CAP_SECONDS := 8 * 60 * 60

static func default_data(now: int = 0) -> Dictionary:
	var formation: Array = BattleSimScript.default_formation()
	var heroes := {}
	for roster_value in HeroCatalogScript.HERO_IDS:
		var hero_id: String = String(roster_value)
		heroes[hero_id] = {
			"level": 1,
			"stars": 1,
			"shards": 0,
			"unlocked": formation.has(hero_id),
		}
	return {
		"version": PROFILE_VERSION,
		"language": "th",
		"sound_enabled": true,
		"gold": 0,
		"essence": 0,
		"shards": 0,
		"highest_cleared": 0,
		"current_wave": 1,
		"formation": formation,
		"heroes": heroes,
		"analytics_flags": {},
		"last_seen": now,
	}

static func load_profile(path: String = SAVE_PATH, now: int = 0) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return default_data(now)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return default_data(now)
	return _normalize(parsed as Dictionary, now)

static func save_profile(profile: Dictionary, path: String = SAVE_PATH) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write profile: %s" % path)
		return
	file.store_string(JSON.stringify(profile, "\t"))

static func claim_offline_reward(profile: Dictionary, now: int) -> Dictionary:
	var last_seen: int = int(profile.get("last_seen", now))
	var seconds: int = clampi(now - last_seen, 0, OFFLINE_CAP_SECONDS)
	var highest: int = int(profile.get("highest_cleared", 0))
	var gold_gain: int = int(seconds / 60) * highest * 2
	var essence_gain: int = int(seconds / 900) * highest
	profile["gold"] = int(profile.get("gold", 0)) + gold_gain
	profile["essence"] = int(profile.get("essence", 0)) + essence_gain
	profile["last_seen"] = max(last_seen, now)
	return {
		"seconds": seconds,
		"gold": gold_gain,
		"essence": essence_gain,
	}

static func clear_wave(profile: Dictionary, wave_id: int, now: int) -> Dictionary:
	var highest: int = int(profile.get("highest_cleared", 0))
	if wave_id <= highest:
		profile["last_seen"] = now
		return {"gold": 0, "essence": 0, "shards": 0}
	var reward: Dictionary = BattleSimScript.reward_for_wave(wave_id)
	profile["gold"] = int(profile.get("gold", 0)) + int(reward["gold"])
	profile["essence"] = int(profile.get("essence", 0)) + int(reward["essence"])
	profile["shards"] = int(profile.get("shards", 0)) + int(reward["shards"])
	profile["highest_cleared"] = wave_id
	profile["current_wave"] = mini(wave_id + 1, BattleSimScript.MAX_WAVE)
	profile["last_seen"] = now
	return reward

static func upgrade_team(profile: Dictionary, now: int) -> bool:
	var level: int = team_level(profile)
	var cost: int = BattleSimScript.upgrade_cost(level)
	if int(profile.get("gold", 0)) < cost:
		return false
	profile["gold"] = int(profile.get("gold", 0)) - cost
	var formation: Array = profile.get("formation", BattleSimScript.default_formation()) as Array
	var heroes: Dictionary = profile.get("heroes", {}) as Dictionary
	for value in formation:
		var hero_id: String = String(value)
		var hero_data: Dictionary = heroes.get(hero_id, {}) as Dictionary
		hero_data["level"] = level + 1
		hero_data["unlocked"] = true
		heroes[hero_id] = hero_data
	profile["heroes"] = heroes
	profile["last_seen"] = now
	return true

static func team_level(profile: Dictionary) -> int:
	var formation: Array = profile.get("formation", BattleSimScript.default_formation()) as Array
	var heroes: Dictionary = profile.get("heroes", {}) as Dictionary
	var level: int = 999
	for value in formation:
		var hero_id: String = String(value)
		var hero_data: Dictionary = heroes.get(hero_id, {"level": 1}) as Dictionary
		level = mini(level, int(hero_data.get("level", 1)))
	return 1 if level == 999 else level

static func hero_levels(profile: Dictionary) -> Dictionary:
	var levels := {}
	var heroes: Dictionary = profile.get("heroes", {}) as Dictionary
	for key in heroes.keys():
		var hero_id: String = String(key)
		var hero_data: Dictionary = heroes.get(hero_id, {"level": 1}) as Dictionary
		levels[hero_id] = int(hero_data.get("level", 1))
	return levels

static func _normalize(profile: Dictionary, now: int) -> Dictionary:
	if int(profile.get("version", 0)) < PROFILE_VERSION:
		return default_data(now)
	var data: Dictionary = default_data(now)
	for key in profile.keys():
		if key == "heroes" and typeof(profile[key]) == TYPE_DICTIONARY:
			var heroes: Dictionary = data["heroes"] as Dictionary
			var stored_heroes: Dictionary = profile[key] as Dictionary
			for hero_id in stored_heroes.keys():
				if heroes.has(hero_id):
					heroes[hero_id] = stored_heroes[hero_id]
			data["heroes"] = heroes
		else:
			data[key] = profile[key]
	return data
