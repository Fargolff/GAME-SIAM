class_name HeroCatalog
extends RefCounted

const MAX_CAMPAIGN_WAVE := 100

const HERO_IDS := [
	"S01_GARUDA_VAYUDEJ",
	"S02_NAGA_SASINAKA",
	"S03_YAKSHA_KRAIASURA",
	"A01_KINNARI_PIMPPRUEKSA",
	"A02_TIGER_PLOENGPAYAK",
	"A03_HUMAN_ARUNRAT",
	"A04_VANARA_KALAVANARA",
	"A05_MAKARA_MAKORNKRAM",
	"A06_SPIRIT_RAMPAN_MASK",
	"A07_HUMAN_CHANGJAKKAEW",
	"B01_GARUDA_MEKHAVI",
	"B02_NAGA_KLEDKRAM",
	"B03_YAKSHA_KHUNPHA",
	"B04_HUMAN_DARIN",
	"B05_KINNARA_RAVIKAN",
	"B06_BEAST_SINGKHON",
	"B07_DRYAD_BUTSABA",
	"B08_HUMAN_MUENMONTRA",
	"B09_SPIRIT_AMBERNIGHT",
	"B10_MERFOLK_MUKWAREE",
	"C01_HUMAN_JETSIAM",
	"C02_KHACHASIH_LOHDIN",
	"C03_HUMAN_PANA",
	"C04_HUMAN_CHABA",
	"C05_VANARA_JORJAN",
	"C06_NAGA_NILNATEE",
	"C07_GARUDA_PEEKTHONG",
	"C08_CROCODILE_KUMPHIL",
	"C09_KINNARI_KAEWKANGSADAN",
	"C10_SPIRIT_KHOMKHAM",
	"D01_HUMAN_PHAIKLA",
	"D02_HUMAN_KHAMPAN",
	"D03_HUMAN_PRANNOI",
	"D04_HUMAN_TAEMTHONG",
	"D05_VANARA_JUKJIK",
	"D06_NAGA_BUABUCHA",
	"D07_GARUDA_LOMPEEK",
	"D08_HUMAN_THIWA",
	"D09_CONSTRUCT_SILADIN",
	"D10_SPIRIT_OUNRUEN",
]

const DEFAULT_FORMATION := [
	"S03_YAKSHA_KRAIASURA",
	"S01_GARUDA_VAYUDEJ",
	"S02_NAGA_SASINAKA",
	"A02_TIGER_PLOENGPAYAK",
	"A03_HUMAN_ARUNRAT",
]

const ARCHETYPES := [
	"vanguard",
	"guardian",
	"ranger",
	"skirmisher",
	"control_mage",
	"support",
	"debuffer",
	"summoner",
]

const SKILL_TEMPLATES := [
	"single_target_burst",
	"cleave",
	"aoe_pulse",
	"taunt",
	"shield_heal",
	"slow_root",
	"debuff_attack",
	"summon_lite_visual",
]

const ARCHETYPE_STATS := {
	"vanguard": {"hp": 340, "attack": 34, "defense": 16, "range": 46.0, "cooldown": 1.25, "move_speed": 86.0},
	"guardian": {"hp": 430, "attack": 27, "defense": 24, "range": 46.0, "cooldown": 1.45, "move_speed": 78.0},
	"ranger": {"hp": 235, "attack": 40, "defense": 8, "range": 165.0, "cooldown": 1.45, "move_speed": 72.0},
	"skirmisher": {"hp": 290, "attack": 39, "defense": 11, "range": 56.0, "cooldown": 1.05, "move_speed": 104.0},
	"control_mage": {"hp": 250, "attack": 37, "defense": 9, "range": 150.0, "cooldown": 1.65, "move_speed": 68.0},
	"support": {"hp": 270, "attack": 30, "defense": 12, "range": 140.0, "cooldown": 1.55, "move_speed": 70.0},
	"debuffer": {"hp": 260, "attack": 32, "defense": 10, "range": 135.0, "cooldown": 1.45, "move_speed": 76.0},
	"summoner": {"hp": 280, "attack": 31, "defense": 13, "range": 125.0, "cooldown": 1.7, "move_speed": 66.0},
}

const RARITY_MULTIPLIER := {
	"S": 1.18,
	"A": 1.08,
	"B": 1.0,
	"C": 0.94,
	"D": 0.88,
}

const HERO_ARCHETYPES := {
	"S01_GARUDA_VAYUDEJ": "skirmisher",
	"S02_NAGA_SASINAKA": "control_mage",
	"S03_YAKSHA_KRAIASURA": "guardian",
	"A01_KINNARI_PIMPPRUEKSA": "support",
	"A02_TIGER_PLOENGPAYAK": "skirmisher",
	"A03_HUMAN_ARUNRAT": "ranger",
	"A04_VANARA_KALAVANARA": "vanguard",
	"A05_MAKARA_MAKORNKRAM": "guardian",
	"A06_SPIRIT_RAMPAN_MASK": "debuffer",
	"A07_HUMAN_CHANGJAKKAEW": "support",
	"B01_GARUDA_MEKHAVI": "ranger",
	"B02_NAGA_KLEDKRAM": "control_mage",
	"B03_YAKSHA_KHUNPHA": "vanguard",
	"B04_HUMAN_DARIN": "skirmisher",
	"B05_KINNARA_RAVIKAN": "support",
	"B06_BEAST_SINGKHON": "guardian",
	"B07_DRYAD_BUTSABA": "summoner",
	"B08_HUMAN_MUENMONTRA": "debuffer",
	"B09_SPIRIT_AMBERNIGHT": "control_mage",
	"B10_MERFOLK_MUKWAREE": "support",
	"C01_HUMAN_JETSIAM": "vanguard",
	"C02_KHACHASIH_LOHDIN": "guardian",
	"C03_HUMAN_PANA": "ranger",
	"C04_HUMAN_CHABA": "support",
	"C05_VANARA_JORJAN": "skirmisher",
	"C06_NAGA_NILNATEE": "control_mage",
	"C07_GARUDA_PEEKTHONG": "ranger",
	"C08_CROCODILE_KUMPHIL": "guardian",
	"C09_KINNARI_KAEWKANGSADAN": "support",
	"C10_SPIRIT_KHOMKHAM": "debuffer",
	"D01_HUMAN_PHAIKLA": "vanguard",
	"D02_HUMAN_KHAMPAN": "guardian",
	"D03_HUMAN_PRANNOI": "ranger",
	"D04_HUMAN_TAEMTHONG": "support",
	"D05_VANARA_JUKJIK": "skirmisher",
	"D06_NAGA_BUABUCHA": "control_mage",
	"D07_GARUDA_LOMPEEK": "ranger",
	"D08_HUMAN_THIWA": "debuffer",
	"D09_CONSTRUCT_SILADIN": "summoner",
	"D10_SPIRIT_OUNRUEN": "support",
}

const HERO_SKILLS := {
	"S01_GARUDA_VAYUDEJ": "single_target_burst",
	"S02_NAGA_SASINAKA": "aoe_pulse",
	"S03_YAKSHA_KRAIASURA": "taunt",
	"A01_KINNARI_PIMPPRUEKSA": "shield_heal",
	"A02_TIGER_PLOENGPAYAK": "cleave",
	"A03_HUMAN_ARUNRAT": "single_target_burst",
	"A04_VANARA_KALAVANARA": "cleave",
	"A05_MAKARA_MAKORNKRAM": "taunt",
	"A06_SPIRIT_RAMPAN_MASK": "slow_root",
	"A07_HUMAN_CHANGJAKKAEW": "shield_heal",
	"B01_GARUDA_MEKHAVI": "single_target_burst",
	"B02_NAGA_KLEDKRAM": "slow_root",
	"B03_YAKSHA_KHUNPHA": "cleave",
	"B04_HUMAN_DARIN": "debuff_attack",
	"B05_KINNARA_RAVIKAN": "shield_heal",
	"B06_BEAST_SINGKHON": "taunt",
	"B07_DRYAD_BUTSABA": "summon_lite_visual",
	"B08_HUMAN_MUENMONTRA": "debuff_attack",
	"B09_SPIRIT_AMBERNIGHT": "aoe_pulse",
	"B10_MERFOLK_MUKWAREE": "shield_heal",
	"C01_HUMAN_JETSIAM": "single_target_burst",
	"C02_KHACHASIH_LOHDIN": "taunt",
	"C03_HUMAN_PANA": "single_target_burst",
	"C04_HUMAN_CHABA": "shield_heal",
	"C05_VANARA_JORJAN": "cleave",
	"C06_NAGA_NILNATEE": "slow_root",
	"C07_GARUDA_PEEKTHONG": "single_target_burst",
	"C08_CROCODILE_KUMPHIL": "taunt",
	"C09_KINNARI_KAEWKANGSADAN": "shield_heal",
	"C10_SPIRIT_KHOMKHAM": "debuff_attack",
	"D01_HUMAN_PHAIKLA": "single_target_burst",
	"D02_HUMAN_KHAMPAN": "taunt",
	"D03_HUMAN_PRANNOI": "single_target_burst",
	"D04_HUMAN_TAEMTHONG": "shield_heal",
	"D05_VANARA_JUKJIK": "cleave",
	"D06_NAGA_BUABUCHA": "slow_root",
	"D07_GARUDA_LOMPEEK": "single_target_burst",
	"D08_HUMAN_THIWA": "debuff_attack",
	"D09_CONSTRUCT_SILADIN": "summon_lite_visual",
	"D10_SPIRIT_OUNRUEN": "shield_heal",
}

const HERO_SKILL_NAMES := {
	"S01_GARUDA_VAYUDEJ": "VAYU TALON",
	"S02_NAGA_SASINAKA": "SASIN STORM",
	"S03_YAKSHA_KRAIASURA": "KRAI AEGIS",
	"A01_KINNARI_PIMPPRUEKSA": "PIMP GRACE",
	"A02_TIGER_PLOENGPAYAK": "PAYAK CUT",
	"A03_HUMAN_ARUNRAT": "ARUN ARROW",
	"A04_VANARA_KALAVANARA": "KALA CRASH",
	"A05_MAKARA_MAKORNKRAM": "MAKORN GUARD",
	"A06_SPIRIT_RAMPAN_MASK": "RAMPAN HEX",
	"A07_HUMAN_CHANGJAKKAEW": "CHANG LOTUS",
	"B01_GARUDA_MEKHAVI": "MEKHAVI SPEAR",
	"B02_NAGA_KLEDKRAM": "KLEDKRAM BIND",
	"B03_YAKSHA_KHUNPHA": "KHUNPHA CLEAVE",
	"B04_HUMAN_DARIN": "DARIN SEAL",
	"B05_KINNARA_RAVIKAN": "RAVIKAN SONG",
	"B06_BEAST_SINGKHON": "SINGKHON ROAR",
	"B07_DRYAD_BUTSABA": "BUTSABA CALL",
	"B08_HUMAN_MUENMONTRA": "MUEN HEX",
	"B09_SPIRIT_AMBERNIGHT": "AMBER PULSE",
	"B10_MERFOLK_MUKWAREE": "MUK GRACE",
	"C01_HUMAN_JETSIAM": "JETSIAM STRIKE",
	"C02_KHACHASIH_LOHDIN": "LOHDIN BULWARK",
	"C03_HUMAN_PANA": "PANA SHOT",
	"C04_HUMAN_CHABA": "CHABA BLOOM",
	"C05_VANARA_JORJAN": "JORJAN CUT",
	"C06_NAGA_NILNATEE": "NILNATEE BIND",
	"C07_GARUDA_PEEKTHONG": "PEEKTHONG DART",
	"C08_CROCODILE_KUMPHIL": "KUMPHIL AEGIS",
	"C09_KINNARI_KAEWKANGSADAN": "KAEW SONG",
	"C10_SPIRIT_KHOMKHAM": "KHOMKHAM SEAL",
	"D01_HUMAN_PHAIKLA": "PHAIKLA BLOW",
	"D02_HUMAN_KHAMPAN": "KHAMPAN GUARD",
	"D03_HUMAN_PRANNOI": "PRANNOI SHOT",
	"D04_HUMAN_TAEMTHONG": "TAEM GRACE",
	"D05_VANARA_JUKJIK": "JUKJIK CUT",
	"D06_NAGA_BUABUCHA": "BUABUCHA BIND",
	"D07_GARUDA_LOMPEEK": "LOMPEEK DART",
	"D08_HUMAN_THIWA": "THIWA SEAL",
	"D09_CONSTRUCT_SILADIN": "SILADIN CALL",
	"D10_SPIRIT_OUNRUEN": "OUNRUEN GRACE",
}

const ENEMY_FAMILIES := [
	"yaksha",
	"naga",
	"garuda",
	"beast",
	"spirit",
]

const ENEMY_FAMILY_MODIFIERS := {
	"yaksha": {"hp": 1.12, "attack": 1.0, "defense": 1.12},
	"naga": {"hp": 0.95, "attack": 1.08, "defense": 1.0},
	"garuda": {"hp": 0.9, "attack": 1.12, "defense": 0.92},
	"beast": {"hp": 1.05, "attack": 1.06, "defense": 0.98},
	"spirit": {"hp": 0.98, "attack": 1.02, "defense": 1.08},
}

const ENEMY_SKINS_BY_FAMILY := {
	"yaksha": ["S03_YAKSHA_KRAIASURA", "B03_YAKSHA_KHUNPHA", "D09_CONSTRUCT_SILADIN"],
	"naga": ["S02_NAGA_SASINAKA", "B02_NAGA_KLEDKRAM", "C06_NAGA_NILNATEE", "D06_NAGA_BUABUCHA"],
	"garuda": ["S01_GARUDA_VAYUDEJ", "B01_GARUDA_MEKHAVI", "C07_GARUDA_PEEKTHONG", "D07_GARUDA_LOMPEEK"],
	"beast": ["A02_TIGER_PLOENGPAYAK", "B06_BEAST_SINGKHON", "C02_KHACHASIH_LOHDIN", "C08_CROCODILE_KUMPHIL"],
	"spirit": ["A06_SPIRIT_RAMPAN_MASK", "B09_SPIRIT_AMBERNIGHT", "C10_SPIRIT_KHOMKHAM", "D10_SPIRIT_OUNRUEN"],
}

static func all_heroes() -> Array[String]:
	var ids: Array[String] = []
	for hero_id in HERO_IDS:
		ids.append(String(hero_id))
	return ids

static func has_hero(hero_id: String) -> bool:
	return HERO_IDS.has(hero_id)

static func rarity_for(hero_id: String) -> String:
	return hero_id.substr(0, 1)

static func archetype_for(hero_id: String) -> String:
	return String(HERO_ARCHETYPES.get(hero_id, "vanguard"))

static func skill_template_for(hero_id: String) -> String:
	return String(HERO_SKILLS.get(hero_id, "single_target_burst"))

static func skill_id_for(hero_id: String) -> String:
	var name := skill_name_for(hero_id).to_lower().replace(" ", "_")
	return "%s_%s" % [hero_id.to_lower(), name]

static func skill_name_for(hero_id: String) -> String:
	return String(HERO_SKILL_NAMES.get(hero_id, "%s BURST" % hero_id.substr(0, 3)))

static func skill_variant_index_for(hero_id: String) -> int:
	return max(0, HERO_IDS.find(hero_id))

static func base_stats_for(hero_id: String) -> Dictionary:
	var archetype := archetype_for(hero_id)
	var stats: Dictionary = (ARCHETYPE_STATS.get(archetype, ARCHETYPE_STATS["vanguard"]) as Dictionary).duplicate()
	var multiplier: float = float(RARITY_MULTIPLIER.get(rarity_for(hero_id), 1.0))
	stats["hp"] = int(round(float(stats["hp"]) * multiplier))
	stats["attack"] = int(round(float(stats["attack"]) * multiplier))
	stats["defense"] = int(round(float(stats["defense"]) * multiplier))
	return stats

static func campaign_wave(wave_id: int) -> Dictionary:
	var safe_wave: int = clampi(wave_id, 1, MAX_CAMPAIGN_WAVE)
	return {
		"wave_id": safe_wave,
		"boss": safe_wave % 10 == 0,
		"enemy_count": 3 if safe_wave < 10 else 4 if safe_wave < 20 else 5,
		"enemy_family": ENEMY_FAMILIES[int((safe_wave - 1) / 20) % ENEMY_FAMILIES.size()],
	}

static func enemy_skin_for_wave(wave_id: int, index: int) -> String:
	var wave := campaign_wave(wave_id)
	var family := String(wave["enemy_family"])
	var skins: Array = ENEMY_SKINS_BY_FAMILY.get(family, ENEMY_SKINS_BY_FAMILY["yaksha"]) as Array
	return String(skins[index % skins.size()])

static func enemy_family_modifier(wave_id: int) -> Dictionary:
	var wave := campaign_wave(wave_id)
	var family := String(wave["enemy_family"])
	return (ENEMY_FAMILY_MODIFIERS.get(family, ENEMY_FAMILY_MODIFIERS["yaksha"]) as Dictionary).duplicate()
