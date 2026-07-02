extends Node2D

const BattleSimScript := preload("res://scripts/combat/battle_sim.gd")
const DirectionResolverScript := preload("res://scripts/presentation/direction_resolver.gd")
const LocalProfileScript := preload("res://scripts/meta/local_profile.gd")
const GameStringsScript := preload("res://scripts/meta/strings.gd")
const HeroCatalogScript := preload("res://scripts/content/hero_catalog.gd")
const EconomyClientScript := preload("res://scripts/backend/economy_client.gd")
const PurchaseClientScript := preload("res://scripts/backend/purchase_client.gd")
const AnalyticsClientScript := preload("res://scripts/telemetry/analytics_client.gd")
const GameEnvironmentScript := preload("res://scripts/config/environment.gd")
const UnitScene := preload("res://scenes/battle/Unit.tscn")

const RUNNING_UI_REFRESH_INTERVAL_MSEC := 100

const ORNATE_BUTTON_FRAME := "res://assets/ui/generated/ornate_button_frame.png"
const ORNATE_HERO_CARD := "res://assets/ui/generated/ornate_hero_card.png"
const ORNATE_ACTION_BUTTON := "res://assets/ui/generated/ornate_action_button.png"
const HP_BAR_FRAME_IMAGEGEN := "res://assets/ui/generated/hp_bar_frame_imagegen_v37.png"
const CURRENCY_GOLD_ICON := "res://assets/ui/generated/currency_gold_icon.png"
const CURRENCY_ESSENCE_ICON := "res://assets/ui/generated/currency_essence_icon.png"
const CURRENCY_SHARD_ICON := "res://assets/ui/generated/currency_shard_icon.png"
const ACTION_AUTO_ICON := "res://assets/ui/generated/action_auto_swords_icon.png"
const ACTION_UPGRADE_ICON := "res://assets/ui/generated/action_upgrade_flame_icon.png"
const AUDIO_UI_CLICK := "res://assets/audio/ui_click.wav"
const AUDIO_HIT_SLASH := "res://assets/audio/hit_slash.wav"
const AUDIO_HIT_MAGIC := "res://assets/audio/hit_magic.wav"
const AUDIO_SKILL_CAST := "res://assets/audio/skill_cast.wav"
const AUDIO_SKILL_IMPACT := "res://assets/audio/skill_impact.wav"
const AUDIO_DEATH_BURST := "res://assets/audio/death_burst.wav"
const AUDIO_REWARD_CHIME := "res://assets/audio/reward_chime.wav"
const AUDIO_AMBIENCE := "res://assets/audio/ambience_temple_loop.wav"
const VFX_SKILL_CHARGE_HAND := "res://assets/vfx/generated/skill_charge_hand_v51.png"
const VFX_SKILL_RELEASE_FLASH := "res://assets/vfx/generated/skill_release_flash_v53.png"
const VFX_SKILL_PROJECTILE_TRAIL := "res://assets/vfx/generated/skill_projectile_trail_v52.png"
const VFX_SKILL_IMPACT_BURST_SHEET := "res://assets/vfx/generated/skill_impact_directional_hit_v52.png"
const VFX_SIGNATURE_GARUDA_WING := "res://assets/vfx/generated/skill_signature_garuda_wing_v59.png"
const VFX_SIGNATURE_NAGA_SPIRAL := "res://assets/vfx/generated/skill_signature_naga_spiral_v59.png"
const VFX_SIGNATURE_YAKSHA_STONE := "res://assets/vfx/generated/skill_signature_yaksha_stone_v59.png"
const VFX_SIGNATURE_KINNARI_BLOSSOM := "res://assets/vfx/generated/skill_signature_kinnari_blossom_v59.png"
const VFX_SIGNATURE_TIGER_CLAW := "res://assets/vfx/generated/skill_signature_tiger_claw_v59.png"
const VFX_SIGNATURE_HUMAN_ARROW_FAN := "res://assets/vfx/generated/skill_signature_human_arrow_fan_v59.png"
const VFX_SIGNATURE_SPIRIT_WISP := "res://assets/vfx/generated/skill_signature_spirit_wisp_v59.png"
const VFX_SIGNATURE_ARROW_TRAJECTORY := "res://assets/vfx/generated/skill_signature_arrow_trajectory_v62.png"
const VFX_SIGNATURE_NAGA_STORM := "res://assets/vfx/generated/skill_signature_naga_storm_v62.png"
const VFX_SIGNATURE_NAGA_BODY_STORM := "res://assets/vfx/generated/skill_signature_naga_body_storm_v72.png"
const VFX_SIGNATURE_AEGIS_SHIELD := "res://assets/vfx/generated/skill_signature_aegis_shield_v62.png"
const V88_REQUIRED_PERSONAL_VFX := [
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
const V89_REQUIRED_PERSONAL_VFX := [
	"A02_TIGER_PLOENGPAYAK",
	"D05_VANARA_JUKJIK",
	"S01_GARUDA_VAYUDEJ",
	"B01_GARUDA_MEKHAVI",
	"B05_KINNARA_RAVIKAN",
	"C07_GARUDA_PEEKTHONG",
	"D07_GARUDA_LOMPEEK",
	"A04_VANARA_KALAVANARA",
	"B03_YAKSHA_KHUNPHA",
	"D02_HUMAN_KHAMPAN",
	"D03_HUMAN_PRANNOI",
	"C01_HUMAN_JETSIAM",
]
const V90_REQUIRED_PERSONAL_VFX := [
	"C07_GARUDA_PEEKTHONG",
	"B01_GARUDA_MEKHAVI",
	"S01_GARUDA_VAYUDEJ",
	"D03_HUMAN_PRANNOI",
	"C01_HUMAN_JETSIAM",
	"B03_YAKSHA_KHUNPHA",
	"A04_VANARA_KALAVANARA",
	"A03_HUMAN_ARUNRAT",
]
const V91_REQUIRED_PERSONAL_VFX := [
	"S01_GARUDA_VAYUDEJ",
	"B03_YAKSHA_KHUNPHA",
	"A04_VANARA_KALAVANARA",
	"A03_HUMAN_ARUNRAT",
	"D03_HUMAN_PRANNOI",
]
const V92_REQUIRED_PERSONAL_VFX := [
	"A03_HUMAN_ARUNRAT",
	"D03_HUMAN_PRANNOI",
]
const V93_REQUIRED_PERSONAL_VFX := V88_REQUIRED_PERSONAL_VFX
const V97_REQUIRED_PERSONAL_VFX := [
	"A01_KINNARI_PIMPPRUEKSA",
	"A07_HUMAN_CHANGJAKKAEW",
	"B05_KINNARA_RAVIKAN",
	"B10_MERFOLK_MUKWAREE",
	"C04_HUMAN_CHABA",
	"S03_YAKSHA_KRAIASURA",
	"A05_MAKARA_MAKORNKRAM",
	"B06_BEAST_SINGKHON",
	"C02_KHACHASIH_LOHDIN",
	"B04_HUMAN_DARIN",
]
const V98_REQUIRED_PERSONAL_VFX := [
	"D10_SPIRIT_OUNRUEN",
	"A06_SPIRIT_RAMPAN_MASK",
	"B02_NAGA_KLEDKRAM",
	"D06_NAGA_BUABUCHA",
	"B08_HUMAN_MUENMONTRA",
	"C10_SPIRIT_KHOMKHAM",
	"B07_DRYAD_BUTSABA",
	"D09_CONSTRUCT_SILADIN",
	"C09_KINNARI_KAEWKANGSADAN",
	"D04_HUMAN_TAEMTHONG",
]
const V99_REQUIRED_PERSONAL_VFX := [
	"A06_SPIRIT_RAMPAN_MASK",
	"C10_SPIRIT_KHOMKHAM",
	"D04_HUMAN_TAEMTHONG",
]
const V100_REQUIRED_PERSONAL_VFX := [
	"A01_KINNARI_PIMPPRUEKSA",
	"B05_KINNARA_RAVIKAN",
	"C04_HUMAN_CHABA",
]
const V101_REQUIRED_PERSONAL_VFX := [
	"B05_KINNARA_RAVIKAN",
	"C04_HUMAN_CHABA",
]
const V102_REQUIRED_PERSONAL_VFX := [
	"C06_NAGA_NILNATEE",
	"D08_HUMAN_THIWA",
	"B09_SPIRIT_AMBERNIGHT",
	"C08_CROCODILE_KUMPHIL",
	"D02_HUMAN_KHAMPAN",
	"S02_NAGA_SASINAKA",
	"C03_HUMAN_PANA",
	"D07_GARUDA_LOMPEEK",
	"C05_VANARA_JORJAN",
	"D05_VANARA_JUKJIK",
]
const V103_REQUIRED_PERSONAL_VFX := [
	"S01_GARUDA_VAYUDEJ",
	"A02_TIGER_PLOENGPAYAK",
	"A03_HUMAN_ARUNRAT",
	"A04_VANARA_KALAVANARA",
	"B01_GARUDA_MEKHAVI",
	"B03_YAKSHA_KHUNPHA",
	"C01_HUMAN_JETSIAM",
	"C07_GARUDA_PEEKTHONG",
	"D01_HUMAN_PHAIKLA",
	"D03_HUMAN_PRANNOI",
]
const V104_REQUIRED_PERSONAL_VFX := [
	"S01_GARUDA_VAYUDEJ",
]
const PERSONAL_VFX_BY_HERO := {
	"S03_YAKSHA_KRAIASURA": "res://assets/vfx/generated/skill_personal_yaksha_stone_shield_smash_v97.png",
	"S01_GARUDA_VAYUDEJ": "res://assets/vfx/generated/skill_personal_vayudej_garuda_talon_v104.png",
	"S02_NAGA_SASINAKA": "res://assets/vfx/generated/skill_personal_sasinaka_royal_naga_storm_v102.png",
	"A02_TIGER_PLOENGPAYAK": "res://assets/vfx/generated/skill_personal_ploengpayak_tiger_flame_cut_v103.png",
	"A03_HUMAN_ARUNRAT": "res://assets/vfx/generated/skill_personal_arunrat_sun_arrow_spear_v103.png",
	"A01_KINNARI_PIMPPRUEKSA": "res://assets/vfx/generated/skill_personal_kinnari_lotus_feather_grace_v100.png",
	"A04_VANARA_KALAVANARA": "res://assets/vfx/generated/skill_personal_kalavanara_staff_sweep_v103.png",
	"A05_MAKARA_MAKORNKRAM": "res://assets/vfx/generated/skill_personal_makara_scale_guard_crash_v97.png",
	"A06_SPIRIT_RAMPAN_MASK": "res://assets/vfx/generated/skill_personal_rampan_spirit_mask_shatter_v99.png",
	"A07_HUMAN_CHANGJAKKAEW": "res://assets/vfx/generated/skill_personal_chang_charm_bead_shatter_v97.png",
	"B01_GARUDA_MEKHAVI": "res://assets/vfx/generated/skill_personal_mekhavi_wind_spear_v103.png",
	"B02_NAGA_KLEDKRAM": "res://assets/vfx/generated/skill_personal_kledkram_water_snare_coil_v98.png",
	"B03_YAKSHA_KHUNPHA": "res://assets/vfx/generated/skill_personal_khunpha_yaksha_axe_cleave_v103.png",
	"B04_HUMAN_DARIN": "res://assets/vfx/generated/skill_personal_darin_dagger_seal_cut_v97.png",
	"B05_KINNARA_RAVIKAN": "res://assets/vfx/generated/skill_personal_ravikan_music_wave_slash_v101.png",
	"B06_BEAST_SINGKHON": "res://assets/vfx/generated/skill_personal_singkhon_fang_roar_hit_v97.png",
	"B07_DRYAD_BUTSABA": "res://assets/vfx/generated/skill_personal_butsaba_thorn_eruption_v98.png",
	"B08_HUMAN_MUENMONTRA": "res://assets/vfx/generated/skill_personal_muen_mantra_paper_tear_v98.png",
	"B09_SPIRIT_AMBERNIGHT": "res://assets/vfx/generated/skill_personal_ambernight_amber_pulse_v102.png",
	"B10_MERFOLK_MUKWAREE": "res://assets/vfx/generated/skill_personal_mukwaree_pearl_splash_wave_v97.png",
	"C01_HUMAN_JETSIAM": "res://assets/vfx/generated/skill_personal_jetsiam_krabi_thrust_v103.png",
	"C02_KHACHASIH_LOHDIN": "res://assets/vfx/generated/skill_personal_lohdin_stone_bulwark_slam_v97.png",
	"C03_HUMAN_PANA": "res://assets/vfx/generated/skill_personal_pana_green_leaf_arrow_v102.png",
	"C04_HUMAN_CHABA": "res://assets/vfx/generated/skill_personal_chaba_hibiscus_petal_burst_v101.png",
	"C05_VANARA_JORJAN": "res://assets/vfx/generated/skill_personal_jorjan_monkey_blade_cleave_v102.png",
	"C06_NAGA_NILNATEE": "res://assets/vfx/generated/skill_personal_nilnatee_water_bind_v102.png",
	"C07_GARUDA_PEEKTHONG": "res://assets/vfx/generated/skill_personal_peekthong_peacock_darts_v103.png",
	"C08_CROCODILE_KUMPHIL": "res://assets/vfx/generated/skill_personal_kumphil_crocodile_aegis_v102.png",
	"C09_KINNARI_KAEWKANGSADAN": "res://assets/vfx/generated/skill_personal_kaew_crystal_chime_shards_v98.png",
	"C10_SPIRIT_KHOMKHAM": "res://assets/vfx/generated/skill_personal_khomkham_soul_flame_seal_v99.png",
	"D01_HUMAN_PHAIKLA": "res://assets/vfx/generated/skill_personal_phaikla_fist_shockwave_v103.png",
	"D02_HUMAN_KHAMPAN": "res://assets/vfx/generated/skill_personal_khampan_bronze_pot_guard_v102.png",
	"D03_HUMAN_PRANNOI": "res://assets/vfx/generated/skill_personal_prannoi_wood_bow_shot_v103.png",
	"D04_HUMAN_TAEMTHONG": "res://assets/vfx/generated/skill_personal_taem_gold_thread_cross_cut_v99.png",
	"D05_VANARA_JUKJIK": "res://assets/vfx/generated/skill_personal_jukjik_twin_claw_cut_v102.png",
	"D06_NAGA_BUABUCHA": "res://assets/vfx/generated/skill_personal_buabucha_lotus_root_bind_v98.png",
	"D07_GARUDA_LOMPEEK": "res://assets/vfx/generated/skill_personal_lompeek_wind_feather_dart_v102.png",
	"D08_HUMAN_THIWA": "res://assets/vfx/generated/skill_personal_thiwa_paper_curse_seal_v102.png",
	"D09_CONSTRUCT_SILADIN": "res://assets/vfx/generated/skill_personal_siladin_stone_fist_ground_slam_v98.png",
	"D10_SPIRIT_OUNRUEN": "res://assets/vfx/generated/skill_personal_ounruen_wispy_dash_strike_v98.png",
}
const UI_FONT_PATH := "res://assets/fonts/BaiJamjuree-SemiBold.ttf"
const UI_BOLD_FONT_PATH := "res://assets/fonts/BaiJamjuree-Bold.ttf"
const UI_TITLE_FONT_PATH := "res://assets/fonts/Cinzel-wght.ttf"
const FORMATION_CARD_LEFT := 154.0
const FORMATION_CARD_TOP := 594.0
const FORMATION_CARD_WIDTH := 184.0
const FORMATION_CARD_HEIGHT := 112.0
const FORMATION_CARD_GAP := 6.0
const FORMATION_HP_WIDTH := 70.0
const LANE_GUIDE_YS := [245.0, 305.0, 365.0, 425.0, 485.0]
const LANE_GUIDE_SEGMENTS := [
	Vector2(190.0, 1090.0),
]
const LANE_DASH_LENGTH := 16.0
const LANE_DASH_GAP := 42.0
const VICTORY_REWARD_DELAY := 1.10
const SKILL_CHARGE_HAND_FRAMES := 6
const SKILL_RELEASE_FLASH_FRAMES := 4
const SKILL_PROJECTILE_TRAIL_FRAMES := 6
const SKILL_IMPACT_BURST_FRAMES := 6
const PERSONAL_VFX_FRAMES := 6

@onready var units_root: Node2D = $Units
@onready var feedback_root: Node2D = $Feedback
@onready var lane_guides: Node2D = $LaneGuides
@onready var background: Sprite2D = $Background
@onready var formation_preview_root: Node2D = $FormationPreviews
@onready var hud_ornaments: Control = $HudOrnaments
@onready var formation_overlay: Control = $FormationOverlay
@onready var bottom_hud_band: ColorRect = $BottomHudBand
@onready var formation_bar: HBoxContainer = $FormationBar
@onready var wave_panel: Panel = $WavePanel
@onready var resource_panel: Panel = $ResourcePanel
@onready var reward_panel: Panel = $RewardPanel
@onready var target_marker: ColorRect = $TargetMarker
@onready var title: Label = $Title
@onready var title_subtitle: Label = $TitleSubtitle
@onready var result_label: Label = $ResultLabel
@onready var status_label: Label = $StatusLabel
@onready var wave_progress_bar: ProgressBar = $WaveProgressBar
@onready var gold_label: Label = $GoldLabel
@onready var reward_label: Label = $RewardLabel
@onready var speed_button: Button = $SpeedButton
@onready var start_button: Button = $StartButton
@onready var upgrade_button: Button = $UpgradeButton
@onready var next_wave_button: Button = $NextWaveButton
@onready var hint_label: Label = $HintLabel
@onready var gacha_button: Button = $GachaButton
@onready var settings_button: Button = $SettingsButton
@onready var gacha_panel: VBoxContainer = $GachaPanel
@onready var odds_label: Label = $GachaPanel/OddsLabel
@onready var pull_one_button: Button = $GachaPanel/PullOneButton
@onready var pull_ten_button: Button = $GachaPanel/PullTenButton
@onready var buy_button: Button = $GachaPanel/BuyButton
@onready var settings_panel: VBoxContainer = $SettingsPanel
@onready var english_button: Button = $SettingsPanel/LanguageRow/EnglishButton
@onready var thai_button: Button = $SettingsPanel/LanguageRow/ThaiButton
@onready var sound_button: Button = $SettingsPanel/SoundButton
@onready var restore_button: Button = $SettingsPanel/RestoreButton
@onready var support_button: Button = $SettingsPanel/SupportButton
@onready var feedback_button: Button = $SettingsPanel/FeedbackButton
@onready var delete_account_button: Button = $SettingsPanel/DeleteAccountButton
@onready var notifications_label: Label = $SettingsPanel/NotificationsLabel
@onready var formation_buttons := [
	$FormationBar/Slot1,
	$FormationBar/Slot2,
	$FormationBar/Slot3,
	$FormationBar/Slot4,
	$FormationBar/Slot5,
]

var sim: RefCounted
var views := {}
var formation := []
var hero_levels := {}
var current_wave := 1
var highest_cleared := 0
var gold := 0
var essence := 0
var shards := 0
var battle_speed := 1.0
var selected_slot := -1
var reward_claimed := false
var profile := {}
var profile_path := LocalProfileScript.SAVE_PATH
var language := "en"
var status_override := ""
var sound_enabled := true
var economy_client := EconomyClientScript.new()
var purchase_client := PurchaseClientScript.new()
var analytics_client := AnalyticsClientScript.new()
var battle_active := false
var last_hp := {}
var formation_preview_sprites := []
var formation_slot_labels := []
var formation_level_labels := []
var formation_role_labels := []
var formation_hp_tracks := []
var formation_hp_fills := []
var formation_hp_glints := []
var formation_hp_labels := []
var last_formation_preview_key := ""
var currency_value_labels := []
var ui_font: FontFile
var ui_bold_font: FontFile
var title_font: FontFile
var skill_test_autoplay := false
var skill_test_log_casts := false
var skill_test_log_path := ""
var skill_cooldown_seconds := 2.6
var skill_showcase_all := false
var skill_showcase_running := false
var skill_showcase_log_path := ""
var skill_showcase_frame_dir := ""
var skill_showcase_frame_index := 0
var capture_frame_dir := ""
var capture_frame_index := 0
var capture_frame_timer := 0.0
var next_running_ui_refresh_msec := 0
var playtest_loop_autoplay := false
var playtest_loop_auto_upgrade := false
var playtest_loop_cooldown := 1.0
var skill_cooldown := 0.0
var skill_caster_index := 0
var hitstop_timer := 0.0
var skill_focus_timer := 0.0
var audio_players := {}
var ambience_player: AudioStreamPlayer
var skill_cooldown_ring: Line2D
var vfx_textures := {}
var battlefield_shake_timer := 0.0
var battlefield_shake_duration := 0.0
var battlefield_shake_strength := 0.0
var background_origin := Vector2.ZERO
var lane_guides_origin := Vector2.ZERO
var units_origin := Vector2.ZERO
var feedback_origin := Vector2.ZERO
var pending_victory_reward := {}
var victory_reward_delay := 0.0

func _ready() -> void:
	_cache_battlefield_origins()
	_apply_safe_area()
	_apply_ui_theme()
	_build_lane_guides()
	_build_hud_ornaments()
	_build_currency_overlay()
	analytics_client.configure()
	var now: int = int(Time.get_unix_time_from_system())
	profile_path = OS.get_environment("GAME_SIAM_PROFILE_PATH").strip_edges()
	if profile_path == "":
		profile_path = LocalProfileScript.SAVE_PATH
	skill_test_autoplay = OS.get_environment("GAME_SIAM_AUTO_SKILL_TEST") == "1"
	skill_test_log_casts = OS.get_environment("GAME_SIAM_SKILL_TEST_LOG") == "1"
	skill_test_log_path = OS.get_environment("GAME_SIAM_SKILL_TEST_LOG_PATH")
	skill_cooldown_seconds = _env_float("GAME_SIAM_SKILL_TEST_COOLDOWN", 2.6)
	skill_showcase_all = OS.get_environment("GAME_SIAM_SKILL_SHOWCASE_ALL") == "1"
	skill_showcase_log_path = OS.get_environment("GAME_SIAM_SKILL_SHOWCASE_LOG_PATH")
	skill_showcase_frame_dir = OS.get_environment("GAME_SIAM_SKILL_SHOWCASE_FRAME_DIR")
	capture_frame_dir = OS.get_environment("GAME_SIAM_CAPTURE_FRAME_DIR")
	if capture_frame_dir.strip_edges() != "":
		DirAccess.make_dir_recursive_absolute(capture_frame_dir)
	playtest_loop_autoplay = OS.get_environment("GAME_SIAM_PLAYTEST_LOOP") == "1"
	playtest_loop_auto_upgrade = OS.get_environment("GAME_SIAM_PLAYTEST_AUTO_UPGRADE") == "1"
	profile = LocalProfileScript.load_profile(profile_path, now)
	language = String(profile.get("language", "en"))
	sound_enabled = false if skill_showcase_all else bool(profile.get("sound_enabled", true))
	if not skill_showcase_all:
		_setup_audio()
	_load_vfx_textures()
	if not skill_showcase_all:
		var offline_reward: Dictionary = LocalProfileScript.claim_offline_reward(profile, now)
		if int(offline_reward["gold"]) > 0 or int(offline_reward["essence"]) > 0:
			status_override = GameStringsScript.text("offline", language) % [offline_reward["gold"], offline_reward["essence"]]
			analytics_client.log_event("offline_claim", {
				"seconds": offline_reward["seconds"],
				"gold": offline_reward["gold"],
				"essence": offline_reward["essence"],
			})
		LocalProfileScript.save_profile(profile, profile_path)
	_apply_playtest_overrides()
	_load_from_profile()
	_build_formation_cards()
	if not skill_showcase_all:
		_log_once("tutorial_start", "tutorial_start")
	speed_button.pressed.connect(_toggle_speed)
	start_button.pressed.connect(_start_wave)
	upgrade_button.pressed.connect(_upgrade_team)
	next_wave_button.pressed.connect(_next_wave)
	gacha_button.pressed.connect(_toggle_gacha_panel)
	settings_button.pressed.connect(_toggle_settings_panel)
	pull_one_button.pressed.connect(_pull_gacha.bind(1))
	pull_ten_button.pressed.connect(_pull_gacha.bind(10))
	buy_button.pressed.connect(_buy_premium)
	english_button.pressed.connect(_set_language.bind("en"))
	thai_button.pressed.connect(_set_language.bind("th"))
	sound_button.pressed.connect(_toggle_sound)
	restore_button.pressed.connect(_restore_account)
	support_button.pressed.connect(_show_support)
	feedback_button.pressed.connect(_show_feedback)
	delete_account_button.pressed.connect(_request_account_deletion)
	var environment: Dictionary = GameEnvironmentScript.current()
	if not skill_showcase_all:
		economy_client.configure(String(environment["supabase_url"]), String(environment["supabase_anon_key"]))
	for i in range(formation_buttons.size()):
		formation_buttons[i].pressed.connect(_select_slot.bind(i))
	_prepare_wave()
	if skill_showcase_all:
		call_deferred("_start_skill_showcase_all")
	elif OS.get_environment("GAME_SIAM_AUTOSTART") == "1":
		call_deferred("_start_wave")
	var capture_quit_after := OS.get_environment("GAME_SIAM_CAPTURE_QUIT_AFTER").strip_edges()
	if capture_quit_after != "":
		call_deferred("_quit_after_capture_delay", maxf(1.0, float(capture_quit_after)))

func _quit_after_capture_delay(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	get_tree().quit()

func _capture_playtest_frame(delta: float) -> void:
	if capture_frame_dir.strip_edges() == "":
		return
	capture_frame_timer -= delta
	if capture_frame_timer > 0.0:
		return
	capture_frame_timer = 0.5
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		return
	image.save_png("%s/frame_%05d.png" % [capture_frame_dir, capture_frame_index])
	capture_frame_index += 1

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_restart_or_mark(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_restart_or_mark(event.position)

func _process(delta: float) -> void:
	_update_battlefield_shake(delta)
	_capture_playtest_frame(delta)
	if skill_showcase_running:
		skill_focus_timer = maxf(skill_focus_timer, 0.35)
		_update_skill_focus_readability()
		return
	if sim == null:
		return
	if not battle_active:
		skill_focus_timer = 0.0
		_update_skill_focus_readability()
		if not pending_victory_reward.is_empty():
			victory_reward_delay = maxf(0.0, victory_reward_delay - delta)
			if victory_reward_delay <= 0.0:
				_reveal_pending_victory_reward()
		if playtest_loop_autoplay and sim.result != "ready" and pending_victory_reward.is_empty():
			playtest_loop_cooldown -= delta
			if playtest_loop_cooldown <= 0.0:
				if playtest_loop_auto_upgrade:
					var cost := BattleSimScript.upgrade_cost(_team_level())
					if gold >= cost:
						_upgrade_team()
						return
				if sim.result == "players":
					_next_wave()
				else:
					_start_wave()
				return
		_refresh_ui()
		return
	skill_focus_timer = maxf(0.0, skill_focus_timer - delta)
	_update_skill_focus_readability()
	if hitstop_timer > 0.0:
		hitstop_timer = maxf(0.0, hitstop_timer - delta)
		_sync_views()
		_refresh_ui(false)
		return
	skill_cooldown = maxf(0.0, skill_cooldown - delta)
	sim.tick(delta * battle_speed)
	if skill_test_autoplay and skill_cooldown <= 0.0:
		_trigger_skill_test()
	_sync_views()
	if sim.result != "running" and not reward_claimed:
		_finish_wave()
	_refresh_ui(false)

func _set_target(position: Vector2) -> void:
	target_marker.visible = true
	target_marker.position = position - (target_marker.size * 0.5)

func _restart_or_mark(position: Vector2) -> void:
	_set_target(position)
	if sim == null or sim.result != "running":
		_play_sound("ui_click")
		_start_wave()

func _prepare_wave() -> void:
	_load_from_profile()
	for child in units_root.get_children():
		child.queue_free()
	for child in feedback_root.get_children():
		child.queue_free()
	views.clear()
	last_hp.clear()
	reward_panel.visible = false
	pending_victory_reward.clear()
	victory_reward_delay = 0.0
	next_running_ui_refresh_msec = 0
	sim = BattleSimScript.new()
	sim.setup_wave(current_wave, formation, hero_levels)
	sim.result = "ready"
	battle_active = false
	reward_claimed = true
	_sync_views()
	_refresh_ui()

func _start_wave() -> void:
	_load_from_profile()
	for child in units_root.get_children():
		child.queue_free()
	for child in feedback_root.get_children():
		child.queue_free()
	views.clear()
	last_hp.clear()
	reward_panel.visible = false
	pending_victory_reward.clear()
	victory_reward_delay = 0.0
	next_running_ui_refresh_msec = 0
	sim = BattleSimScript.new()
	sim.setup_wave(current_wave, formation, hero_levels)
	battle_active = true
	reward_claimed = false
	skill_cooldown = 0.25
	skill_caster_index = 0
	skill_focus_timer = 0.0
	playtest_loop_cooldown = 1.2
	reward_label.visible = false
	status_override = ""
	analytics_client.log_event("wave_start", {"wave_id": current_wave, "team_level": _team_level()})
	_log_once("first_battle_start", "first_battle_start", {"wave_id": current_wave})
	_sync_views()
	_refresh_ui()

func _sync_views() -> void:
	for unit in sim.units:
		var unit_id: String = unit["id"]
		var view: Node2D = views.get(unit_id)
		if view == null:
			view = UnitScene.instantiate()
			view.character_id = unit["character_id"]
			units_root.add_child(view)
			views[unit_id] = view
		view.set_team(String(unit["team"]))
		var previous_hp: int = int(last_hp.get(unit_id, int(unit["hp"])))
		var current_hp: int = int(unit["hp"])
		if current_hp < previous_hp:
			var visual_delay := float(unit.get("last_hit_visual_delay", 0.12))
			var hit_from: Vector2 = unit.get("last_hit_from_position", unit["position"])
			var attacker_id := String(unit.get("last_hit_attacker_id", ""))
			if view.has_method("play_hit_reaction"):
				view.play_hit_reaction(hit_from, false)
			if not _skill_focus_active():
				_show_normal_hit_vfx(hit_from, unit["position"], bool(unit.get("last_hit_is_ranged", false)), visual_delay, attacker_id)
				_show_damage_later(unit["position"], previous_hp - current_hp, false, visual_delay)
		last_hp[unit_id] = current_hp
		view.sync_from_sim(unit)

func _finish_wave() -> void:
	next_running_ui_refresh_msec = 0
	reward_claimed = true
	battle_active = false
	if sim.result != "players":
		analytics_client.log_event("wave_fail", {"wave_id": current_wave, "team_level": _team_level()})
		return
	var reward: Dictionary = LocalProfileScript.clear_wave(profile, current_wave, int(Time.get_unix_time_from_system()))
	analytics_client.log_event("wave_clear", {"wave_id": current_wave, "reward": reward})
	_log_once("first_battle_win", "first_battle_win", {"wave_id": current_wave})
	status_override = GameStringsScript.text("clear", language) % [reward["gold"], reward["essence"], reward["shards"]]
	reward_label.text = GameStringsScript.text("reward_line", language) % [reward["gold"], reward["essence"], reward["shards"]]
	reward_label.visible = false
	reward_panel.visible = false
	_show_victory_action()
	_queue_victory_reward(reward)
	LocalProfileScript.save_profile(profile, profile_path)
	highest_cleared = int(profile.get("highest_cleared", highest_cleared))
	gold = int(profile.get("gold", gold))
	essence = int(profile.get("essence", essence))
	shards = int(profile.get("shards", shards))
	hero_levels = LocalProfileScript.hero_levels(profile)

func _queue_victory_reward(reward: Dictionary) -> void:
	pending_victory_reward = reward.duplicate()
	victory_reward_delay = VICTORY_REWARD_DELAY

func _reveal_pending_victory_reward() -> void:
	if pending_victory_reward.is_empty():
		return
	pending_victory_reward.clear()
	victory_reward_delay = 0.0
	reward_label.visible = true
	reward_panel.visible = true
	_play_sound("reward")
	_show_reward_burst()

func _show_victory_action() -> void:
	var alive_index := 0
	for unit in sim.units:
		if String(unit["team"]) != "player" or not bool(unit["alive"]):
			continue
		var view = views.get(String(unit["id"]))
		if view != null and view.has_method("play_victory"):
			view.play_victory(alive_index)
		_add_ring_vfx((unit["position"] as Vector2) + Vector2(0.0, -30.0), 26.0, Color(1.0, 0.78, 0.28, 0.72))
		alive_index += 1
	_show_victory_banner()
	_kick_battlefield_shake(3.5, 0.18)

func _show_victory_banner() -> void:
	var banner := Label.new()
	banner.text = "VICTORY"
	banner.position = Vector2(468.0, 174.0)
	banner.size = Vector2(344.0, 62.0)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.z_index = 2300
	_apply_ui_font(banner, title_font)
	banner.add_theme_font_size_override("font_size", 38)
	banner.add_theme_color_override("font_color", Color(1.0, 0.82, 0.34, 1.0))
	banner.add_theme_color_override("font_outline_color", Color(0.05, 0.025, 0.0, 1.0))
	banner.add_theme_constant_override("outline_size", 5)
	feedback_root.add_child(banner)
	var tween := create_tween()
	tween.tween_property(banner, "scale", Vector2(1.08, 1.08), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.38)
	tween.tween_property(banner, "position", banner.position + Vector2(0.0, -22.0), 0.32)
	tween.parallel().tween_property(banner, "modulate:a", 0.0, 0.32)
	tween.tween_callback(banner.queue_free)

func _next_wave() -> void:
	if sim.result == "players" and current_wave < BattleSimScript.MAX_WAVE:
		var next_wave := int(profile.get("current_wave", current_wave + 1))
		if next_wave <= current_wave:
			next_wave = current_wave + 1
		current_wave = mini(next_wave, BattleSimScript.MAX_WAVE)
		profile["current_wave"] = current_wave
		LocalProfileScript.save_profile(profile, profile_path)
		_prepare_wave()

func _upgrade_team() -> void:
	if battle_active and sim != null and sim.result == "running":
		_trigger_skill_test()
		return
	_play_sound("ui_click")
	if LocalProfileScript.upgrade_team(profile, int(Time.get_unix_time_from_system())):
		_log_once("first_upgrade", "first_upgrade", {"team_level": LocalProfileScript.team_level(profile)})
		LocalProfileScript.save_profile(profile, profile_path)
		_start_wave()

func _trigger_skill_test() -> void:
	if sim == null or skill_cooldown > 0.0:
		return
	var players := []
	for unit in sim.units:
		if unit["team"] != "player" or not bool(unit["alive"]):
			continue
		players.append(unit)
	if players.is_empty():
		return
	var caster: Dictionary = players[skill_caster_index % players.size()]
	skill_caster_index += 1
	var primary := _nearest_enemy(caster)
	if primary.is_empty():
		return
	var caster_id := String(caster["character_id"])
	var skill_name := _skill_name(caster_id)
	var skill_profile := _skill_profile(caster_id)
	skill_cooldown = skill_cooldown_seconds
	# ponytail: short visual quiet window; upgrade to per-event VFX layers if we need simultaneous readable ultimates.
	skill_focus_timer = maxf(skill_focus_timer, float(skill_profile["delay"]) + 0.85)
	_clear_normal_combat_vfx()
	var stage_delay := _stage_skill_caster(caster, primary, skill_profile)
	if stage_delay > 0.0:
		await get_tree().create_timer(stage_delay).timeout
		if sim == null or not battle_active or sim.result != "running":
			return
		if not bool(caster.get("alive", false)):
			return
		if primary.is_empty() or not bool(primary.get("alive", false)):
			primary = _nearest_enemy(caster)
		if primary.is_empty():
			return
	if skill_test_log_casts and OS.is_debug_build():
		print("skill_test_cast\t%s\t%s\t%s\t%s" % [caster_id, String(skill_profile["skill_id"]), HeroCatalogScript.skill_template_for(caster_id), skill_name])
		_append_skill_test_log(caster_id, skill_name)
	var skill_to_target: Vector2 = primary["position"] - caster["position"]
	if skill_to_target.length_squared() > 0.0001:
		caster["direction"] = DirectionResolverScript.direction_for_vector(skill_to_target, String(caster.get("direction", "east")))
	caster["state"] = "skill_01"
	caster["forced_timer"] = 0.9
	caster["attack_timer"] = maxf(float(caster["attack_timer"]), 0.45)
	_show_skill_banner(skill_name, skill_profile)
	_show_skill_cast_vfx(caster["position"], skill_profile, primary["position"])
	_play_sound("skill_cast")
	hitstop_timer = 0.035
	await get_tree().create_timer(float(skill_profile["delay"])).timeout
	if sim == null or not battle_active or sim.result != "running":
		return
	if not bool(caster.get("alive", false)):
		return
	if primary.is_empty() or not bool(primary.get("alive", false)):
		primary = _nearest_enemy(caster)
	if primary.is_empty():
		return
	var skill_impact_delay := _show_skill_vfx(caster["position"], primary["position"], skill_profile)
	if skill_impact_delay > 0.0:
		await get_tree().create_timer(skill_impact_delay).timeout
		if sim == null or not battle_active or sim.result != "running":
			return
		if primary.is_empty() or not bool(primary.get("alive", false)):
			primary = _nearest_enemy(caster)
		if primary.is_empty():
			return
	_show_skill_impact_vfx(caster["position"], primary["position"], skill_profile)
	_play_sound("skill_impact")
	_kick_battlefield_shake(float(skill_profile["shake"]), 0.16)
	var affected := 0
	for target in sim.units:
		if target["team"] == caster["team"] or not bool(target["alive"]):
			continue
		if target["position"].distance_to(primary["position"]) > float(skill_profile["radius"]):
			continue
		var damage := maxi(int(skill_profile["min_damage"]), int(round(float(caster["attack"]) * float(skill_profile["damage_multiplier"]))) + int(skill_profile["flat_damage"]))
		target["hp"] = maxi(0, int(target["hp"]) - damage)
		target["state"] = "hurt"
		target["forced_timer"] = 0.34
		var target_view = views.get(String(target["id"]))
		if target_view != null and target_view.has_method("play_hit_reaction"):
			target_view.play_hit_reaction(caster["position"], true)
		var away: Vector2 = (target["position"] - caster["position"]).normalized()
		target["position"] = target["position"] + away * float(skill_profile["knockback"])
		var visible_damage_pops := 1 if int(skill_profile["max_targets"]) > 2 else 2
		if affected < visible_damage_pops:
			_show_damage_later(target["position"], damage, true, 0.34 + float(affected) * 0.065, affected)
		last_hp[String(target["id"])] = int(target["hp"])
		affected += 1
		if int(target["hp"]) <= 0:
			target["alive"] = false
			target["state"] = "death"
			target["forced_timer"] = 99.0
			_show_death_burst(target["position"])
			_kick_battlefield_shake(5.0, 0.12)
			_play_sound("death")
		if affected >= int(skill_profile["max_targets"]):
			break
	hitstop_timer = float(skill_profile["hitstop"])

func _stage_skill_caster(caster: Dictionary, primary: Dictionary, profile: Dictionary) -> float:
	var caster_id := String(caster.get("character_id", ""))
	if _hero_skill_is_ranged(caster_id, profile):
		return 0.0
	var caster_position: Vector2 = caster["position"]
	var target_position: Vector2 = primary["position"]
	var to_target := target_position - caster_position
	if to_target.length() <= 132.0:
		return 0.0
	var side := 1.0 if target_position.x >= caster_position.x else -1.0
	var desired := target_position + Vector2(-78.0 * side, clampf(float(caster.get("engage_position", caster_position).y) - target_position.y, -30.0, 30.0))
	desired.x = clampf(desired.x, BattleSimScript.ARENA_MIN.x, BattleSimScript.ARENA_MAX.x)
	desired.y = clampf(desired.y, BattleSimScript.ARENA_MIN.y, BattleSimScript.ARENA_MAX.y)
	if caster_position.distance_to(desired) <= 18.0:
		return 0.0
	caster["position"] = desired
	caster["velocity"] = (desired - caster_position) / 0.18
	caster["direction"] = DirectionResolverScript.direction_for_vector(desired - caster_position, String(caster.get("direction", "east")))
	caster["state"] = "walk"
	caster["forced_timer"] = 0.18
	_spawn_skill_travel_motes(caster_position + Vector2(0, -22), desired + Vector2(0, -22), profile["tint"], 0.18, "dash")
	return 0.18

func _hero_skill_is_ranged(hero_id: String, profile: Dictionary) -> bool:
	var signature := String(profile.get("signature", ""))
	if ["arrow", "spear", "dart", "shot"].has(signature):
		return true
	var stats := HeroCatalogScript.base_stats_for(hero_id)
	return float(stats.get("range", 46.0)) >= 120.0

func _toggle_speed() -> void:
	_play_sound("ui_click")
	battle_speed = 2.0 if battle_speed == 1.0 else 1.0
	_refresh_ui()

func _toggle_gacha_panel() -> void:
	_play_sound("ui_click")
	gacha_panel.visible = not gacha_panel.visible
	if gacha_panel.visible:
		settings_panel.visible = false
		analytics_client.log_event("gacha_view", {"wave_id": current_wave})

func _toggle_settings_panel() -> void:
	_play_sound("ui_click")
	settings_panel.visible = not settings_panel.visible
	if settings_panel.visible:
		gacha_panel.visible = false

func _set_language(next_language: String) -> void:
	_play_sound("ui_click")
	language = next_language
	profile["language"] = language
	LocalProfileScript.save_profile(profile, profile_path)
	_refresh_ui()

func _toggle_sound() -> void:
	sound_enabled = not sound_enabled
	if sound_enabled and ambience_player != null and not ambience_player.playing:
		ambience_player.play()
	elif not sound_enabled and ambience_player != null:
		ambience_player.stop()
	profile["sound_enabled"] = sound_enabled
	LocalProfileScript.save_profile(profile, profile_path)
	_refresh_ui()

func _restore_account() -> void:
	status_override = GameStringsScript.text("restore_pending", language)
	settings_panel.visible = false
	_refresh_ui()

func _show_support() -> void:
	status_override = GameStringsScript.text("support_pending", language)
	settings_panel.visible = false
	_refresh_ui()

func _show_feedback() -> void:
	var environment: Dictionary = GameEnvironmentScript.current()
	status_override = GameStringsScript.text("feedback_pending", language) % environment["feedback_url"]
	settings_panel.visible = false
	_refresh_ui()

func _request_account_deletion() -> void:
	status_override = GameStringsScript.text("account_deletion_pending", language)
	settings_panel.visible = false
	_refresh_ui()

func _select_slot(index: int) -> void:
	if selected_slot == -1:
		selected_slot = index
	elif selected_slot == index:
		selected_slot = -1
	else:
		var tmp = formation[selected_slot]
		formation[selected_slot] = formation[index]
		formation[index] = tmp
		selected_slot = -1
		profile["formation"] = formation
		LocalProfileScript.save_profile(profile, profile_path)
		_prepare_wave()
	_refresh_ui()

func _team_level() -> int:
	return LocalProfileScript.team_level(profile)

func _load_from_profile() -> void:
	formation = profile.get("formation", BattleSimScript.default_formation()) as Array
	hero_levels = LocalProfileScript.hero_levels(profile)
	current_wave = int(profile.get("current_wave", 1))
	highest_cleared = int(profile.get("highest_cleared", 0))
	gold = int(profile.get("gold", 0))
	essence = int(profile.get("essence", 0))
	shards = int(profile.get("shards", 0))
	sound_enabled = bool(profile.get("sound_enabled", true))

func _apply_playtest_overrides() -> void:
	var formation_env := OS.get_environment("GAME_SIAM_PLAYTEST_FORMATION").strip_edges()
	if formation_env != "":
		var next_formation := []
		for raw_id in formation_env.split(",", false):
			var hero_id := String(raw_id).strip_edges()
			if HeroCatalogScript.has_hero(hero_id):
				next_formation.append(hero_id)
		while next_formation.size() > 5:
			next_formation.pop_back()
		if not next_formation.is_empty():
			profile["formation"] = next_formation
			var level := maxi(1, int(OS.get_environment("GAME_SIAM_PLAYTEST_LEVEL")))
			var heroes: Dictionary = profile.get("heroes", {}) as Dictionary
			for hero_id in next_formation:
				var hero_data: Dictionary = heroes.get(hero_id, {}) as Dictionary
				hero_data["level"] = level
				hero_data["unlocked"] = true
				heroes[hero_id] = hero_data
			profile["heroes"] = heroes
	var wave_env := OS.get_environment("GAME_SIAM_PLAYTEST_WAVE").strip_edges()
	if wave_env != "":
		profile["current_wave"] = clampi(int(wave_env), 1, BattleSimScript.MAX_WAVE)

func _env_float(name: String, fallback: float) -> float:
	var value := OS.get_environment(name).strip_edges()
	if value == "":
		return fallback
	return maxf(0.35, float(value))

func _append_skill_test_log(hero_id: String, skill_name: String) -> void:
	if skill_test_log_path.strip_edges() == "":
		return
	var file := FileAccess.open(skill_test_log_path, FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open(skill_test_log_path, FileAccess.WRITE)
	if file == null:
		return
	file.seek_end()
	file.store_line("%s\t%s\t%s\t%s" % [hero_id, HeroCatalogScript.skill_id_for(hero_id), HeroCatalogScript.skill_template_for(hero_id), skill_name])

func _append_skill_showcase_log(index: int, hero_id: String, profile: Dictionary, ranged: bool, distance: float) -> void:
	if skill_showcase_log_path.strip_edges() == "":
		return
	var file := FileAccess.open(skill_showcase_log_path, FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open(skill_showcase_log_path, FileAccess.WRITE)
	if file == null:
		return
	file.seek_end()
	file.store_line("%02d\t%s\t%s\t%s\t%s\t%s\t%.1f" % [
		index + 1,
		hero_id,
		String(profile["skill_id"]),
		HeroCatalogScript.skill_template_for(hero_id),
		HeroCatalogScript.skill_name_for(hero_id),
		"ranged" if ranged else "melee",
		distance,
	])

func _start_skill_showcase_all() -> void:
	if skill_showcase_running:
		return
	skill_showcase_running = true
	battle_active = false
	skill_focus_timer = 999.0
	status_override = ""
	_hide_skill_showcase_ui()
	if skill_showcase_frame_dir.strip_edges() != "":
		DirAccess.make_dir_recursive_absolute(skill_showcase_frame_dir)
		skill_showcase_frame_index = 0
	for child in units_root.get_children():
		child.queue_free()
	for child in feedback_root.get_children():
		child.queue_free()
	views.clear()
	await get_tree().create_timer(0.20).timeout
	var heroes := _skill_showcase_heroes()
	var showcase_limit := heroes.size()
	var limit_env := OS.get_environment("GAME_SIAM_SKILL_SHOWCASE_LIMIT").strip_edges()
	if limit_env != "":
		showcase_limit = clampi(int(limit_env), 1, heroes.size())
	for index in range(showcase_limit):
		await _showcase_one_skill(index, String(heroes[index]))
	skill_showcase_running = false
	if OS.is_debug_build() and OS.get_environment("GAME_SIAM_SKILL_SHOWCASE_STDOUT") == "1":
		print("skill_showcase_complete\t%d" % showcase_limit)
	if OS.get_environment("GAME_SIAM_SKILL_SHOWCASE_QUIT") == "1":
		get_tree().quit()

func _skill_showcase_heroes() -> Array:
	var hero_filter := OS.get_environment("GAME_SIAM_SKILL_SHOWCASE_HEROES").strip_edges()
	if hero_filter == "":
		return HeroCatalogScript.all_heroes()
	var selected: Array[String] = []
	for raw_id in hero_filter.split(",", false):
		var hero_id := String(raw_id).strip_edges()
		if hero_id != "" and HeroCatalogScript.has_hero(hero_id):
			selected.append(hero_id)
	return selected if not selected.is_empty() else HeroCatalogScript.all_heroes()

func _hide_skill_showcase_ui() -> void:
	var hidden_nodes: Array[CanvasItem] = [
		hud_ornaments,
		formation_preview_root,
		formation_overlay,
		bottom_hud_band,
		formation_bar,
		wave_panel,
		resource_panel,
		reward_panel,
		target_marker,
		gacha_panel,
		settings_panel,
		gacha_button,
		settings_button,
		speed_button,
		start_button,
		upgrade_button,
		next_wave_button,
		gold_label,
		reward_label,
		hint_label,
		wave_progress_bar,
	]
	for node in hidden_nodes:
		if node != null:
			node.visible = false
	title.text = "GAME SIAM"
	title_subtitle.text = "SKILL QC"
	result_label.text = ""
	status_label.text = ""

func _showcase_one_skill(index: int, hero_id: String) -> void:
	for child in units_root.get_children():
		child.queue_free()
	for child in feedback_root.get_children():
		child.queue_free()
	var profile := _skill_profile(hero_id)
	var ranged := _hero_skill_is_ranged(hero_id, profile)
	var row := float(index % 5)
	var lane_y := 270.0 + row * 58.0
	var start_pos := Vector2(330.0, lane_y)
	var target_pos := Vector2(900.0, lane_y + (6.0 if index % 2 == 0 else -6.0)) if ranged else Vector2(675.0, lane_y)
	var cast_pos := start_pos if ranged else target_pos + Vector2(-88.0, 0.0)
	var target_id := "S03_YAKSHA_KRAIASURA" if hero_id != "S03_YAKSHA_KRAIASURA" else "A02_TIGER_PLOENGPAYAK"
	var caster := _spawn_showcase_unit(hero_id, start_pos, "player", "east")
	var target := _spawn_showcase_unit(target_id, target_pos, "enemy", "west")
	_append_skill_showcase_log(index, hero_id, profile, ranged, cast_pos.distance_to(target_pos))
	await _capture_skill_showcase_span(0.08)
	if not ranged:
		caster.play("walk", "east")
		var walk_time := clampf(start_pos.distance_to(cast_pos) / 760.0, 0.18, 0.34)
		var walk_tween := create_tween()
		walk_tween.tween_property(caster, "position", cast_pos.round(), walk_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await _capture_skill_showcase_span(walk_time)
		if walk_tween.is_running():
			await walk_tween.finished
	else:
		await _capture_skill_showcase_span(0.08)
	caster.play("skill_01", "east")
	_show_skill_cast_vfx(cast_pos, profile, target_pos)
	await _capture_skill_showcase_span(float(profile["delay"]) + 0.05)
	var travel_delay := _show_skill_vfx(cast_pos, target_pos, profile)
	if travel_delay > 0.0:
		await _capture_skill_showcase_span(travel_delay)
	_show_skill_impact_vfx(cast_pos, target_pos, profile)
	target.play_hit_reaction(cast_pos, true)
	target.play("hurt", "west")
	_show_skill_damage_number(target_pos + Vector2(0.0, -36.0), 900 + index * 7, index % 2)
	await _capture_skill_showcase_span(0.46)

func _spawn_showcase_unit(hero_id: String, unit_position: Vector2, team: String, facing: String) -> Node2D:
	var unit := UnitScene.instantiate()
	unit.character_id = hero_id
	units_root.add_child(unit)
	unit.position = unit_position.round()
	if unit.has_method("set_team"):
		unit.set_team(team)
	if unit.has_method("play"):
		unit.play("idle", facing)
	return unit

func _capture_skill_showcase_span(duration: float) -> void:
	if skill_showcase_frame_dir.strip_edges() == "":
		await get_tree().create_timer(duration).timeout
		return
	var frame_interval := 1.0 / 12.0
	var frames := maxi(1, int(ceil(duration / frame_interval)))
	for _frame in range(frames):
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		if image != null and not image.is_empty():
			var path := "%s/frame_%05d.png" % [skill_showcase_frame_dir, skill_showcase_frame_index]
			image.save_png(path)
			skill_showcase_frame_index += 1
		await get_tree().create_timer(frame_interval).timeout

func _refresh_ui(force_full := true) -> void:
	if not force_full and battle_active and sim != null and sim.result == "running":
		var now_msec := Time.get_ticks_msec()
		if now_msec < next_running_ui_refresh_msec:
			_update_skill_cooldown_ring()
			_update_skill_focus_readability()
			return
		next_running_ui_refresh_msec = now_msec + RUNNING_UI_REFRESH_INTERVAL_MSEC
	var level := _team_level()
	var cost := BattleSimScript.upgrade_cost(level)
	var reward_pending := not pending_victory_reward.is_empty()
	var goal_hint := _goal_hint_text(cost, reward_pending)
	var result_text := GameStringsScript.text(sim.result, language) if sim.result in ["ready", "players", "enemies", "running"] else String(sim.result)
	result_label.text = "WAVE  %d/%d" % [current_wave, BattleSimScript.MAX_WAVE]
	status_label.text = "%s  |  Team Lv %d" % [result_text, level]
	wave_progress_bar.value = float(current_wave) / float(BattleSimScript.MAX_WAVE) * 100.0
	_update_currency_overlay()
	odds_label.text = GameStringsScript.text("odds", language)
	gacha_button.text = GameStringsScript.text("gacha", language).to_upper()
	settings_button.text = GameStringsScript.text("settings", language).to_upper()
	speed_button.text = "%dX" % int(battle_speed)
	start_button.text = "\nAUTO"
	if battle_active and sim.result == "running":
		upgrade_button.text = _skill_button_text() if skill_cooldown <= 0.05 else "\nULT\n%d%%" % int(round((1.0 - clampf(skill_cooldown / skill_cooldown_seconds, 0.0, 1.0)) * 100.0))
		upgrade_button.disabled = skill_cooldown > 0.05
		upgrade_button.modulate = Color(1.0, 0.88 + sin(Time.get_ticks_msec() * 0.012) * 0.1, 0.5, 1.0) if skill_cooldown <= 0.05 else Color(0.72, 0.7, 0.62, 0.9)
	else:
		upgrade_button.text = "\n%s\n%d" % [GameStringsScript.text("upgrade", language), cost]
		upgrade_button.disabled = gold < cost
		upgrade_button.modulate = Color.WHITE
	next_wave_button.text = "%s\nWAVE" % GameStringsScript.text("next", language)
	next_wave_button.disabled = sim.result != "players" or current_wave >= BattleSimScript.MAX_WAVE or reward_pending
	next_wave_button.visible = sim.result == "players" and current_wave < BattleSimScript.MAX_WAVE and not reward_pending
	pull_one_button.text = GameStringsScript.text("pull_one", language)
	pull_ten_button.text = GameStringsScript.text("pull_ten", language)
	buy_button.text = GameStringsScript.text("buy_premium", language)
	english_button.text = GameStringsScript.text("english", language)
	thai_button.text = GameStringsScript.text("thai", language)
	sound_button.text = GameStringsScript.text("sound_on", language) if sound_enabled else GameStringsScript.text("sound_off", language)
	restore_button.text = GameStringsScript.text("restore", language)
	support_button.text = GameStringsScript.text("support", language)
	feedback_button.text = GameStringsScript.text("feedback", language)
	delete_account_button.text = GameStringsScript.text("delete_account", language)
	notifications_label.text = GameStringsScript.text("notifications_later", language)

	if sim.result == "ready":
		hint_label.visible = true
		reward_label.visible = false
		reward_panel.visible = false
		status_label.text = GameStringsScript.text("ready_status", language)
		hint_label.text = goal_hint
	elif sim.result == "players":
		hint_label.visible = true
		status_label.text = status_override
		hint_label.text = goal_hint
	elif sim.result == "enemies":
		hint_label.visible = true
		status_label.text = GameStringsScript.text("defeat", language)
		hint_label.text = goal_hint if gold >= cost else GameStringsScript.text("hint_loss", language)
	elif status_override != "":
		hint_label.visible = true
		status_label.text = status_override
		hint_label.text = goal_hint
	else:
		hint_label.visible = false
		status_label.text = GameStringsScript.text("running", language)
		hint_label.text = ""

	for i in range(formation_buttons.size()):
		formation_buttons[i].text = ""
	_update_skill_cooldown_ring()
	_sync_formation_cards(level)
	_update_skill_focus_readability()

func _goal_hint_text(cost: int, reward_pending: bool) -> String:
	if reward_pending:
		return GameStringsScript.text("goal_claim_reward", language)
	if gold >= cost and sim.result != "running":
		return GameStringsScript.text("goal_upgrade_ready", language)
	if current_wave <= 1 and highest_cleared < 1:
		return GameStringsScript.text("goal_clear_wave1", language)
	if current_wave < 5:
		return GameStringsScript.text("goal_reach_wave5", language)
	if current_wave < 10:
		return GameStringsScript.text("goal_reach_wave10", language)
	if current_wave == 10:
		return GameStringsScript.text("goal_boss_wave10", language)
	return GameStringsScript.text("hint_start" if sim.result == "ready" else "hint_win", language)

func _show_normal_hit_vfx(from_position: Vector2, target_position: Vector2, ranged: bool, delay: float, attacker_id := "") -> void:
	if _skill_focus_active():
		return
	var from_anchor := from_position + Vector2(0, -42)
	var to_anchor := target_position + Vector2(0, -46)
	var personal_key := _personal_vfx_key_for_hero(attacker_id)
	if personal_key != "":
		var travel := to_anchor - from_anchor
		var angle := travel.angle() if travel.length() > 0.0 else 0.0
		var hit_size := 38.0 if ranged else 36.0
		var is_priority_attacker := V102_REQUIRED_PERSONAL_VFX.has(String(attacker_id)) or V103_REQUIRED_PERSONAL_VFX.has(String(attacker_id)) or V104_REQUIRED_PERSONAL_VFX.has(String(attacker_id))
		if String(attacker_id) == "S03_YAKSHA_KRAIASURA":
			hit_size = 36.0
		elif String(attacker_id) == "S02_NAGA_SASINAKA":
			hit_size = 38.0
		elif String(attacker_id) == "B07_DRYAD_BUTSABA":
			hit_size = 50.0
		elif String(attacker_id) == "B08_HUMAN_MUENMONTRA":
			hit_size = 50.0
		if is_priority_attacker:
			hit_size = 50.0 if ranged else 46.0
		if ranged and travel.length() >= 8.0:
			var is_butsaba_thorn := String(attacker_id) == "B07_DRYAD_BUTSABA"
			var is_muen_hex := String(attacker_id) == "B08_HUMAN_MUENMONTRA"
			var start_ratio := 0.46 if is_muen_hex else (0.42 if is_butsaba_thorn else (0.46 if is_priority_attacker else 0.56))
			var start := from_anchor.lerp(to_anchor, start_ratio)
			var step_divisor := 6.0 if is_muen_hex else (6.1 if is_butsaba_thorn else (6.2 if is_priority_attacker else 7.5))
			var min_step := 0.036 if (is_priority_attacker or is_butsaba_thorn or is_muen_hex) else 0.028
			_spawn_vfx_sheet_animation(personal_key, start, PERSONAL_VFX_FRAMES, hit_size, 2112, maxf(delay / step_divisor, min_step), angle, Color.WHITE, to_anchor - start, false)
			return
		await get_tree().create_timer(maxf(delay * 0.45, 0.03)).timeout
		if not is_inside_tree() or _skill_focus_active():
			return
		_spawn_vfx_sheet_animation(personal_key, to_anchor, PERSONAL_VFX_FRAMES, hit_size, 2112, 0.036, angle, Color.WHITE, Vector2.ZERO, false)
		return
	if ranged:
		var travel := to_anchor - from_anchor
		if travel.length() < 4.0:
			return
		var shot := Line2D.new()
		shot.width = 3.0
		shot.default_color = Color(1.0, 0.84, 0.32, 0.92)
		shot.position = from_anchor
		shot.rotation = travel.angle()
		shot.points = PackedVector2Array([Vector2(-18, 0), Vector2(18, 0)])
		shot.z_index = 2110
		shot.add_to_group("normal_combat_vfx")
		feedback_root.add_child(shot)
		var tween := create_tween()
		tween.tween_property(shot, "position", to_anchor, maxf(delay - 0.035, 0.08))
		tween.parallel().tween_property(shot, "modulate:a", 0.35, maxf(delay - 0.035, 0.08))
		tween.tween_callback(shot.queue_free)
		return
	await get_tree().create_timer(maxf(delay * 0.45, 0.03)).timeout
	if not is_inside_tree() or _skill_focus_active():
		return
	var slash := Line2D.new()
	slash.width = 4.0
	slash.default_color = Color(1.0, 0.62, 0.22, 0.82)
	slash.position = to_anchor
	slash.rotation = -0.55
	slash.points = PackedVector2Array([Vector2(-28, 12), Vector2(28, -12)])
	slash.z_index = 2112
	slash.add_to_group("normal_combat_vfx")
	feedback_root.add_child(slash)
	var echo := Line2D.new()
	echo.width = 2.0
	echo.default_color = Color(1.0, 0.92, 0.58, 0.68)
	echo.position = to_anchor + Vector2(0, 6)
	echo.rotation = 0.45
	echo.points = PackedVector2Array([Vector2(-18, -9), Vector2(18, 9)])
	echo.z_index = 2113
	echo.add_to_group("normal_combat_vfx")
	feedback_root.add_child(echo)
	_fade_free(slash, 0.18)
	_fade_free(echo, 0.16)

func _show_damage_later(position: Vector2, amount: int, special: bool, delay: float, pop_index := 0) -> void:
	await get_tree().create_timer(maxf(delay, 0.0)).timeout
	if not is_inside_tree():
		return
	if not special and _skill_focus_active():
		return
	_show_damage(position, amount, special, pop_index)

func _skill_focus_active() -> bool:
	return skill_focus_timer > 0.0

func _clear_normal_combat_vfx() -> void:
	for node in get_tree().get_nodes_in_group("normal_combat_vfx"):
		if is_instance_valid(node):
			node.queue_free()

func _update_skill_focus_readability() -> void:
	for view in views.values():
		if is_instance_valid(view) and view.has_method("set_focus_hp_alpha"):
			var hp_alpha := 1.0
			if _skill_focus_active():
				hp_alpha = 0.14 if String(view.get("team")) == "enemy" else 0.28
			view.set_focus_hp_alpha(hp_alpha)
	var focus_alpha := 1.0
	if _skill_focus_active():
		focus_alpha = 0.48
	_set_canvas_alpha(bottom_hud_band, 0.58 if _skill_focus_active() else 1.0)
	_set_canvas_alpha(formation_bar, focus_alpha)
	_set_canvas_alpha(formation_overlay, focus_alpha)
	_set_canvas_alpha(formation_preview_root, 0.54 if _skill_focus_active() else 1.0)
	_set_canvas_alpha(start_button, 0.42 if _skill_focus_active() else 1.0)
	_set_canvas_alpha(upgrade_button, 0.62 if _skill_focus_active() else 1.0)
	_set_canvas_alpha(next_wave_button, 0.48 if _skill_focus_active() else 1.0)
	_set_canvas_alpha(hint_label, 0.38 if _skill_focus_active() else 1.0)
	_set_canvas_alpha(gacha_button, 0.72 if _skill_focus_active() else 1.0)
	_set_canvas_alpha(settings_button, 0.72 if _skill_focus_active() else 1.0)
	_set_canvas_alpha(speed_button, 0.72 if _skill_focus_active() else 1.0)
	_set_canvas_alpha(resource_panel, 0.78 if _skill_focus_active() else 1.0)
	_set_canvas_alpha(gold_label, 0.78 if _skill_focus_active() else 1.0)

func _set_canvas_alpha(item: CanvasItem, alpha: float) -> void:
	if not is_instance_valid(item):
		return
	var color := item.modulate
	color.a = alpha
	item.modulate = color

func _show_damage(position: Vector2, amount: int, special := false, pop_index := 0) -> void:
	_play_sound("hit_magic" if special else "hit_slash")
	var heavy := special or amount >= 38
	if heavy:
		hitstop_timer = maxf(hitstop_timer, 0.065)
	if special:
		_show_skill_damage_number(position, amount, pop_index)
		return
	var spark := Polygon2D.new()
	var spark_y := -52.0
	spark.position = position + Vector2(0, spark_y)
	spark.z_index = 2199
	spark.color = Color(1.0, 0.50, 0.12, 0.96)
	spark.polygon = PackedVector2Array([
		Vector2(0, -20),
		Vector2(6, -6),
		Vector2(24, 0),
		Vector2(6, 6),
		Vector2(0, 20),
		Vector2(-6, 6),
		Vector2(-24, 0),
		Vector2(-6, -6),
	])
	spark.add_to_group("normal_combat_vfx")
	feedback_root.add_child(spark)
	if heavy:
		_add_ring_vfx(position + Vector2(0, -48), 31.0, Color(1.0, 0.75, 0.24, 0.72))
		_spawn_damage_shards(position + Vector2(0, -50), false)
	var label := Label.new()
	label.text = "-%d" % amount
	var side_kick := float((amount % 5) - 2) * 5.0
	label.position = position + Vector2(-25, -82)
	label.size = Vector2(90.0, 42.0)
	label.z_index = 2200
	label.scale = Vector2(0.62, 0.62)
	label.pivot_offset = Vector2(38.0, 20.0)
	_apply_ui_font(label, ui_bold_font)
	label.add_theme_font_size_override("font_size", 35 if heavy else 31)
	label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.38, 1.0) if heavy else Color(1.0, 0.82, 0.26, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.10, 0.025, 0.0, 1.0))
	label.add_theme_constant_override("outline_size", 5 if heavy else 4)
	label.add_to_group("normal_combat_vfx")
	feedback_root.add_child(label)
	var spark_tween := create_tween()
	spark.scale = Vector2(0.35, 0.35)
	var spark_target_scale := Vector2(2.35, 2.25) if heavy else Vector2(1.95, 1.95)
	var spark_fade_duration := 0.30
	spark_tween.tween_property(spark, "scale", spark_target_scale, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	spark_tween.parallel().tween_property(spark, "modulate:a", 0.0, spark_fade_duration)
	spark_tween.tween_callback(spark.queue_free)
	var label_tween := create_tween()
	label_tween.tween_property(label, "scale", Vector2(1.22, 1.22) if heavy else Vector2(1.06, 1.06), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	label_tween.parallel().tween_property(label, "position", label.position + Vector2(side_kick, -24), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	label_tween.tween_property(label, "position", label.position + Vector2(side_kick * 1.7, -58), 0.34).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	label_tween.parallel().tween_property(label, "modulate:a", 0.0, 0.34)
	label_tween.tween_callback(label.queue_free)

func _show_skill_damage_number(position: Vector2, amount: int, pop_index: int) -> void:
	_spawn_damage_shards(position + Vector2(0, -52), true)
	_add_ring_vfx(position + Vector2(0, -48), 18.0, Color(1.0, 0.72, 0.24, 0.18))
	var label := Label.new()
	label.text = "-%d" % amount
	var column := float((pop_index % 3) - 1)
	var row := float(int(pop_index / 3))
	var inward_side := -1.0 if position.x > 640.0 else 1.0
	var label_position := position + Vector2((inward_side * 62.0) + column * 18.0, -98.0 - row * 9.0)
	label_position.y = maxf(label_position.y, 184.0 + row * 8.0)
	label.position = label_position
	label.size = Vector2(78.0, 32.0)
	label.z_index = 2168
	label.scale = Vector2(0.40, 0.40)
	label.pivot_offset = Vector2(42.0, 18.0)
	_apply_ui_font(label, ui_bold_font)
	label.add_theme_font_size_override("font_size", 27)
	label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.28, 0.82))
	label.add_theme_color_override("font_outline_color", Color(0.015, 0.006, 0.0, 1.0))
	label.add_theme_constant_override("outline_size", 3)
	feedback_root.add_child(label)
	var lift := Vector2(inward_side * 18.0 + column * 5.0, -30.0)
	var tween := create_tween()
	tween.tween_property(label, "scale", Vector2(0.78, 0.78), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "position", label.position + lift * 0.42, 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position", label.position + lift, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.22)
	tween.tween_callback(label.queue_free)

func _spawn_damage_shards(center: Vector2, special: bool) -> void:
	var color := Color(1.0, 0.76, 0.28, 0.48) if special else Color(1.0, 0.78, 0.24, 0.92)
	var angles := [-1.95, -1.35, -0.52, 0.48, 1.22, 1.82]
	for i in range(angles.size()):
		var shard := Polygon2D.new()
		shard.position = center
		shard.rotation = float(angles[i])
		shard.z_index = 2148 if special else 2198
		shard.color = color
		if not special:
			shard.add_to_group("normal_combat_vfx")
		shard.polygon = PackedVector2Array([
			Vector2(0, -7),
			Vector2(3, 2),
			Vector2(0, 7),
			Vector2(-3, 2),
		])
		feedback_root.add_child(shard)
		var distance := 18.0 + float(i % 3) * 7.0
		var target := center + Vector2(cos(float(angles[i])), sin(float(angles[i]))) * distance
		var tween := create_tween()
		tween.tween_property(shard, "position", target, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(shard, "scale", Vector2(0.32, 0.32), 0.22)
		tween.parallel().tween_property(shard, "modulate:a", 0.0, 0.22)
		tween.tween_callback(shard.queue_free)

func _pull_gacha(count: int) -> void:
	analytics_client.log_event("gacha_pull", {"count": count})
	var request := economy_client.pull_gacha("local-profile", "pull-%d-%d" % [count, Time.get_unix_time_from_system()], count)
	status_override = "Gacha request ready: %s" % request["url"].get_file()
	_refresh_ui()

func _buy_premium() -> void:
	analytics_client.log_event("purchase_start", {"product_id": "premium_small"})
	var purchase: Dictionary = purchase_client.start_purchase("premium_small")
	if bool(purchase.get("ok", false)):
		var request := purchase_client.grant_request(economy_client, "local-profile", purchase)
		if bool(request.get("ok", true)) == false:
			analytics_client.log_event("purchase_fail", {"product_id": purchase["productId"], "error": request.get("error", "unknown")})
			status_override = "Purchase blocked: %s" % request.get("error", "unknown")
		else:
			status_override = "Purchase validation request ready: %s" % request["url"].get_file()
	else:
		analytics_client.log_event("purchase_fail", {"product_id": "premium_small", "error": purchase.get("error", "unknown")})
	_refresh_ui()

func _record_purchase_granted(product_id: String) -> void:
	analytics_client.log_event("purchase_success", {"product_id": product_id})

func _short_id(character_id: String) -> String:
	var parts := character_id.split("_")
	if parts.size() >= 3:
		return parts[2].left(6)
	return character_id

func _build_hud_ornaments() -> void:
	for child in hud_ornaments.get_children():
		child.queue_free()
	_add_hud_line(Vector2(480, 56), Vector2(800, 56), 2.0, Color(1.0, 0.66, 0.22, 0.72))
	_add_hud_line(Vector2(420, 153), Vector2(860, 153), 2.0, Color(1.0, 0.66, 0.22, 0.72))
	for x in [430.0, 850.0]:
		_add_hud_diamond(Vector2(x, 153), 10.0, Color(1.0, 0.69, 0.23, 0.86))
	_add_top_button_icon("temple", Vector2(39.0, 45.0), 0.74)
	_add_top_button_icon("menu", Vector2(188.0, 45.0), 0.86)
	_add_play_triangle(Vector2(1240.0, 45.0), 15.0, Color(1.0, 0.72, 0.22, 0.94))
	_add_action_medal_core(Vector2(84.0, 648.0), 54.0)
	_add_action_medal_core(Vector2(1196.0, 648.0), 56.0)
	_add_action_icon(ACTION_AUTO_ICON, Vector2(84.0, 618.0), 54.0)
	_add_action_icon(ACTION_UPGRADE_ICON, Vector2(1196.0, 616.0), 62.0)
	skill_cooldown_ring = Line2D.new()
	skill_cooldown_ring.width = 3.0
	skill_cooldown_ring.default_color = Color(1.0, 0.78, 0.28, 0.92)
	skill_cooldown_ring.z_index = 20
	hud_ornaments.add_child(skill_cooldown_ring)

func _build_currency_overlay() -> void:
	currency_value_labels.clear()
	gold_label.visible = false
	var specs := [
		{"center": Vector2(827.0, 45.0), "label": Vector2(844.0, 30.0), "texture": CURRENCY_GOLD_ICON, "color": Color(1.0, 0.74, 0.22, 1.0), "outline": Color(0.55, 0.32, 0.05, 1.0)},
		{"center": Vector2(943.0, 45.0), "label": Vector2(960.0, 30.0), "texture": CURRENCY_ESSENCE_ICON, "color": Color(0.72, 0.34, 1.0, 1.0), "outline": Color(0.34, 0.08, 0.52, 1.0)},
		{"center": Vector2(1059.0, 45.0), "label": Vector2(1076.0, 30.0), "texture": CURRENCY_SHARD_ICON, "color": Color(1.0, 0.22, 0.18, 1.0), "outline": Color(0.52, 0.04, 0.04, 1.0)},
	]
	for spec in specs:
		_add_currency_icon(spec["texture"], spec["center"], spec["color"], spec["outline"])
		var label := Label.new()
		label.position = spec["label"]
		label.size = Vector2(58.0, 30.0)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_apply_ui_font(label, ui_bold_font)
		label.add_theme_font_size_override("font_size", 17)
		label.add_theme_color_override("font_color", Color(1.0, 0.93, 0.76, 1.0))
		label.add_theme_color_override("font_outline_color", Color(0.02, 0.012, 0.0, 1.0))
		label.add_theme_constant_override("outline_size", 2)
		hud_ornaments.add_child(label)
		currency_value_labels.append(label)
	_update_currency_overlay()

func _update_currency_overlay() -> void:
	if currency_value_labels.size() < 3:
		return
	currency_value_labels[0].text = _compact_number(gold)
	currency_value_labels[1].text = _compact_number(essence)
	currency_value_labels[2].text = _compact_number(shards)

func _add_currency_icon(path: String, center: Vector2, fallback_fill: Color, fallback_outline: Color) -> void:
	var texture := load(path) as Texture2D
	if texture == null:
		_add_currency_gem(center, fallback_fill, fallback_outline)
		return
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = center
	sprite.scale = Vector2(28.0 / float(texture.get_width()), 28.0 / float(texture.get_height()))
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hud_ornaments.add_child(sprite)

func _add_action_icon(path: String, center: Vector2, size: float) -> void:
	var texture := load(path) as Texture2D
	if texture == null:
		return
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = center
	sprite.scale = Vector2(size / float(texture.get_width()), size / float(texture.get_height()))
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hud_ornaments.add_child(sprite)

func _add_action_medal_core(center: Vector2, radius: float) -> void:
	var core := Polygon2D.new()
	core.color = Color(0.075, 0.052, 0.024, 0.48)
	var core_points := PackedVector2Array()
	for i in range(36):
		var angle := TAU * float(i) / 36.0
		core_points.append(center + Vector2(cos(angle) * radius * 0.78, sin(angle) * radius * 0.78))
	core.polygon = core_points
	hud_ornaments.add_child(core)
	var ring := Line2D.new()
	ring.width = 1.8
	ring.default_color = Color(1.0, 0.68, 0.22, 0.62)
	var ring_points := PackedVector2Array()
	for i in range(41):
		var angle := TAU * float(i) / 40.0
		ring_points.append(center + Vector2(cos(angle) * radius * 0.82, sin(angle) * radius * 0.82))
	ring.points = ring_points
	hud_ornaments.add_child(ring)

func _add_top_button_icon(kind: String, center: Vector2, scale: float) -> void:
	match kind:
		"menu":
			for y in [-8.0, 0.0, 8.0]:
				_add_hud_line(center + Vector2(-12.0, y), center + Vector2(12.0, y), 3.4 * scale, Color(1.0, 0.79, 0.38, 0.9))
		_:
			var spire := Polygon2D.new()
			spire.color = Color(1.0, 0.78, 0.35, 0.92)
			spire.polygon = PackedVector2Array([
				center + Vector2(0, -18) * scale,
				center + Vector2(5, -7) * scale,
				center + Vector2(2, -7) * scale,
				center + Vector2(2, -3) * scale,
				center + Vector2(9, -1) * scale,
				center + Vector2(6, 4) * scale,
				center + Vector2(-6, 4) * scale,
				center + Vector2(-9, -1) * scale,
				center + Vector2(-2, -3) * scale,
				center + Vector2(-2, -7) * scale,
				center + Vector2(-5, -7) * scale,
			])
			hud_ornaments.add_child(spire)
			_add_hud_line(center + Vector2(-14.0, 8.0) * scale, center + Vector2(14.0, 8.0) * scale, 2.0 * scale, Color(1.0, 0.72, 0.28, 0.86))
			_add_hud_line(center + Vector2(-17.0, 14.0) * scale, center + Vector2(17.0, 14.0) * scale, 2.3 * scale, Color(1.0, 0.72, 0.28, 0.78))

func _add_play_triangle(center: Vector2, radius: float, color: Color) -> void:
	var triangle := Polygon2D.new()
	triangle.color = color
	triangle.polygon = PackedVector2Array([
		center + Vector2(-radius * 0.45, -radius * 0.72),
		center + Vector2(radius * 0.68, 0),
		center + Vector2(-radius * 0.45, radius * 0.72),
	])
	hud_ornaments.add_child(triangle)

func _add_currency_gem(center: Vector2, fill: Color, outline: Color) -> void:
	var outline_gem := Polygon2D.new()
	outline_gem.color = outline
	outline_gem.polygon = PackedVector2Array([
		center + Vector2(0, -13),
		center + Vector2(12, -3),
		center + Vector2(8, 11),
		center + Vector2(-8, 11),
		center + Vector2(-12, -3),
	])
	hud_ornaments.add_child(outline_gem)
	var gem := Polygon2D.new()
	gem.color = fill
	gem.polygon = PackedVector2Array([
		center + Vector2(0, -9),
		center + Vector2(8, -2),
		center + Vector2(5, 8),
		center + Vector2(-5, 8),
		center + Vector2(-8, -2),
	])
	hud_ornaments.add_child(gem)
	var shine := Line2D.new()
	shine.width = 1.2
	shine.default_color = Color(1, 1, 1, 0.55)
	shine.points = PackedVector2Array([
		center + Vector2(-3, -5),
		center + Vector2(3, 2),
	])
	hud_ornaments.add_child(shine)

func _build_lane_guides() -> void:
	for child in lane_guides.get_children():
		child.queue_free()
	for i in range(LANE_GUIDE_YS.size()):
		var y := float(LANE_GUIDE_YS[i])
		var alpha := 0.42 if i == 2 else 0.30
		for segment in LANE_GUIDE_SEGMENTS:
			_add_lane_inlay(Vector2(segment.x, y), Vector2(segment.y, y), alpha)
			var x := float(segment.x)
			while x < float(segment.y):
				_add_lane_dash(Vector2(x, y), Vector2(minf(x + LANE_DASH_LENGTH, float(segment.y)), y), alpha)
				x += LANE_DASH_LENGTH + LANE_DASH_GAP
			_add_lane_marker(Vector2(segment.x, y), alpha + 0.06)
			_add_lane_marker(Vector2(segment.y, y), alpha + 0.06)

func _add_lane_inlay(from: Vector2, to: Vector2, alpha: float) -> void:
	var shadow := Line2D.new()
	shadow.width = 2.4
	shadow.default_color = Color(0.0, 0.0, 0.0, alpha * 0.52)
	shadow.points = PackedVector2Array([from, to])
	lane_guides.add_child(shadow)
	var gold := Line2D.new()
	gold.width = 0.8
	gold.default_color = Color(1.0, 0.66, 0.22, alpha * 0.36)
	gold.points = PackedVector2Array([from, to])
	lane_guides.add_child(gold)

func _add_lane_dash(from: Vector2, to: Vector2, alpha: float) -> void:
	var line := Line2D.new()
	line.width = 1.35
	line.default_color = Color(1.0, 0.72, 0.28, alpha * 1.18)
	line.points = PackedVector2Array([from, to])
	lane_guides.add_child(line)

func _add_lane_marker(center: Vector2, alpha: float) -> void:
	var marker := Polygon2D.new()
	marker.color = Color(1.0, 0.68, 0.24, alpha * 0.68)
	marker.polygon = PackedVector2Array([
		center + Vector2(0, -4),
		center + Vector2(6, 0),
		center + Vector2(0, 4),
		center + Vector2(-6, 0),
	])
	lane_guides.add_child(marker)

func _build_formation_cards() -> void:
	for child in formation_preview_root.get_children():
		child.queue_free()
	for child in formation_overlay.get_children():
		child.queue_free()
	formation_preview_sprites.clear()
	formation_slot_labels.clear()
	formation_level_labels.clear()
	formation_role_labels.clear()
	formation_hp_tracks.clear()
	formation_hp_fills.clear()
	formation_hp_glints.clear()
	formation_hp_labels.clear()
	for i in range(formation_buttons.size()):
		var x := FORMATION_CARD_LEFT + float(i) * (FORMATION_CARD_WIDTH + FORMATION_CARD_GAP)
		var y := FORMATION_CARD_TOP
		_add_card_portrait_shadow(Vector2(x + 50.0, y + 73.0))
		var slot_label := _new_overlay_label(Vector2(x + 12.0, y + 10.0), Vector2(22.0, 22.0), 15, Color(1.0, 0.9, 0.62, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
		var level_label := _new_overlay_label(Vector2(x + 110.0, y + 18.0), Vector2(66.0, 23.0), 15, Color(1.0, 0.92, 0.76, 1.0), HORIZONTAL_ALIGNMENT_LEFT)
		var role_label := _new_overlay_label(Vector2(x + 110.0, y + 45.0), Vector2(70.0, 18.0), 11, Color(0.94, 0.9, 0.78, 0.74), HORIZONTAL_ALIGNMENT_LEFT)
		_new_overlay_texture(HP_BAR_FRAME_IMAGEGEN, Vector2(x + 104.0, y + 66.0), Vector2(FORMATION_HP_WIDTH + 12.0, 23.0), 910)
		var hp_track := _new_overlay_rect(Vector2(x + 110.0, y + 73.0), Vector2(FORMATION_HP_WIDTH, 9.0), Color(0.015, 0.018, 0.012, 0.98))
		var hp_fill := _new_overlay_rect(Vector2(x + 111.0, y + 74.0), Vector2(FORMATION_HP_WIDTH - 2.0, 7.0), Color(0.92, 0.54, 0.12, 1.0))
		var hp_glint := _new_overlay_rect(Vector2(x + 112.0, y + 74.0), Vector2(FORMATION_HP_WIDTH - 4.0, 2.0), Color(1.0, 0.86, 0.34, 0.44))
		var hp_label := _new_overlay_label(Vector2(x + 110.0, y + 67.0), Vector2(FORMATION_HP_WIDTH, 14.0), 8, Color(1.0, 0.96, 0.78, 0.0), HORIZONTAL_ALIGNMENT_CENTER)
		hp_label.visible = false
		hp_track.z_index = 911
		hp_fill.z_index = 912
		hp_glint.z_index = 913
		formation_slot_labels.append(slot_label)
		formation_level_labels.append(level_label)
		formation_role_labels.append(role_label)
		formation_hp_tracks.append(hp_track)
		formation_hp_fills.append(hp_fill)
		formation_hp_glints.append(hp_glint)
		formation_hp_labels.append(hp_label)

		var sprite := AnimatedSprite2D.new()
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.scale = Vector2(1.08, 1.08)
		sprite.position = Vector2(x + 50.0, y + 72.0)
		sprite.z_index = 905
		formation_preview_root.add_child(sprite)
		formation_preview_sprites.append(sprite)
	_update_formation_preview_sprites()

func _add_card_portrait_shadow(center: Vector2) -> void:
	var shadow := Polygon2D.new()
	shadow.z_index = 902
	shadow.color = Color(0.0, 0.0, 0.0, 0.38)
	shadow.polygon = PackedVector2Array([
		center + Vector2(-38, 18),
		center + Vector2(36, 12),
		center + Vector2(43, 20),
		center + Vector2(20, 28),
		center + Vector2(-28, 28),
		center + Vector2(-44, 22),
	])
	formation_preview_root.add_child(shadow)

func _sync_formation_cards(level: int) -> void:
	if formation.size() != formation_preview_sprites.size():
		return
	_update_formation_preview_sprites()
	var hp_by_character := {}
	if sim != null:
		for unit in sim.units:
			if unit["team"] == "player":
				hp_by_character[String(unit["character_id"])] = {
					"hp": int(unit["hp"]),
					"max_hp": int(unit["max_hp"]),
					"alive": bool(unit["alive"]),
				}
	for i in range(formation.size()):
		var hero_id := String(formation[i])
		var role := _role_label(HeroCatalogScript.archetype_for(hero_id))
		var hp_info: Dictionary = hp_by_character.get(hero_id, {"hp": 1, "max_hp": 1, "alive": true}) as Dictionary
		var hp := int(hp_info.get("hp", 1))
		var max_hp: int = maxi(1, int(hp_info.get("max_hp", 1)))
		var ratio: float = clampf(float(hp) / float(max_hp), 0.0, 1.0)
		formation_slot_labels[i].text = "%d" % (i + 1)
		formation_level_labels[i].text = "Lv. %d" % level
		formation_role_labels[i].text = role
		formation_hp_fills[i].size.x = maxf(0.0, (FORMATION_HP_WIDTH - 2.0) * ratio)
		formation_hp_fills[i].color = _formation_hp_color(ratio)
		formation_hp_glints[i].size.x = maxf(0.0, (FORMATION_HP_WIDTH - 4.0) * ratio)
		formation_hp_glints[i].color = _formation_hp_glint_color(ratio)
		formation_hp_labels[i].text = ""
		formation_preview_sprites[i].modulate = Color(1, 1, 1, 1) if bool(hp_info.get("alive", true)) else Color(0.42, 0.42, 0.42, 0.82)
		if selected_slot == i:
			formation_buttons[i].modulate = Color(1.0, 0.86, 0.42, 1.0)
		else:
			formation_buttons[i].modulate = Color.WHITE

func _formation_hp_color(ratio: float) -> Color:
	if ratio <= 0.22:
		return Color(0.84, 0.10, 0.07, 1.0)
	if ratio <= 0.45:
		return Color(0.92, 0.46, 0.10, 1.0)
	return Color(0.92, 0.54, 0.12, 1.0)

func _formation_hp_glint_color(ratio: float) -> Color:
	if ratio <= 0.22:
		return Color(1.0, 0.74, 0.48, 0.42)
	if ratio <= 0.45:
		return Color(1.0, 0.88, 0.52, 0.42)
	return Color(1.0, 0.86, 0.34, 0.44)

func _update_formation_preview_sprites() -> void:
	var key := "|".join(PackedStringArray(formation))
	if key == last_formation_preview_key:
		return
	last_formation_preview_key = key
	for i in range(min(formation.size(), formation_preview_sprites.size())):
		var sprite: AnimatedSprite2D = formation_preview_sprites[i]
		var hero_id := String(formation[i])
		sprite.sprite_frames = load("res://generated/spriteframes/%s.tres" % hero_id)
		if sprite.sprite_frames != null and sprite.sprite_frames.has_animation("idle_south"):
			sprite.play("idle_south")

func _new_overlay_label(position: Vector2, size: Vector2, font_size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.position = position
	label.size = size
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_apply_ui_font(label, ui_font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.012, 0.0, 1.0))
	label.add_theme_constant_override("outline_size", 2)
	formation_overlay.add_child(label)
	return label

func _new_overlay_rect(position: Vector2, size: Vector2, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.position = position
	rect.size = size
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	formation_overlay.add_child(rect)
	return rect

func _new_overlay_texture(path: String, position: Vector2, size: Vector2, z: int) -> TextureRect:
	var rect := TextureRect.new()
	rect.position = position
	rect.size = size
	rect.z_index = z
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	var texture := load(path) as Texture2D
	if texture == null:
		push_warning("Missing overlay texture: %s" % path)
	else:
		rect.texture = texture
	formation_overlay.add_child(rect)
	return rect

func _add_hud_line(from: Vector2, to: Vector2, width: float, color: Color) -> void:
	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.points = PackedVector2Array([from, to])
	hud_ornaments.add_child(line)

func _add_hud_diamond(center: Vector2, radius: float, color: Color) -> void:
	var diamond := Polygon2D.new()
	diamond.color = color
	diamond.polygon = PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius, 0),
	])
	hud_ornaments.add_child(diamond)

func _role_label(archetype: String) -> String:
	match archetype:
		"vanguard":
			return "BLADE"
		"guardian":
			return "TANK"
		"ranger":
			return "ARCHER"
		"skirmisher":
			return "ROGUE"
		"control_mage":
			return "MAGE"
		"support":
			return "HEALER"
		"debuffer":
			return "HEX"
		"summoner":
			return "SPIRIT"
	return archetype.to_upper()

func _compact_number(value: int) -> String:
	if value >= 1000000:
		return "%.1fM" % (float(value) / 1000000.0)
	if value >= 10000:
		return "%.1fK" % (float(value) / 1000.0)
	return "%d" % value

func _apply_safe_area() -> void:
	if not OS.has_feature("android"):
		return
	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	var safe_top: int = max(0, safe_area.position.y)
	if safe_top <= 0:
		return
	for node in [
		$Title,
		$TitleSubtitle,
		$GachaButton,
		$SettingsButton,
		$SpeedButton,
		$ResultLabel,
		$StatusLabel,
		$GoldLabel,
		$SettingsPanel,
	]:
		node.position.y += safe_top

func _apply_ui_theme() -> void:
	ui_font = load(UI_FONT_PATH) as FontFile
	ui_bold_font = load(UI_BOLD_FONT_PATH) as FontFile
	title_font = load(UI_TITLE_FONT_PATH) as FontFile
	_apply_font_tree(self, ui_font)
	var primary := Color(0.12, 0.09, 0.035, 0.96)
	var secondary := Color(0.025, 0.04, 0.04, 0.96)
	var border := Color(0.98, 0.68, 0.24, 1.0)
	_style_panel(wave_panel, Color(0.015, 0.02, 0.024, 0.88), border)
	_style_panel(resource_panel, Color(0.015, 0.02, 0.024, 0.88), border)
	_style_panel(reward_panel, Color(0.05, 0.04, 0.02, 0.9), border)
	for button in [start_button, upgrade_button]:
		_style_action_button(button)
	_style_button(next_wave_button, primary, border, 3)
	for button in [gacha_button, settings_button, speed_button, pull_one_button, pull_ten_button, buy_button, english_button, thai_button, sound_button, restore_button, support_button, feedback_button, delete_account_button]:
		_style_button(button, secondary, border, 3)
	for button in formation_buttons:
		_style_card_button(button)

	title.add_theme_color_override("font_color", Color(1.0, 0.78, 0.34, 1.0))
	_apply_ui_font(title, title_font)
	title.add_theme_color_override("font_outline_color", Color(0.04, 0.02, 0.0, 1.0))
	title.add_theme_constant_override("outline_size", 4)
	title_subtitle.add_theme_color_override("font_color", Color(1.0, 0.76, 0.32, 1.0))
	_apply_ui_font(title_subtitle, ui_bold_font)
	title_subtitle.add_theme_color_override("font_outline_color", Color(0.04, 0.02, 0.0, 1.0))
	title_subtitle.add_theme_constant_override("outline_size", 2)
	result_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.34, 1.0))
	_apply_ui_font(result_label, ui_bold_font)
	result_label.add_theme_color_override("font_outline_color", Color(0.04, 0.02, 0.0, 1.0))
	result_label.add_theme_constant_override("outline_size", 3)
	status_label.add_theme_color_override("font_color", Color(0.94, 0.9, 0.78, 1.0))
	gold_label.add_theme_color_override("font_color", Color(0.98, 0.9, 0.72, 1.0))
	_style_progress_bar(wave_progress_bar)

func _style_panel(panel: Panel, fill: Color, border: Color) -> void:
	var texture := load(ORNATE_BUTTON_FRAME) as Texture2D
	if texture != null:
		panel.add_theme_stylebox_override("panel", _texture_style(texture, 0, 0, 0, 0, Color(1, 1, 1, 1)))
		return
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0, 0, 0, 0.72)
	style.shadow_size = 6
	panel.add_theme_stylebox_override("panel", style)

func _style_button(button: Button, fill: Color, border: Color, border_width: int) -> void:
	var texture := load(ORNATE_BUTTON_FRAME) as Texture2D
	if texture != null:
		var normal := _texture_style(texture, 0, 0, 0, 0, Color(1, 1, 1, 1))
		var hover := _texture_style(texture, 0, 0, 0, 0, Color(1.08, 1.06, 0.94, 1))
		var pressed := _texture_style(texture, 0, 0, 0, 0, Color(0.88, 0.84, 0.72, 1))
		var disabled := _texture_style(texture, 0, 0, 0, 0, Color(0.78, 0.72, 0.54, 0.76))
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", pressed)
		button.add_theme_stylebox_override("disabled", disabled)
		_apply_button_text_theme(button)
		return

	var normal := StyleBoxFlat.new()
	normal.bg_color = fill
	normal.border_color = border
	normal.border_width_left = border_width
	normal.border_width_top = border_width
	normal.border_width_right = border_width
	normal.border_width_bottom = border_width
	normal.corner_radius_top_left = 4
	normal.corner_radius_top_right = 4
	normal.corner_radius_bottom_right = 4
	normal.corner_radius_bottom_left = 4
	normal.content_margin_left = 10
	normal.content_margin_right = 10
	normal.shadow_color = Color(0, 0, 0, 0.7)
	normal.shadow_size = 4

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = fill.lightened(0.08)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = fill.darkened(0.12)
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(fill.r, fill.g, fill.b, 0.42)
	disabled.border_color = Color(border.r, border.g, border.b, 0.42)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color(1.0, 0.9, 0.68, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.76, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.82, 0.38, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.84, 0.8, 0.66, 0.78))
	button.add_theme_color_override("font_outline_color", Color(0.02, 0.015, 0.0, 1.0))
	button.add_theme_constant_override("outline_size", 2)

func _style_card_button(button: Button) -> void:
	var texture := load(ORNATE_HERO_CARD) as Texture2D
	if texture == null:
		_style_button(button, Color(0.025, 0.045, 0.04, 0.96), Color(0.98, 0.68, 0.24, 1.0), 2)
		return
	var normal := _texture_style(texture, 0, 0, 0, 0, Color(1, 1, 1, 1))
	var hover := _texture_style(texture, 0, 0, 0, 0, Color(1.08, 1.06, 0.94, 1))
	var pressed := _texture_style(texture, 0, 0, 0, 0, Color(0.9, 0.86, 0.76, 1))
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", _texture_style(texture, 0, 0, 0, 0, Color(0.78, 0.72, 0.54, 0.76)))
	_apply_button_text_theme(button)

func _style_action_button(button: Button) -> void:
	var texture := load(ORNATE_ACTION_BUTTON) as Texture2D
	if texture == null:
		_style_button(button, Color(0.12, 0.09, 0.035, 0.96), Color(0.98, 0.68, 0.24, 1.0), 3)
		return
	button.add_theme_stylebox_override("normal", _texture_style(texture, 0, 0, 0, 0, Color(1, 1, 1, 1)))
	button.add_theme_stylebox_override("hover", _texture_style(texture, 0, 0, 0, 0, Color(1.08, 1.06, 0.94, 1)))
	button.add_theme_stylebox_override("pressed", _texture_style(texture, 0, 0, 0, 0, Color(0.88, 0.84, 0.72, 1)))
	button.add_theme_stylebox_override("disabled", _texture_style(texture, 0, 0, 0, 0, Color(0.86, 0.78, 0.54, 0.84)))
	_apply_button_text_theme(button)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_constant_override("outline_size", 3)

func _style_progress_bar(bar: ProgressBar) -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.04, 0.025, 0.012, 0.95)
	background.border_color = Color(0.95, 0.62, 0.18, 1.0)
	background.border_width_left = 1
	background.border_width_top = 1
	background.border_width_right = 1
	background.border_width_bottom = 1
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(1.0, 0.72, 0.08, 1.0)
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)

func _texture_style(texture: Texture2D, left: int, top: int, right: int, bottom: int, tint: Color) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = left
	style.texture_margin_top = top
	style.texture_margin_right = right
	style.texture_margin_bottom = bottom
	style.draw_center = true
	style.modulate_color = tint
	return style

func _apply_button_text_theme(button: Button) -> void:
	_apply_ui_font(button, ui_bold_font if ui_bold_font != null else ui_font)
	button.add_theme_color_override("font_color", Color(1.0, 0.9, 0.68, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.76, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.82, 0.38, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.86, 0.82, 0.68, 0.82))
	button.add_theme_color_override("font_outline_color", Color(0.02, 0.015, 0.0, 1.0))
	button.add_theme_constant_override("outline_size", 2)

func _apply_font_tree(node: Node, font: FontFile) -> void:
	if font == null:
		return
	if node is Control:
		_apply_ui_font(node as Control, font)
	for child in node.get_children():
		_apply_font_tree(child, font)

func _apply_ui_font(control: Control, font: FontFile) -> void:
	if font != null:
		control.add_theme_font_override("font", font)

func _setup_audio() -> void:
	var specs := {
		"ui_click": AUDIO_UI_CLICK,
		"hit_slash": AUDIO_HIT_SLASH,
		"hit_magic": AUDIO_HIT_MAGIC,
		"skill_cast": AUDIO_SKILL_CAST,
		"skill_impact": AUDIO_SKILL_IMPACT,
		"death": AUDIO_DEATH_BURST,
		"reward": AUDIO_REWARD_CHIME,
	}
	for name in specs.keys():
		var stream := load(String(specs[name])) as AudioStream
		if stream == null:
			push_warning("Missing audio stream: %s" % specs[name])
			continue
		var player := AudioStreamPlayer.new()
		player.stream = stream
		player.volume_db = -3.5 if name == "ui_click" else -1.0
		add_child(player)
		audio_players[name] = player
	var ambience_stream := load(AUDIO_AMBIENCE) as AudioStream
	if ambience_stream == null:
		push_warning("Missing ambience stream: %s" % AUDIO_AMBIENCE)
		return
	ambience_player = AudioStreamPlayer.new()
	ambience_player.stream = ambience_stream
	ambience_player.volume_db = -18.0
	add_child(ambience_player)
	ambience_player.finished.connect(_restart_ambience)
	if sound_enabled:
		ambience_player.play()

func _restart_ambience() -> void:
	if sound_enabled and ambience_player != null:
		ambience_player.play()

func _play_sound(name: String) -> void:
	if not sound_enabled:
		return
	var player := audio_players.get(name) as AudioStreamPlayer
	if player == null:
		return
	player.stop()
	player.play()

func _nearest_enemy(caster: Dictionary) -> Dictionary:
	var nearest := {}
	var best_distance := INF
	for unit in sim.units:
		if unit["team"] == caster["team"] or not bool(unit["alive"]):
			continue
		var distance: float = (unit["position"] as Vector2).distance_to(caster["position"])
		if distance < best_distance:
			best_distance = distance
			nearest = unit
	return nearest

func _skill_name(hero_id: String) -> String:
	return HeroCatalogScript.skill_name_for(hero_id)

func _personal_vfx_key_from_path(path: String) -> String:
	return path.get_file().get_basename()

func _personal_vfx_key_for_hero(hero_id: String) -> String:
	var path := String(PERSONAL_VFX_BY_HERO.get(hero_id, ""))
	if path == "":
		return ""
	return _personal_vfx_key_from_path(path)

func _personal_vfx_path_for_hero(hero_id: String) -> String:
	return String(PERSONAL_VFX_BY_HERO.get(hero_id, ""))

func _is_v101_personal_profile(profile: Dictionary) -> bool:
	return V101_REQUIRED_PERSONAL_VFX.has(String(profile.get("hero_id", "")))

func _is_v102_personal_profile(profile: Dictionary) -> bool:
	return V102_REQUIRED_PERSONAL_VFX.has(String(profile.get("hero_id", "")))

func _is_v103_personal_profile(profile: Dictionary) -> bool:
	return V103_REQUIRED_PERSONAL_VFX.has(String(profile.get("hero_id", "")))

func _is_v104_personal_profile(profile: Dictionary) -> bool:
	return V104_REQUIRED_PERSONAL_VFX.has(String(profile.get("hero_id", "")))

func _personal_vfx_runtime_mode(profile: Dictionary) -> String:
	match String(profile.get("hero_id", "")):
		"S01_GARUDA_VAYUDEJ":
			return "v104_garuda_talon"
		"B09_SPIRIT_AMBERNIGHT":
			return "pulse_hold"
		"C01_HUMAN_JETSIAM":
			return "melee_thrust"
		"B02_NAGA_KLEDKRAM", "D06_NAGA_BUABUCHA":
			return "target_seal"
		"B03_YAKSHA_KHUNPHA":
			return "melee_cleave"
		"B04_HUMAN_DARIN":
			return "melee_seal"
		"B07_DRYAD_BUTSABA":
			return "thorn_path"
		"B08_HUMAN_MUENMONTRA":
			return "paper_hex"
		"C03_HUMAN_PANA":
			return "leaf_projectile"
		"C05_VANARA_JORJAN", "D05_VANARA_JUKJIK":
			return "melee_cleave"
		"D08_HUMAN_THIWA":
			return "target_seal_compact"
		"D02_HUMAN_KHAMPAN":
			return "melee_guard"
		"D03_HUMAN_PRANNOI":
			return "bow_release"
	return ""

func _skill_button_text() -> String:
	var next_id := _next_skill_caster_id()
	return "\nULT\n%s" % (_short_id(next_id) if next_id != "" else "READY")

func _next_skill_caster_id() -> String:
	if sim == null:
		return ""
	var players := []
	for unit in sim.units:
		if unit["team"] == "player" and bool(unit["alive"]):
			players.append(unit)
	if players.is_empty():
		return ""
	return String(players[skill_caster_index % players.size()]["character_id"])

func _skill_profile(hero_id: String) -> Dictionary:
	var profile := {
		"hero_id": hero_id,
		"skill_id": HeroCatalogScript.skill_id_for(hero_id),
		"delay": 0.16,
		"radius": 150.0,
		"max_targets": 3,
		"damage_multiplier": 1.9,
		"flat_damage": 12,
		"min_damage": 34,
		"knockback": 12.0,
		"hitstop": 0.075,
		"cast_size": 210.0,
		"streak_scale": 0.92,
		"impact_size": 330.0,
		"impact_rotation": 0.0,
		"cast_texture": "cast",
		"impact_texture": "single_arrow",
		"show_streak": true,
		"shake": 7.0,
		"tint": Color(1.0, 1.0, 1.0, 0.98),
		"banner": Color(0.72, 0.98, 1.0, 1.0),
		"signature": "burst",
		"personal_vfx": _personal_vfx_key_for_hero(hero_id),
	}
	match HeroCatalogScript.skill_template_for(hero_id):
		"taunt":
			profile.merge({"delay": 0.22, "radius": 185.0, "max_targets": 4, "damage_multiplier": 1.45, "flat_damage": 18, "knockback": 18.0, "cast_size": 245.0, "streak_scale": 0.55, "impact_size": 430.0, "cast_texture": "cast_guardian", "impact_texture": "guardian_aegis", "show_streak": false, "shake": 10.0, "tint": Color(1.0, 0.86, 0.46, 0.94), "banner": Color(1.0, 0.84, 0.38, 1.0), "signature": "guard"}, true)
		"cleave":
			profile.merge({"delay": 0.12, "radius": 128.0, "max_targets": 3, "damage_multiplier": 2.05, "flat_damage": 8, "knockback": 20.0, "cast_size": 178.0, "streak_scale": 0.72, "impact_size": 385.0, "impact_rotation": -0.35, "cast_texture": "cast_blade", "impact_texture": "cleave_slash", "show_streak": false, "shake": 9.0, "tint": Color(1.0, 0.9, 0.48, 0.96), "banner": Color(1.0, 0.78, 0.32, 1.0), "signature": "slash"}, true)
		"aoe_pulse":
			profile.merge({"delay": 0.2, "radius": 215.0, "max_targets": 5, "damage_multiplier": 1.65, "flat_damage": 14, "knockback": 10.0, "cast_size": 230.0, "streak_scale": 0.5, "impact_size": 470.0, "cast_texture": "cast_yantra", "impact_texture": "aoe_yantra", "show_streak": false, "shake": 10.5, "tint": Color(0.72, 0.98, 1.0, 0.92), "banner": Color(0.54, 0.96, 1.0, 1.0), "signature": "pulse"}, true)
		"shield_heal":
			profile.merge({"delay": 0.18, "radius": 170.0, "max_targets": 2, "damage_multiplier": 1.25, "flat_damage": 8, "knockback": 8.0, "cast_size": 255.0, "streak_scale": 0.42, "impact_size": 340.0, "cast_texture": "cast_guardian", "impact_texture": "guardian_aegis", "show_streak": false, "tint": Color(1.0, 0.95, 0.62, 0.92), "banner": Color(1.0, 0.92, 0.62, 1.0), "signature": "blossom"}, true)
		"slow_root":
			profile.merge({"delay": 0.2, "radius": 190.0, "max_targets": 4, "damage_multiplier": 1.45, "flat_damage": 10, "knockback": 5.0, "cast_size": 225.0, "streak_scale": 0.7, "impact_size": 380.0, "cast_texture": "cast_yantra", "impact_texture": "aoe_yantra", "show_streak": false, "tint": Color(0.62, 0.86, 1.0, 0.9), "banner": Color(0.7, 0.9, 1.0, 1.0), "signature": "bind"}, true)
		"debuff_attack":
			profile.merge({"delay": 0.14, "radius": 155.0, "max_targets": 3, "damage_multiplier": 1.75, "flat_damage": 10, "knockback": 11.0, "cast_size": 205.0, "streak_scale": 0.82, "impact_size": 330.0, "impact_texture": "single_arrow", "tint": Color(0.86, 0.66, 1.0, 0.96), "banner": Color(0.9, 0.72, 1.0, 1.0), "signature": "hex"}, true)
		"summon_lite_visual":
			profile.merge({"delay": 0.24, "radius": 190.0, "max_targets": 4, "damage_multiplier": 1.5, "flat_damage": 12, "knockback": 14.0, "cast_size": 260.0, "streak_scale": 0.58, "impact_size": 430.0, "cast_texture": "cast_yantra", "impact_texture": "spirit_summon", "show_streak": false, "tint": Color(0.78, 1.0, 0.82, 0.9), "banner": Color(0.78, 1.0, 0.82, 1.0), "signature": "summon"}, true)
	match hero_id:
		"S01_GARUDA_VAYUDEJ":
			profile.merge({"delay": 0.18, "streak_scale": 1.12, "impact_size": 380.0, "impact_texture": "cleave_slash", "impact_rotation": -0.24, "tint": Color(1.0, 0.82, 0.28, 0.98), "banner": Color(1.0, 0.84, 0.34, 1.0), "shake": 8.5, "signature": "garuda"}, true)
		"S02_NAGA_SASINAKA":
			profile.merge({"delay": 0.24, "cast_texture": "cast_yantra", "impact_texture": "aoe_yantra", "show_streak": false, "impact_size": 500.0, "tint": Color(0.52, 0.92, 1.0, 0.94), "banner": Color(0.62, 0.96, 1.0, 1.0), "shake": 11.0, "signature": "naga"}, true)
		"S03_YAKSHA_KRAIASURA":
			profile.merge({"delay": 0.24, "cast_texture": "cast_guardian", "impact_texture": "guardian_aegis", "show_streak": false, "impact_size": 465.0, "tint": Color(1.0, 0.72, 0.26, 0.96), "banner": Color(1.0, 0.78, 0.28, 1.0), "shake": 11.5, "signature": "aegis"}, true)
		"C08_CROCODILE_KUMPHIL":
			profile.merge({"delay": 0.24, "cast_texture": "cast_guardian", "impact_texture": "guardian_aegis", "show_streak": false, "impact_size": 455.0, "tint": Color(0.92, 0.76, 0.32, 0.96), "banner": Color(1.0, 0.82, 0.36, 1.0), "shake": 10.5, "signature": "aegis"}, true)
		"A02_TIGER_PLOENGPAYAK":
			profile.merge({"delay": 0.13, "impact_texture": "cleave_slash", "impact_rotation": 0.42, "impact_size": 410.0, "tint": Color(1.0, 0.36, 0.14, 0.96), "banner": Color(1.0, 0.52, 0.24, 1.0), "shake": 10.0, "signature": "tiger"}, true)
		"A03_HUMAN_ARUNRAT":
			profile.merge({"delay": 0.25, "streak_scale": 1.22, "impact_texture": "single_arrow", "impact_size": 360.0, "tint": Color(1.0, 0.88, 0.42, 0.98), "banner": Color(1.0, 0.86, 0.44, 1.0), "shake": 8.0, "signature": "arrow"}, true)
		"B04_HUMAN_DARIN":
			profile.merge({"delay": 0.20, "show_streak": false, "streak_scale": 0.96, "impact_size": 370.0, "tint": Color(0.92, 0.68, 1.0, 0.96), "banner": Color(0.96, 0.78, 1.0, 1.0), "shake": 8.5, "signature": "seal"}, true)
	_apply_personal_skill_variant(profile, hero_id)
	if hero_id == "D02_HUMAN_KHAMPAN":
		profile.merge({"cast_size": 176.0, "impact_size": 292.0, "release_size": 218.0, "show_streak": false, "shake": 8.6, "tint": Color(1.0, 0.78, 0.34, 0.94), "banner": Color(1.0, 0.84, 0.40, 1.0), "signature": "guard"}, true)
	return profile

func _apply_personal_skill_variant(profile: Dictionary, hero_id: String) -> void:
	var index := HeroCatalogScript.skill_variant_index_for(hero_id)
	var skill_name := HeroCatalogScript.skill_name_for(hero_id)
	var deltas := [-0.10, -0.05, 0.0, 0.06, 0.12]
	var radius_deltas := [-18.0, -9.0, 0.0, 9.0, 18.0]
	var size_deltas := [-34.0, -18.0, 0.0, 18.0, 34.0]
	profile["variant_index"] = index
	profile["damage_multiplier"] = maxf(0.8, float(profile["damage_multiplier"]) + float(deltas[index % deltas.size()]))
	profile["flat_damage"] = maxi(1, int(profile["flat_damage"]) + (index % 7) - 3)
	profile["radius"] = maxf(72.0, float(profile["radius"]) + float(radius_deltas[int(index / 5) % radius_deltas.size()]))
	profile["delay"] = clampf(float(profile["delay"]) + float(deltas[int(index / 3) % deltas.size()]) * 0.16, 0.08, 0.32)
	profile["knockback"] = maxf(0.0, float(profile["knockback"]) + float((index % 4) - 1) * 2.5)
	profile["cast_size"] = maxf(96.0, float(profile["cast_size"]) + float(size_deltas[int(index / 2) % size_deltas.size()]) * 0.55)
	profile["impact_size"] = maxf(120.0, float(profile["impact_size"]) + float(size_deltas[index % size_deltas.size()]))
	profile["impact_rotation"] = float(profile["impact_rotation"]) + deg_to_rad(float((index % 9) - 4) * 7.0)
	var tint := Color.from_hsv(fmod(0.08 + float(index) * 0.61803398875, 1.0), 0.46, 1.0, 0.96)
	var signature := String(profile.get("signature", ""))
	if signature == "burst":
		if skill_name.ends_with("SPEAR"):
			profile.merge({"signature": "spear", "streak_scale": 1.18, "impact_texture": "single_arrow", "tint": Color(1.0, 0.90, 0.36, 0.98)}, true)
		elif skill_name.ends_with("DART"):
			profile.merge({"signature": "dart", "streak_scale": 0.92, "impact_texture": "single_arrow", "tint": Color(0.78, 0.96, 1.0, 0.96)}, true)
		elif skill_name.ends_with("SHOT"):
			profile.merge({"signature": "shot", "streak_scale": 1.04, "impact_texture": "single_arrow", "tint": Color(1.0, 0.80, 0.42, 0.98)}, true)
		elif skill_name.ends_with("BLOW") or skill_name.ends_with("STRIKE"):
			profile.merge({"signature": "blow", "show_streak": false, "impact_texture": "cleave_slash", "tint": Color(1.0, 0.64, 0.24, 0.98)}, true)
		signature = String(profile.get("signature", ""))
	var base_tint: Color = profile["tint"]
	var base_banner: Color = profile["banner"]
	var tint_mix := 0.38
	if ["arrow", "garuda", "tiger", "naga", "pulse", "guard", "aegis", "spear", "dart", "shot", "blow"].has(signature):
		tint_mix = 0.12
	elif ["blossom", "bind", "summon"].has(signature):
		tint_mix = 0.22
	profile["tint"] = base_tint.lerp(tint, tint_mix)
	profile["banner"] = base_banner.lerp(Color(tint.r, tint.g, tint.b, 1.0), tint_mix * 0.85)
	if ["arrow", "spear", "dart", "shot"].has(signature):
		profile["show_streak"] = true
	elif ["garuda", "tiger", "blow", "slash", "aegis", "guard"].has(signature):
		profile["show_streak"] = false
	profile["release_size"] = clampf(float(profile["impact_size"]) * (0.74 + float(index % 5) * 0.035), 190.0, 410.0)

func _show_skill_banner(skill_name: String, profile: Dictionary) -> void:
	var back := ColorRect.new()
	back.position = Vector2(470, 152)
	back.size = Vector2(340, 34)
	back.color = Color(0.005, 0.018, 0.024, 0.38)
	back.z_index = 2298
	feedback_root.add_child(back)
	var banner := Label.new()
	banner.text = skill_name
	banner.position = Vector2(486, 154)
	banner.size = Vector2(308, 28)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.z_index = 2300
	_apply_ui_font(banner, title_font if title_font != null else ui_bold_font)
	banner.add_theme_font_size_override("font_size", 22)
	banner.add_theme_color_override("font_color", profile["banner"])
	banner.add_theme_color_override("font_outline_color", Color(0.0, 0.04, 0.08, 1.0))
	banner.add_theme_constant_override("outline_size", 2)
	feedback_root.add_child(banner)
	var tween := create_tween()
	banner.scale = Vector2(0.92, 0.92)
	tween.tween_property(banner, "scale", Vector2(1.0, 1.0), 0.11)
	tween.tween_interval(0.24)
	tween.tween_property(banner, "modulate:a", 0.0, 0.16)
	tween.parallel().tween_property(back, "modulate:a", 0.0, 0.16)
	tween.tween_callback(banner.queue_free)
	tween.tween_callback(back.queue_free)

func _show_skill_vfx(from: Vector2, to: Vector2, profile: Dictionary) -> float:
	var side := 1.0 if to.x >= from.x else -1.0
	var from_anchor := from + Vector2(25.0 * side, -12.0)
	var to_anchor := to + Vector2(-16.0 * side, -14.0)
	var travel := to_anchor - from_anchor
	var travel_distance := travel.length()
	var tint: Color = profile["tint"]
	var signature := String(profile.get("signature", ""))
	var hero_id := String(profile.get("hero_id", ""))
	var personal_mode := _personal_vfx_runtime_mode(profile)
	var personal_key := String(profile.get("personal_vfx", ""))
	var is_v101 := _is_v101_personal_profile(profile)
	var is_v102 := _is_v102_personal_profile(profile)
	var is_v103 := _is_v103_personal_profile(profile)
	var is_v104 := _is_v104_personal_profile(profile)
	var is_priority_personal := is_v102 or is_v103 or is_v104
	if signature == "blossom":
		var support_center := from + Vector2(0.0, -30.0)
		_spawn_vfx_sheet_animation("release_flash_v53", from + Vector2(0.0, -18.0), SKILL_RELEASE_FLASH_FRAMES, 48.0, 2118, 0.038, 0.0, tint)
		if personal_key != "":
			var blossom_size := 96.0 if is_v101 else 86.0
			var blossom_alpha := 0.94 if is_v101 else 0.88
			var blossom_step := 0.068 if is_v101 else 0.055
			if hero_id == "B05_KINNARA_RAVIKAN":
				blossom_size = 104.0
				blossom_alpha = 0.92
				blossom_step = 0.068
			_spawn_vfx_sheet_animation(personal_key, support_center, PERSONAL_VFX_FRAMES, blossom_size, 2134, blossom_step, 0.0, Color(1.0, 1.0, 1.0, blossom_alpha), Vector2(0.0, -8.0), false)
		if hero_id == "C04_HUMAN_CHABA":
			_show_chaba_blossom_path(from_anchor, to_anchor, tint, side, 0.34)
		_add_ring_vfx(from + Vector2(0.0, -16.0), 28.0, Color(tint.r, tint.g, tint.b, 0.22))
		return 0.32 if is_v101 else 0.22
	var release_direction := travel.normalized() if travel_distance > 0.0 else Vector2.RIGHT
	var release_size := clampf(float(profile.get("release_size", 280.0)) * 0.18, 38.0, 52.0)
	if signature == "naga" or signature == "pulse":
		release_size = clampf(float(profile.get("release_size", 280.0)) * 0.22, 48.0, 62.0)
		_show_storm_cast_origin(from_anchor, side)
	_spawn_vfx_sheet_animation("release_flash_v53", from_anchor, SKILL_RELEASE_FLASH_FRAMES, release_size, 2118, 0.038, release_direction.angle(), tint)
	var projectile_duration := clampf(travel_distance / 1850.0, 0.22, 0.34)
	if is_priority_personal:
		projectile_duration = clampf(travel_distance / 1650.0, 0.30, 0.42)
	if personal_mode == "leaf_projectile":
		projectile_duration = maxf(projectile_duration, 0.46)
	if personal_key != "":
		if personal_mode == "v104_garuda_talon":
			var slash_duration := clampf(travel_distance / 1320.0, 0.36, 0.48)
			var personal_start := from_anchor.lerp(to_anchor, 0.04)
			var personal_end := from_anchor.lerp(to_anchor, 0.90)
			_spawn_skill_travel_motes(from_anchor, to_anchor, Color(1.0, 0.82, 0.28, 0.78), slash_duration, "garuda")
			_spawn_vfx_sheet_animation(personal_key, personal_start, PERSONAL_VFX_FRAMES, 108.0, 2140, slash_duration / float(PERSONAL_VFX_FRAMES), release_direction.angle(), Color(1.0, 1.0, 1.0, 0.98), personal_end - personal_start, false)
			return slash_duration
		if personal_mode == "pulse_hold":
			var pulse_duration := clampf(travel_distance / 1500.0, 0.36, 0.46)
			_spawn_skill_travel_motes(from_anchor, to_anchor, tint, pulse_duration, signature)
			_spawn_vfx_sheet_animation(personal_key, from_anchor + Vector2(16.0 * side, -4.0), PERSONAL_VFX_FRAMES, 82.0, 2140, 0.062, 0.0, Color(1.0, 1.0, 1.0, 0.78), Vector2(12.0 * side, -2.0), false)
			var pulse_start := from_anchor.lerp(to_anchor, 0.16)
			var pulse_end := from_anchor.lerp(to_anchor, 0.84)
			_spawn_vfx_sheet_animation(personal_key, pulse_start, PERSONAL_VFX_FRAMES, 86.0, 2141, pulse_duration / float(PERSONAL_VFX_FRAMES), release_direction.angle(), Color(1.0, 1.0, 1.0, 0.90), pulse_end - pulse_start, false)
			return pulse_duration
		if personal_mode == "melee_seal":
			var seal_center := to_anchor + Vector2(-8.0 * side, -5.0)
			_spawn_vfx_sheet_animation(personal_key, seal_center, PERSONAL_VFX_FRAMES, 92.0, 2140, 0.070, 0.0, Color(1.0, 1.0, 1.0, 0.96), Vector2(5.0 * side, -2.0), false)
			return 0.24
		if personal_mode == "melee_guard":
			var guard_center := to_anchor + Vector2(-10.0 * side, 2.0)
			_spawn_vfx_sheet_animation(personal_key, guard_center, PERSONAL_VFX_FRAMES, 82.0, 2140, 0.066, 0.0, Color(1.0, 1.0, 1.0, 0.92), Vector2(5.0 * side, -2.0), false)
			return 0.25
		if personal_mode == "target_seal" or personal_mode == "target_seal_compact":
			var seal_duration := 0.34 if personal_mode == "target_seal_compact" else 0.38
			var seal_size := 86.0 if personal_mode == "target_seal_compact" else 108.0
			var seal_offset := Vector2(0.0, -4.0) if personal_mode == "target_seal_compact" else Vector2(0.0, -8.0)
			var seal_step := 0.074 if personal_mode == "target_seal_compact" else 0.088
			_spawn_skill_travel_motes(from_anchor, to_anchor, tint, seal_duration, signature)
			_spawn_vfx_sheet_animation(personal_key, to_anchor + seal_offset, PERSONAL_VFX_FRAMES, seal_size, 2140, seal_step, 0.0, Color.WHITE, Vector2(0.0, -2.0), false)
			return seal_duration
		if personal_mode == "melee_cleave":
			var cut_center := to_anchor + Vector2(-12.0 * side, -3.0)
			_spawn_vfx_sheet_animation(personal_key, cut_center, PERSONAL_VFX_FRAMES, 106.0, 2140, 0.074, 0.0, Color.WHITE, Vector2(6.0 * side, -2.0), false)
			return 0.28
		if personal_mode == "melee_thrust":
			var thrust_start := from_anchor.lerp(to_anchor, 0.58)
			var thrust_end := to_anchor + Vector2(-10.0 * side, -2.0)
			_spawn_vfx_sheet_animation(personal_key, thrust_start, PERSONAL_VFX_FRAMES, 82.0, 2140, 0.050, release_direction.angle(), Color(1.0, 1.0, 1.0, 0.96), thrust_end - thrust_start, false)
			return 0.24
		if personal_mode == "thorn_path":
			var thorn_duration := clampf(travel_distance / 1480.0, 0.36, 0.48)
			_spawn_skill_travel_motes(from_anchor, to_anchor, Color(0.62, 1.0, 0.42, 0.82), thorn_duration, "summon")
			var thorn_start := from_anchor.lerp(to_anchor, 0.10)
			var thorn_end := from_anchor.lerp(to_anchor, 0.86)
			_spawn_vfx_sheet_animation(personal_key, thorn_start, PERSONAL_VFX_FRAMES, 84.0, 2140, thorn_duration / float(PERSONAL_VFX_FRAMES), release_direction.angle(), Color(1.0, 1.0, 1.0, 0.96), thorn_end - thorn_start, false)
			_spawn_vfx_sheet_animation(personal_key, to_anchor + Vector2(-10.0 * side, -8.0), PERSONAL_VFX_FRAMES, 102.0, 2142, 0.070, 0.0, Color(1.0, 1.0, 1.0, 0.90), Vector2(0.0, -4.0), false)
			return thorn_duration
		if personal_mode == "paper_hex":
			var hex_duration := clampf(travel_distance / 1560.0, 0.34, 0.46)
			_spawn_skill_travel_motes(from_anchor, to_anchor, Color(1.0, 0.78, 0.34, 0.76), hex_duration, "hex")
			var paper_start := from_anchor.lerp(to_anchor, 0.16)
			var paper_end := from_anchor.lerp(to_anchor, 0.88)
			_spawn_vfx_sheet_animation(personal_key, paper_start, PERSONAL_VFX_FRAMES, 78.0, 2140, hex_duration / float(PERSONAL_VFX_FRAMES), release_direction.angle(), Color(1.0, 1.0, 1.0, 0.94), paper_end - paper_start, false)
			_spawn_vfx_sheet_animation(personal_key, to_anchor + Vector2(-8.0 * side, -10.0), PERSONAL_VFX_FRAMES, 96.0, 2142, 0.066, 0.0, Color(1.0, 0.96, 0.78, 0.92), Vector2(0.0, -3.0), false)
			return hex_duration
		if personal_mode == "bow_release":
			_spawn_vfx_sheet_animation(personal_key, from_anchor + Vector2(14.0 * side, -5.0), PERSONAL_VFX_FRAMES, 64.0, 2140, 0.050, release_direction.angle(), Color(1.0, 1.0, 1.0, 0.88), Vector2(6.0 * side, -2.0), false)
			personal_key = ""
	if bool(profile.get("show_streak", true)):
		var start := from_anchor.lerp(to_anchor, 0.08)
		var end := from_anchor.lerp(to_anchor, 0.86)
		var projectile_size := clampf(travel_distance * float(profile["streak_scale"]) * 0.15, 50.0, 76.0)
		_spawn_vfx_sheet_animation("projectile_trail_v52", start, SKILL_PROJECTILE_TRAIL_FRAMES, projectile_size, 2112, projectile_duration / float(SKILL_PROJECTILE_TRAIL_FRAMES), release_direction.angle(), tint, end - start)
	else:
		_spawn_skill_travel_motes(from_anchor, to_anchor, tint, projectile_duration, signature)
	if personal_key != "":
		var start_ratio := 0.10 if is_priority_personal else 0.18
		var end_ratio := 0.88 if is_priority_personal else 0.82
		if personal_mode == "leaf_projectile":
			start_ratio = 0.02
			end_ratio = 0.94
		var personal_start := from_anchor.lerp(to_anchor, start_ratio)
		var personal_end := from_anchor.lerp(to_anchor, end_ratio)
		var personal_size := 58.0
		var personal_alpha := 0.62
		if ["arrow", "spear", "dart", "shot"].has(signature):
			personal_size = clampf(travel_distance * 0.105, 48.0, 68.0)
			personal_alpha = 0.78
		elif ["garuda", "tiger", "slash", "blow"].has(signature):
			personal_size = 72.0
			personal_alpha = 0.70
		elif ["guard", "aegis"].has(signature):
			personal_size = 66.0
			personal_alpha = 0.52
		if is_priority_personal:
			if ["arrow", "spear", "dart", "shot"].has(signature):
				personal_size = clampf(travel_distance * 0.120, 62.0, 82.0)
			else:
				personal_size = maxf(personal_size, 78.0)
			personal_alpha = 0.92
		if personal_mode == "leaf_projectile":
			personal_size = clampf(travel_distance * 0.138, 76.0, 96.0)
			personal_alpha = 1.0
		_spawn_vfx_sheet_animation(personal_key, personal_start, PERSONAL_VFX_FRAMES, personal_size, 2134, maxf(projectile_duration / float(PERSONAL_VFX_FRAMES), 0.044 if is_priority_personal else 0.032), release_direction.angle(), Color(1.0, 1.0, 1.0, personal_alpha), personal_end - personal_start, false)
	return projectile_duration

func _spawn_skill_travel_motes(from_anchor: Vector2, to_anchor: Vector2, tint: Color, duration: float, signature: String) -> void:
	var travel := to_anchor - from_anchor
	if travel.length() < 8.0:
		return
	var normal := Vector2(-travel.y, travel.x).normalized()
	var is_storm := signature == "naga" or signature == "pulse"
	var mote_count := 11 if is_storm else 8
	var lane_width := 7.0 if is_storm else 5.5
	var alpha_boost := 1.0 if is_storm else 0.88
	for i in range(mote_count):
		var start_t := 0.07 + float(i) * (0.042 if is_storm else 0.055)
		var end_t := minf(start_t + (0.54 if is_storm else 0.48), 0.95)
		var lane := float((i % 4) - 1.5) * lane_width
		var mote := Polygon2D.new()
		var size := (5.2 if is_storm else 4.2) + float(i % 3) * 1.25
		mote.position = from_anchor.lerp(to_anchor, start_t) + normal * lane
		mote.z_index = 2114 + i
		mote.color = Color(tint.r, tint.g, tint.b, alpha_boost)
		if i % 2 == 0:
			mote.color = Color(1.0, 0.88, 0.36, alpha_boost)
		mote.polygon = PackedVector2Array([
			Vector2(0, -size),
			Vector2(size, 0),
			Vector2(0, size),
			Vector2(-size, 0),
		])
		feedback_root.add_child(mote)
		mote.scale = Vector2(0.62, 0.62)
		var tween := create_tween()
		tween.tween_interval(float(i) * 0.014)
		tween.tween_property(mote, "position", from_anchor.lerp(to_anchor, end_t) + normal * lane * 0.42, maxf(duration * 0.82, 0.18)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(mote, "scale", Vector2(1.18, 1.0), maxf(duration * 0.50, 0.11))
		tween.parallel().tween_property(mote, "modulate:a", 0.0, maxf(duration * 0.82, 0.18))
		tween.tween_callback(mote.queue_free)
	if is_storm:
		_spawn_storm_travel_clusters(from_anchor, to_anchor, tint, duration)

func _spawn_storm_travel_clusters(from_anchor: Vector2, to_anchor: Vector2, tint: Color, duration: float) -> void:
	var travel := to_anchor - from_anchor
	if travel.length() < 8.0:
		return
	var normal := Vector2(-travel.y, travel.x).normalized()
	var direction := travel.normalized()
	for cluster_i in range(5):
		var t := 0.18 + float(cluster_i) * 0.15
		var base := from_anchor.lerp(to_anchor, t)
		var drift := direction * (16.0 + float(cluster_i % 2) * 5.0)
		for shard_i in range(3):
			var lane := float(shard_i - 1) * (5.0 + float(cluster_i % 2) * 1.5)
			var shard := Polygon2D.new()
			shard.position = base + normal * lane - direction * float(shard_i) * 5.0
			shard.z_index = 2130 + cluster_i * 3 + shard_i
			shard.color = Color(0.66, 1.0, 1.0, 0.92) if shard_i != 1 else Color(1.0, 0.88, 0.34, 0.86)
			var size := 4.2 + float((cluster_i + shard_i) % 3) * 1.1
			shard.polygon = PackedVector2Array([
				Vector2(0, -size),
				Vector2(size, 0),
				Vector2(0, size),
				Vector2(-size, 0),
			])
			feedback_root.add_child(shard)
			shard.scale = Vector2(0.48, 0.48)
			var tween := create_tween()
			tween.tween_interval(float(cluster_i) * 0.016 + float(shard_i) * 0.012)
			tween.tween_property(shard, "position", base + drift + normal * lane * 0.45, maxf(duration * 0.36, 0.12)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(shard, "scale", Vector2(1.12, 0.90), maxf(duration * 0.22, 0.08))
			tween.parallel().tween_property(shard, "modulate:a", 0.0, maxf(duration * 0.48, 0.14))
			tween.tween_callback(shard.queue_free)

func _show_chaba_blossom_path(from_anchor: Vector2, to_anchor: Vector2, tint: Color, side: float, duration: float) -> void:
	var travel := to_anchor - from_anchor
	if travel.length() < 8.0:
		return
	var normal := Vector2(-travel.y, travel.x).normalized()
	var petal_color := Color(1.0, 0.70, 0.82, 0.78)
	var leaf_color := Color(tint.r, tint.g, tint.b, 0.54)
	for i in range(7):
		var start_t := 0.10 + float(i) * 0.07
		var end_t := minf(start_t + 0.32, 0.92)
		var lane := float((i % 3) - 1) * 7.0
		var petal := _vfx_line(1.7, petal_color if i % 2 == 0 else leaf_color, 2136 + i)
		petal.points = PackedVector2Array([
			from_anchor.lerp(to_anchor, start_t) + normal * lane,
			from_anchor.lerp(to_anchor, end_t) + normal * lane * 0.35 + Vector2(6.0 * side, -3.0),
		])
		_fade_free(petal, duration + float(i % 3) * 0.025)
	for i in range(3):
		var t := 0.34 + float(i) * 0.18
		_spawn_pixel_diamond(
			from_anchor.lerp(to_anchor, t) + normal * float(i - 1) * 6.0,
			Color(1.0, 0.90, 0.46, 0.58),
			2144 + i,
			3.6,
			duration * 0.72
		)

func _show_chaba_blossom_landing(center: Vector2, tint: Color, side: float) -> void:
	_add_ring_vfx(center + Vector2(0.0, 8.0), 24.0, Color(1.0, 0.72, 0.82, 0.20))
	for i in range(9):
		var angle := -0.85 + float(i) * 0.21
		var petal := _vfx_line(1.6, Color(1.0, 0.74, 0.86, 0.70), 2180 + i)
		petal.points = PackedVector2Array([
			center + Vector2(-6.0 * side, 2.0),
			center + Vector2(cos(angle) * 36.0 * side, -12.0 + sin(angle) * 22.0),
		])
		_fade_free(petal, 0.18 + float(i % 3) * 0.025)
	for i in range(4):
		_spawn_pixel_diamond(
			center + Vector2((-15.0 + float(i) * 10.0) * side, -18.0 + float(i % 2) * 10.0),
			Color(tint.r, tint.g, tint.b, 0.72),
			2192,
			4.0,
			0.20
		)

func _show_storm_cast_origin(center: Vector2, side: float) -> void:
	for wave_i in range(2):
		var wave := _vfx_line(1.8 - float(wave_i) * 0.25, Color(0.62, 1.0, 1.0, 0.66 - float(wave_i) * 0.12), 2119)
		var points := PackedVector2Array()
		for point_i in range(5):
			var t := float(point_i) / 4.0
			points.append(center + Vector2(lerpf(-15.0, 22.0, t) * side, -8.0 + float(wave_i) * 9.0 + sin(t * PI * 1.5) * 4.0))
		wave.points = points
		_fade_free(wave, 0.20 + float(wave_i) * 0.04)
	for shard_i in range(5):
		var offset := Vector2(float(shard_i - 2) * 5.5 * side, -11.0 + float(shard_i % 3) * 7.0)
		var color := Color(0.74, 1.0, 1.0, 0.92) if shard_i % 2 == 0 else Color(1.0, 0.88, 0.34, 0.84)
		_spawn_pixel_diamond(center + offset, color, 2120, 3.8 + float(shard_i % 2) * 1.2, 0.18 + float(shard_i) * 0.012)

func _show_skill_impact_vfx(from: Vector2, to: Vector2, profile: Dictionary) -> void:
	var side := 1.0 if to.x >= from.x else -1.0
	var from_anchor := from + Vector2(25.0 * side, -12.0)
	var to_anchor := to + Vector2(-7.0 * side, -20.0)
	var tint: Color = profile["tint"]
	var signature := String(profile.get("signature", ""))
	var hero_id := String(profile.get("hero_id", ""))
	var personal_mode := _personal_vfx_runtime_mode(profile)
	var is_v101 := _is_v101_personal_profile(profile)
	var is_v102 := _is_v102_personal_profile(profile)
	var is_v103 := _is_v103_personal_profile(profile)
	var is_v104 := _is_v104_personal_profile(profile)
	var is_priority_personal := is_v102 or is_v103 or is_v104
	if signature == "blossom":
		var personal_key := String(profile.get("personal_vfx", ""))
		var support_center := from + Vector2(0.0, -30.0)
		_add_skill_vfx_backdrop(support_center, tint, side, signature)
		if personal_key != "":
			var support_size := 106.0 if is_v101 else 96.0
			var support_step := 0.074 if is_v101 else 0.064
			if hero_id == "B05_KINNARA_RAVIKAN":
				support_size = 108.0
				support_step = 0.074
			_spawn_vfx_sheet_animation(personal_key, support_center + Vector2(0.0, 2.0), PERSONAL_VFX_FRAMES, support_size, 2172, support_step, 0.0, Color.WHITE, Vector2(0.0, -6.0), false)
		if hero_id == "C04_HUMAN_CHABA":
			_show_chaba_blossom_landing(to_anchor, tint, side)
		_add_ring_vfx(from + Vector2(0.0, -16.0), 31.0, Color(tint.r, tint.g, tint.b, 0.20))
		_show_signature_contact_pop(support_center, profile, side)
		return
	var restrained_signatures := ["pulse", "guard", "blossom", "bind", "summon", "naga", "aegis"]
	var impact_scale := 0.15 if restrained_signatures.has(signature) else 0.17
	var impact_size := clampf(float(profile["impact_size"]) * impact_scale, 46.0, 64.0)
	var impact_angle := (to_anchor - from_anchor).angle() + float(profile["impact_rotation"]) * 0.25
	var impact_alpha := 0.42 if restrained_signatures.has(signature) else 0.62
	var impact_tint := Color(tint.r, tint.g, tint.b, minf(tint.a, impact_alpha))
	if signature == "arrow":
		impact_tint = Color(1.0, 0.88, 0.32, impact_alpha)
	elif signature == "naga" or signature == "pulse":
		impact_tint = Color(0.58, 0.98, 1.0, impact_alpha)
	elif signature == "guard" or signature == "aegis":
		impact_tint = Color(1.0, 0.78, 0.28, impact_alpha)
	var personal_key := String(profile.get("personal_vfx", ""))
	if personal_key != "":
		if personal_mode == "v104_garuda_talon":
			var contact_center := to_anchor + Vector2(-8.0 * side, -2.0)
			_add_personal_impact_edge(contact_center, Color(1.0, 0.82, 0.28, 0.78), side, "garuda", impact_angle)
			_spawn_vfx_sheet_animation("impact_directional_hit_v52", contact_center, SKILL_IMPACT_BURST_FRAMES, 76.0, 2146, 0.054, impact_angle, Color(1.0, 0.78, 0.24, 0.44), Vector2.ZERO, true)
			_add_ring_vfx(to + Vector2(0, -12), 17.0, Color(1.0, 0.78, 0.24, 0.14))
			_show_signature_contact_pop(contact_center, profile, side)
			return
		if personal_mode == "bow_release":
			var arrow_contact := to_anchor + Vector2(-7.0 * side, 4.0)
			_spawn_vfx_sheet_animation("impact_directional_hit_v52", arrow_contact, SKILL_IMPACT_BURST_FRAMES, 66.0, 2146, 0.046, impact_angle, Color(1.0, 0.84, 0.34, 0.46), Vector2.ZERO, true)
			_add_ring_vfx(to + Vector2(0, -10), 14.0, Color(1.0, 0.78, 0.28, 0.12))
			_show_signature_contact_pop(arrow_contact, profile, side)
			return
		var personal_center := to_anchor + Vector2(0.0, -1.0)
		var contact_center := to_anchor + Vector2(0.0, 7.0)
		var personal_size := clampf(float(profile["impact_size"]) * 0.198, 72.0, 96.0)
		if signature == "aegis" or signature == "naga":
			personal_size = clampf(float(profile["impact_size"]) * 0.172, 68.0, 86.0)
		if is_priority_personal:
			personal_size = clampf(float(profile["impact_size"]) * 0.205, 86.0, 108.0)
			if signature == "guard" or signature == "aegis":
				personal_size = clampf(float(profile["impact_size"]) * 0.214, 92.0, 112.0)
		var personal_rotation := impact_angle
		var personal_step := 0.074 if is_priority_personal else 0.062
		var show_directional_contact := true
		if personal_mode == "pulse_hold":
			personal_center = to_anchor + Vector2(0.0, -8.0)
			personal_size = 116.0
			personal_rotation = 0.0
			personal_step = 0.090
		elif personal_mode == "target_seal" or personal_mode == "target_seal_compact":
			personal_center = to_anchor + (Vector2(0.0, -6.0) if personal_mode == "target_seal_compact" else Vector2(0.0, -10.0))
			personal_size = 88.0 if personal_mode == "target_seal_compact" else 112.0
			personal_rotation = 0.0
			personal_step = 0.074 if personal_mode == "target_seal_compact" else 0.092
			show_directional_contact = false
		elif personal_mode == "melee_cleave":
			personal_center = to_anchor + Vector2(-10.0 * side, -5.0)
			personal_size = 116.0
			personal_rotation = 0.0
			personal_step = 0.084
		elif personal_mode == "melee_thrust":
			personal_center = to_anchor + Vector2(-12.0 * side, -3.0)
			contact_center = to_anchor + Vector2(-7.0 * side, 4.0)
			personal_size = 92.0
			personal_rotation = impact_angle
			personal_step = 0.060
		elif personal_mode == "leaf_projectile":
			personal_center = to_anchor + Vector2(-6.0 * side, -6.0)
			personal_size = 106.0
			personal_step = 0.082
		elif personal_mode == "melee_seal":
			personal_center = to_anchor + Vector2(-7.0 * side, -8.0)
			personal_size = 90.0
			personal_rotation = 0.0
			personal_step = 0.078
			show_directional_contact = true
		elif personal_mode == "melee_guard":
			personal_center = to_anchor + Vector2(-8.0 * side, 1.0)
			contact_center = to_anchor + Vector2(-5.0 * side, 8.0)
			personal_size = 82.0
			personal_rotation = 0.0
			personal_step = 0.070
			show_directional_contact = true
		var contact_size := clampf(personal_size * 0.86, 58.0, 74.0)
		_add_skill_vfx_backdrop(personal_center, tint, side, signature)
		if show_directional_contact:
			_add_personal_impact_edge(personal_center, tint, side, signature, personal_rotation)
			_spawn_vfx_sheet_animation("impact_directional_hit_v52", contact_center, SKILL_IMPACT_BURST_FRAMES, contact_size, 2144, 0.046, personal_rotation, Color(tint.r, tint.g, tint.b, 0.30), Vector2.ZERO, true)
		_spawn_vfx_sheet_animation(personal_key, personal_center, PERSONAL_VFX_FRAMES, personal_size, 2172, personal_step, personal_rotation, Color.WHITE, Vector2.ZERO, false)
		_add_ring_vfx(to + Vector2(0, -12), 19.0, Color(tint.r, tint.g, tint.b, 0.14))
		_show_signature_contact_pop(personal_center, profile, side)
		return
	_spawn_vfx_sheet_animation("impact_directional_hit_v52", to_anchor, SKILL_IMPACT_BURST_FRAMES, impact_size, 2120, 0.045, impact_angle, impact_tint)
	_add_ring_vfx(to + Vector2(0, -8), 18.0, Color(tint.r, tint.g, tint.b, 0.16))
	_show_signature_vfx(to_anchor, profile, side)
	_show_hero_signature_accent(to_anchor, profile)
	_show_signature_contact_pop(to_anchor, profile, side)
	if signature == "naga" or signature == "pulse":
		_show_storm_body_splash(to_anchor + Vector2(0, 2), side)

func _add_skill_vfx_backdrop(center: Vector2, tint: Color, side: float, signature: String) -> void:
	var shadow := Polygon2D.new()
	shadow.position = center + Vector2(0.0, 12.0)
	shadow.z_index = 2141
	shadow.color = Color(0.0, 0.018, 0.020, 0.48)
	var width := 78.0
	var height := 26.0
	if signature == "slash" or signature == "garuda":
		width = 96.0
	elif signature == "arrow" or signature == "shot":
		width = 88.0
	var points := PackedVector2Array()
	for i in range(25):
		var angle := TAU * float(i) / 24.0
		points.append(Vector2(cos(angle) * width * 0.5, sin(angle) * height * 0.5))
	shadow.polygon = points
	shadow.scale = Vector2(0.58, 0.40)
	feedback_root.add_child(shadow)
	var shadow_tween := create_tween()
	shadow_tween.tween_property(shadow, "scale", Vector2(1.0, 0.76), 0.13).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	shadow_tween.tween_property(shadow, "modulate:a", 0.0, 0.24)
	shadow_tween.tween_callback(shadow.queue_free)

	var rim := _vfx_line(2.0, Color(tint.r, tint.g, tint.b, 0.28), 2142)
	rim.points = PackedVector2Array([
		center + Vector2(-42.0 * side, 15.0),
		center + Vector2(-12.0 * side, 20.0),
		center + Vector2(34.0 * side, 13.0),
	])
	_fade_free(rim, 0.20)

func _add_personal_impact_edge(center: Vector2, tint: Color, side: float, signature: String, angle: float) -> void:
	var edge_color := Color(1.0, 0.88, 0.32, 0.70)
	var accent_color := Color(tint.r, tint.g, tint.b, 0.54)
	match signature:
		"arrow", "shot", "spear", "dart":
			var shaft := _vfx_line(2.8, edge_color, 2182)
			shaft.points = PackedVector2Array([
				center + Vector2(-56.0 * side, 3.0),
				center + Vector2(50.0 * side, -16.0),
			])
			_fade_free(shaft, 0.18)
			var head_a := _vfx_line(2.0, Color(1.0, 0.96, 0.58, 0.66), 2183)
			head_a.points = PackedVector2Array([
				center + Vector2(50.0 * side, -16.0),
				center + Vector2(34.0 * side, -7.0),
			])
			_fade_free(head_a, 0.16)
			var head_b := _vfx_line(2.0, Color(1.0, 0.96, 0.58, 0.62), 2183)
			head_b.points = PackedVector2Array([
				center + Vector2(50.0 * side, -16.0),
				center + Vector2(34.0 * side, -26.0),
			])
			_fade_free(head_b, 0.16)
		"slash", "garuda", "tiger", "blow":
			for arc_i in range(2):
				var arc := _vfx_line(3.0 - float(arc_i) * 0.7, edge_color if arc_i == 0 else accent_color, 2182 + arc_i)
				var points := PackedVector2Array()
				for p_i in range(7):
					var t := float(p_i) / 6.0
					points.append(center + Vector2(lerpf(-48.0, 52.0, t) * side, -28.0 + sin(t * PI) * 34.0 + float(arc_i) * 9.0))
				arc.points = points
				_fade_free(arc, 0.18 + float(arc_i) * 0.03)
		"aegis", "guard":
			var plate := _vfx_line(2.8, edge_color, 2182)
			plate.points = PackedVector2Array([
				center + Vector2(-34.0, -24.0),
				center + Vector2(0.0, -34.0),
				center + Vector2(34.0, -24.0),
				center + Vector2(28.0, 18.0),
				center + Vector2(0.0, 30.0),
				center + Vector2(-28.0, 18.0),
				center + Vector2(-34.0, -24.0),
			])
			_fade_free(plate, 0.20)
		"naga", "pulse", "bind":
			for strand_i in range(2):
				var strand := _vfx_line(2.2 - float(strand_i) * 0.45, Color(0.62, 1.0, 1.0, 0.62 - float(strand_i) * 0.14), 2182 + strand_i)
				var points := PackedVector2Array()
				for p_i in range(9):
					var t := float(p_i) / 8.0
					points.append(center + Vector2(lerpf(-42.0, 42.0, t) * side, -20.0 + float(strand_i) * 20.0 + sin(t * TAU * 1.15) * 13.0))
				strand.points = points
				_fade_free(strand, 0.22)
		"seal", "hex":
			var glyph := _vfx_line(2.4, Color(0.98, 0.78, 1.0, 0.76), 2182)
			glyph.points = PackedVector2Array([
				center + Vector2(0.0, -36.0),
				center + Vector2(30.0 * side, -18.0),
				center + Vector2(26.0 * side, 18.0),
				center + Vector2(0.0, 34.0),
				center + Vector2(-26.0 * side, 18.0),
				center + Vector2(-30.0 * side, -18.0),
				center + Vector2(0.0, -36.0),
			])
			_fade_free(glyph, 0.24)
			for cut_i in range(3):
				var cut := _vfx_line(2.0, Color(1.0, 0.86, 0.32, 0.70 - float(cut_i) * 0.08), 2183 + cut_i)
				var y := -16.0 + float(cut_i) * 15.0
				cut.points = PackedVector2Array([
					center + Vector2(-24.0 * side, y + 8.0),
					center + Vector2(0.0, y - 2.0),
					center + Vector2(27.0 * side, y + 4.0),
				])
				_fade_free(cut, 0.18 + float(cut_i) * 0.02)
		_:
			var mark := _vfx_line(2.6, edge_color, 2182)
			mark.points = PackedVector2Array([
				center + Vector2(-40.0 * side, -20.0),
				center + Vector2(38.0 * side, 18.0),
			])
			_fade_free(mark, 0.18)
	for i in range(3):
		var t := float(i) / 2.0
		_spawn_pixel_diamond(center + Vector2(lerpf(-24.0, 26.0, t) * side, -21.0 + float(i % 2) * 18.0), Color(1.0, 0.88, 0.30, 0.58), 2184, 3.8 + float(i) * 0.8, 0.16)

func _uses_impact_texture(profile: Dictionary) -> bool:
	return false

func _show_signature_vfx(center: Vector2, profile: Dictionary, side: float) -> void:
	var tint: Color = profile["tint"]
	var index := int(profile.get("variant_index", 0))
	match String(profile.get("signature", "")):
		"burst":
			_spawn_vfx_sprite("sig_arrow_fan", center + Vector2(8, -8), 82.0, 2135, 0.26, 0.62, 0.20, -0.10 + float(index % 5) * 0.035, tint)
			for i in range(3 + index % 3):
				var lane := -18.0 + float(i) * (12.0 + float(index % 2) * 2.0)
				var bolt := _vfx_line(1.8, Color(1.0, 0.86, 0.28, 0.62), 2138)
				bolt.points = PackedVector2Array([center + Vector2(-42, 10 - lane * 0.20), center + Vector2(42 + float(i % 2) * 10.0, lane - 14)])
				_fade_free(bolt, 0.16 + float(i) * 0.018)
				var head := _vfx_line(1.4, Color(1.0, 0.96, 0.58, 0.58), 2139)
				head.points = PackedVector2Array([center + Vector2(42 + float(i % 2) * 10.0, lane - 14), center + Vector2(28 + float(i % 2) * 8.0, lane - 8)])
				_fade_free(head, 0.16 + float(i) * 0.014)
		"spear":
			_spawn_vfx_sprite("sig_arrow_trajectory_v62", center + Vector2(2.0 * side, -10), 126.0, 2193, 0.20, 0.80, 0.32, 0.0 if side > 0.0 else PI, Color.WHITE, false)
			var shaft := _vfx_line(2.5, Color(1.0, 0.88, 0.28, 0.82), 2195)
			shaft.points = PackedVector2Array([center + Vector2(-58.0 * side, 2), center + Vector2(54.0 * side, -20)])
			_fade_free(shaft, 0.28)
			for i in range(2):
				var flare := _vfx_line(1.5, Color(0.66, 1.0, 1.0, 0.58), 2196)
				var offset := -8.0 + float(i) * 16.0
				flare.points = PackedVector2Array([center + Vector2(-16.0 * side, offset), center + Vector2(42.0 * side, -18 + offset * 0.35)])
				_fade_free(flare, 0.20)
		"dart":
			for i in range(4):
				var y := -18.0 + float(i) * 8.5
				var dart := _vfx_line(1.5, Color(0.74, 1.0, 1.0, 0.74), 2194)
				dart.points = PackedVector2Array([center + Vector2(-42.0 * side, y * 0.25), center + Vector2(34.0 * side, y)])
				_fade_free(dart, 0.18 + float(i % 2) * 0.02)
			_spawn_pixel_diamond(center + Vector2(18.0 * side, -10), Color(1.0, 0.90, 0.36, 0.86), 2196, 5.0, 0.20)
		"shot":
			_spawn_vfx_sprite("sig_arrow_fan", center + Vector2(4.0 * side, -8), 74.0, 2135, 0.20, 0.54, 0.18, 0.0 if side > 0.0 else PI, tint)
			for i in range(3):
				var shot := _vfx_line(2.0, Color(1.0, 0.82, 0.30, 0.78), 2194)
				var y := -14.0 + float(i) * 12.0
				shot.points = PackedVector2Array([center + Vector2(-34.0 * side, y * 0.20), center + Vector2(38.0 * side, y)])
				_fade_free(shot, 0.19 + float(i) * 0.018)
		"blow":
			for i in range(3):
				var wave := _vfx_line(2.3 - float(i) * 0.25, Color(1.0, 0.62, 0.20, 0.72 - float(i) * 0.10), 2140)
				var points := PackedVector2Array()
				for p_i in range(6):
					var t := float(p_i) / 5.0
					points.append(center + Vector2(lerpf(-34.0, 38.0, t) * side, -4.0 + float(i) * 9.0 + sin(t * PI) * 9.0))
				wave.points = points
				_fade_free(wave, 0.20 + float(i) * 0.03)
			for i in range(4):
				_spawn_pixel_diamond(center + Vector2((-22.0 + float(i) * 14.0) * side, 4.0 + float(i % 2) * 8.0), Color(1.0, 0.84, 0.30, 0.78), 2142, 4.8, 0.20)
		"slash":
			_spawn_vfx_sprite("sig_tiger", center + Vector2(0, -8), 88.0, 2135, 0.24, 0.58, 0.20, -0.20 + float(index % 4) * 0.08, tint)
			for i in range(4):
				var t := float(i) / 3.0
				var cut := _vfx_line(2.35, Color(1.0, 0.62, 0.20, 0.68), 2137)
				cut.points = PackedVector2Array([
					center + Vector2(-42 + t * 10.0, -24 + t * 20.0),
					center + Vector2(-10 + t * 18.0, -6 + t * 16.0),
					center + Vector2(42, 16 + t * 6.0)
				])
				_fade_free(cut, 0.19 + float(i) * 0.018)
		"pulse":
			_spawn_vfx_sprite("sig_naga_storm_v62", center + Vector2(0, -18), 112.0, 2139, 0.14, 0.58, 0.52, float(index % 4) * 0.08, Color(1.0, 1.0, 1.0, 0.58), false, 0.58)
			_spawn_vfx_sheet_animation("sig_naga_body_storm_v72", center + Vector2(0, -8), 6, 82.0, 2152, 0.046, 0.0, Color.WHITE)
			_show_naga_body_surge(center + Vector2(0, -4), side, 3, 0.64)
			return
			for i in range(9):
				var angle := -0.75 + float(i) * 0.19
				var pulse := _vfx_line(2.2, Color(0.58, 0.96, 1.0, 0.66), 2137)
				pulse.points = PackedVector2Array([
					center + Vector2(cos(angle) * 6.0, -2.0 + sin(angle) * 5.0),
					center + Vector2(cos(angle) * (34.0 + float(i % 3) * 5.0), -2.0 + sin(angle) * (20.0 + float(i % 2) * 4.0))
				])
				_fade_free(pulse, 0.15 + float(i % 3) * 0.025)
			for strand_i in range(2):
				var storm := _vfx_line(1.6 - float(strand_i) * 0.25, Color(0.62, 0.98, 1.0, 0.30 - float(strand_i) * 0.08), 2146)
				storm.position = center + Vector2(0, -8)
				var storm_points := PackedVector2Array()
				for p_i in range(17):
					var t := float(p_i) / 16.0
					var phase := float(strand_i) * PI + t * TAU * 1.15
					storm_points.append(Vector2(cos(phase) * (30.0 - t * 8.0), lerpf(22.0, -38.0, t)))
				storm.points = storm_points
				var storm_tween := create_tween()
				storm_tween.tween_property(storm, "rotation", (0.55 + float(strand_i) * 0.20) * side, 0.62).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				storm_tween.parallel().tween_property(storm, "scale", Vector2(1.18, 1.12), 0.62)
				storm_tween.parallel().tween_property(storm, "modulate:a", 0.0, 0.62)
				storm_tween.tween_callback(storm.queue_free)
		"guard":
			_spawn_vfx_sprite("sig_aegis_shield_v62", center + Vector2(0, -18), 134.0, 2141, 0.18, 0.90, 0.30, float(index % 5) * 0.04, Color(0.02, 0.04, 0.04, 0.62), false)
			_spawn_vfx_sprite("sig_aegis_shield_v62", center + Vector2(0, -18), 122.0, 2142, 0.18, 0.86, 0.30, float(index % 5) * 0.04, Color(1.0, 1.0, 1.0, 0.94), false)
			_show_aegis_barrier(center + Vector2(0, -12), 2145)
			for i in range(4):
				var y := -20.0 + float(i) * 13.0
				var plate := _vfx_line(2.6, Color(1.0, 0.84, 0.34, 0.68), 2143)
				var x0 := -30.0 + float(i % 2) * 8.0
				plate.points = PackedVector2Array([center + Vector2(x0, y), center + Vector2(x0 + 34.0, y - 7.0)])
				_fade_free(plate, 0.16 + float(i) * 0.02)
			var crack := _vfx_line(1.6, Color(tint.r, tint.g, tint.b, 0.46), 2138)
			crack.points = PackedVector2Array([center + Vector2(-20, 18), center + Vector2(-4, -10), center + Vector2(18, -24), center + Vector2(8, 16)])
			_fade_free(crack, 0.22)
		"blossom":
			_spawn_vfx_sprite("sig_kinnari", center + Vector2(1, -8), 78.0, 2135, 0.24, 0.58, 0.22, float(index % 3) * 0.05, tint)
			for i in range(5):
				var angle := -0.65 + float(i) * 0.32
				var petal := _vfx_line(1.7, Color(1.0, 0.92, 0.56, 0.50), 2137)
				petal.points = PackedVector2Array([center + Vector2(-8, 2 + float(i % 2) * 3.0), center + Vector2(26.0 + float(i) * 6.0, -12.0 + sin(angle) * 14.0)])
				_fade_free(petal, 0.20)
		"bind":
			_spawn_vfx_sprite("sig_naga", center + Vector2(-2, -2), 70.0, 2135, 0.22, 0.48, 0.22, -0.35 + float(index % 4) * 0.12, tint)
			for strand_i in range(3):
				var snare := _vfx_line(1.9, Color(0.58, 0.96, 1.0, 0.56), 2137)
				var bind_points := PackedVector2Array()
				for i in range(7):
					var t := float(i) / 6.0
					bind_points.append(center + Vector2(lerpf(-34.0, 36.0, t), -20.0 + float(strand_i) * 17.0 + sin(t * TAU * 1.35 + float(strand_i)) * 7.0))
				snare.points = bind_points
				_fade_free(snare, 0.20 + float(strand_i) * 0.03)
		"hex":
			for i in range(4):
				var cut_angle := -0.4 + float(i) * 0.28
				var seal := _vfx_line(1.6, Color(0.88, 0.62, 1.0, 0.54), 2137)
				seal.points = PackedVector2Array([
					center + Vector2(-26.0, -14.0 + float(i) * 9.0),
					center + Vector2(18.0 + float(i % 2) * 8.0, -18.0 + float(i) * 7.0).rotated(cut_angle * 0.12)
				])
				_fade_free(seal, 0.16 + float(i) * 0.02)
		"summon":
			_spawn_vfx_sprite("sig_spirit", center + Vector2(0, -6), 78.0, 2135, 0.24, 0.54, 0.24, float(index % 5) * 0.08, tint)
			for x in [-24.0, -8.0, 10.0, 26.0]:
				var wisp := _vfx_line(1.7, Color(tint.r, tint.g, tint.b, 0.52), 2137)
				wisp.points = PackedVector2Array([center + Vector2(x, 28), center + Vector2(x * 0.35, -18), center + Vector2(x * 0.12, -42)])
				_fade_free(wisp, 0.22)
		"garuda":
			_spawn_vfx_sprite("sig_garuda", center + Vector2(-4, -8), 110.0, 2135, 0.22, 0.70, 0.26, -0.08, tint)
			for i in range(6):
				var feather := _vfx_line(2.35 if i < 3 else 1.75, Color(1.0, 0.84, 0.26, 0.78), 2137)
				var spread := -52.0 + float(i) * 18.0
				feather.points = PackedVector2Array([
					center + Vector2(-8, 4),
					center + Vector2(spread * 0.36, -20 - absf(spread) * 0.08),
					center + Vector2(spread, -36 + absf(spread) * 0.18)
				])
				_fade_free(feather, 0.18 + float(i) * 0.012)
			var sun_cut := _vfx_line(2.4, Color(0.50, 1.0, 1.0, 0.54), 2138)
			sun_cut.points = PackedVector2Array([center + Vector2(-40, 8), center + Vector2(36, -22), center + Vector2(56, -10)])
			_fade_free(sun_cut, 0.20)
		"naga":
			_spawn_vfx_sprite("sig_naga_storm_v62", center + Vector2(0, -20), 120.0, 2139, 0.14, 0.62, 0.56, 0.04, Color(1.0, 1.0, 1.0, 0.62), false, 0.70)
			_spawn_vfx_sheet_animation("sig_naga_body_storm_v72", center + Vector2(0, -8), 6, 92.0, 2152, 0.046, 0.0, Color.WHITE)
			_show_naga_body_surge(center + Vector2(0, -4), side, 4, 0.78)
			return
			var serpent := _vfx_line(3.0, Color(0.56, 0.98, 1.0, 0.76), 2137)
			var points := PackedVector2Array()
			for i in range(13):
				var t := float(i) / 12.0
				points.append(center + Vector2(lerpf(-58.0, 48.0, t), -14.0 + sin(t * TAU * 1.5) * 16.0))
			serpent.points = points
			_fade_free(serpent, 0.30)
			var lower_serpent := _vfx_line(2.4, Color(0.82, 1.0, 1.0, 0.58), 2138)
			var lower_points := PackedVector2Array()
			for i in range(11):
				var t := float(i) / 10.0
				lower_points.append(center + Vector2(lerpf(-42.0, 42.0, t), 8.0 + sin(t * TAU * 1.25 + 0.8) * 13.0))
			lower_serpent.points = lower_points
			_fade_free(lower_serpent, 0.26)
			for i in range(5):
				var fang := _vfx_line(1.4, Color(0.72, 1.0, 1.0, 0.46), 2138)
				fang.points = PackedVector2Array([center + Vector2(-18 + float(i) * 10.0, -4), center + Vector2(-8 + float(i) * 12.0, 14 + float(i % 2) * 4.0)])
				_fade_free(fang, 0.18 + float(i) * 0.01)
			for strand_i in range(3):
				var storm := _vfx_line(1.7 - float(strand_i) * 0.22, Color(0.60, 0.98, 1.0, 0.34 - float(strand_i) * 0.08), 2146)
				storm.position = center + Vector2(0, -8)
				var storm_points := PackedVector2Array()
				for p_i in range(19):
					var t := float(p_i) / 18.0
					var phase := float(strand_i) * TAU / 3.0 + t * TAU * 1.30
					storm_points.append(Vector2(cos(phase) * (34.0 - t * 9.0), lerpf(24.0, -42.0, t)))
				storm.points = storm_points
				var storm_tween := create_tween()
				storm_tween.tween_property(storm, "rotation", (0.65 + float(strand_i) * 0.16) * side, 0.66).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				storm_tween.parallel().tween_property(storm, "scale", Vector2(1.20, 1.14), 0.66)
				storm_tween.parallel().tween_property(storm, "modulate:a", 0.0, 0.66)
				storm_tween.tween_callback(storm.queue_free)
		"aegis":
			_spawn_vfx_sprite("sig_aegis_shield_v62", center + Vector2(0, -20), 154.0, 2141, 0.18, 0.94, 0.32, 0.0, Color(0.02, 0.04, 0.04, 0.66), false)
			_spawn_vfx_sprite("sig_aegis_shield_v62", center + Vector2(0, -20), 140.0, 2142, 0.18, 0.90, 0.32, 0.0, Color(1.0, 1.0, 1.0, 0.96), false)
			_show_aegis_barrier(center + Vector2(0, -14), 2145)
			for i in range(5):
				var shard := _vfx_line(2.4, Color(1.0, 0.84, 0.32, 0.68), 2143)
				var y := -24.0 + float(i) * 11.0
				shard.points = PackedVector2Array([center + Vector2(-26 + float(i % 2) * 7.0, y), center + Vector2(24 - float(i % 2) * 5.0, y - 5.0)])
				_fade_free(shard, 0.17 + float(i) * 0.02)
			for x in [-24.0, 0.0, 24.0]:
				var ward := _vfx_line(1.6, Color(1.0, 0.86, 0.36, 0.52), 2137)
				ward.points = PackedVector2Array([center + Vector2(x, -28), center + Vector2(x * 0.42, 24)])
				_fade_free(ward, 0.22)
		"tiger":
			_spawn_vfx_sprite("sig_tiger", center + Vector2(0, -8), 94.0, 2135, 0.26, 0.64, 0.22, 0.12, tint)
			for i in range(4):
				var claw := _vfx_line(2.55, Color(1.0, 0.30, 0.08, 0.76), 2137)
				var offset := float(i - 1) * 9.0
				claw.points = PackedVector2Array([
					center + Vector2(-44, -26 + offset),
					center + Vector2(-12, -8 + offset * 0.4),
					center + Vector2(40, 18 + offset)
				])
				_fade_free(claw, 0.20 + float(i) * 0.018)
			var ember := _vfx_line(1.4, Color(1.0, 0.78, 0.20, 0.48), 2138)
			ember.points = PackedVector2Array([center + Vector2(-22, 24), center + Vector2(34, 2)])
			_fade_free(ember, 0.18)
		"arrow":
			_spawn_vfx_sprite("sig_arrow_trajectory_v62", center + Vector2(4.0 * side, -10), 122.0, 2193, 0.22, 0.86, 0.36, 0.0 if side > 0.0 else PI, Color.WHITE, false)
			for i in range(5):
				var spread := float(i - 2) * 9.0
				var arrow := _vfx_line(2.15, Color(1.0, 0.88, 0.28, 0.78), 2194)
				arrow.points = PackedVector2Array([center + Vector2(-50.0 * side, -4 + spread * 0.35), center + Vector2(46.0 * side, -16 + spread)])
				_fade_free(arrow, 0.30 + float(abs(i - 2)) * 0.012)
				var head := _vfx_line(1.55, Color(1.0, 0.96, 0.56, 0.70), 2195)
				head.points = PackedVector2Array([center + Vector2(46.0 * side, -16 + spread), center + Vector2(32.0 * side, -10 + spread * 0.8)])
				_fade_free(head, 0.28)

func _show_naga_body_surge(center: Vector2, side: float, bands: int, alpha: float) -> void:
	for band_i in range(bands):
		var y := -22.0 + float(band_i) * 16.0
		var wave := _vfx_line(3.1 - float(band_i) * 0.35, Color(0.58, 0.98, 1.0, alpha - float(band_i) * 0.12), 2148)
		var points := PackedVector2Array()
		for point_i in range(7):
			var t := float(point_i) / 6.0
			points.append(center + Vector2(lerpf(-42.0, 42.0, t) * side, y + sin(t * PI * 1.5 + float(band_i) * 0.65) * 7.0))
		wave.points = points
		var glow := _vfx_line(1.6, Color(1.0, 0.88, 0.36, 0.54 - float(band_i) * 0.08), 2149)
		glow.points = PackedVector2Array([
			center + Vector2(-22.0 * side, y - 5.0),
			center + Vector2(7.0 * side, y + 1.0),
			center + Vector2(31.0 * side, y - 8.0),
		])
		var duration := 0.34 + float(band_i) * 0.045
		_fade_free(wave, duration)
		_fade_free(glow, duration * 0.82)
	for shard_i in range(8):
		var t := float(shard_i) / 7.0
		var shard_pos := center + Vector2(lerpf(-36.0, 36.0, t) * side, -25.0 + float(shard_i % 3) * 16.0 + sin(t * TAU) * 5.0)
		var color := Color(0.68, 1.0, 1.0, 0.90) if shard_i % 3 != 1 else Color(1.0, 0.88, 0.34, 0.82)
		_spawn_pixel_diamond(shard_pos, color, 2150, 5.0 + float(shard_i % 3) * 1.6, 0.26 + float(shard_i % 2) * 0.04)

func _show_storm_body_splash(center: Vector2, side: float) -> void:
	for band_i in range(3):
		var y := -19.0 + float(band_i) * 15.0
		var wave := _vfx_line(2.1 - float(band_i) * 0.24, Color(0.62, 1.0, 1.0, 0.72 - float(band_i) * 0.10), 2157)
		var points := PackedVector2Array()
		for point_i in range(6):
			var t := float(point_i) / 5.0
			points.append(center + Vector2(lerpf(-31.0, 33.0, t) * side, y + sin(t * TAU + float(band_i)) * 4.5))
		wave.points = points
		_fade_free(wave, 0.22 + float(band_i) * 0.035)
	for shard_i in range(6):
		var x := -24.0 + float(shard_i) * 9.5
		var color := Color(0.72, 1.0, 1.0, 0.94) if shard_i % 2 == 0 else Color(1.0, 0.88, 0.34, 0.82)
		_spawn_pixel_diamond(center + Vector2(x * side, -16.0 + float(shard_i % 3) * 13.0), color, 2159, 4.0 + float(shard_i % 2) * 1.5, 0.20 + float(shard_i % 3) * 0.025)

func _spawn_pixel_diamond(position: Vector2, color: Color, z: int, size: float, duration: float) -> void:
	var diamond := Polygon2D.new()
	diamond.position = position
	diamond.z_index = z
	diamond.color = color
	diamond.polygon = PackedVector2Array([
		Vector2(0, -size),
		Vector2(size, 0),
		Vector2(0, size),
		Vector2(-size, 0),
	])
	feedback_root.add_child(diamond)
	diamond.scale = Vector2(0.35, 0.35)
	var tween := create_tween()
	tween.tween_property(diamond, "scale", Vector2(1.08, 0.92), duration * 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(diamond, "modulate:a", 0.0, duration)
	tween.tween_callback(diamond.queue_free)

func _show_signature_contact_pop(center: Vector2, profile: Dictionary, side: float) -> void:
	var tint: Color = profile["tint"]
	var signature := String(profile.get("signature", ""))
	var core := Polygon2D.new()
	core.position = center + Vector2(0, -2)
	core.z_index = 2148
	core.color = Color(1.0, 0.96, 0.58, 0.84)
	core.polygon = PackedVector2Array([
		Vector2(0, -18),
		Vector2(5, -5),
		Vector2(22, 0),
		Vector2(5, 5),
		Vector2(0, 18),
		Vector2(-5, 5),
		Vector2(-22, 0),
		Vector2(-5, -5),
	])
	feedback_root.add_child(core)
	core.scale = Vector2(0.24, 0.24)
	var core_tween := create_tween()
	core_tween.tween_property(core, "scale", Vector2(1.35, 1.05), 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	core_tween.parallel().tween_property(core, "modulate:a", 0.0, 0.18)
	core_tween.tween_callback(core.queue_free)
	var spark_color := Color(tint.r, tint.g, tint.b, 0.72)
	match signature:
		"guard", "aegis":
			for i in range(6):
				var shard := _vfx_line(1.8, spark_color, 2147)
				var x := -30.0 + float(i) * 12.0
				shard.points = PackedVector2Array([center + Vector2(x * 0.35, -10), center + Vector2(x, 18.0 - absf(x) * 0.25)])
				_fade_free(shard, 0.16 + float(i % 2) * 0.03)
		"naga", "bind", "pulse":
			for i in range(4):
				var wave := _vfx_line(2.2, Color(0.58, 0.96, 1.0, 0.80), 2147)
				var points := PackedVector2Array()
				for p_i in range(5):
					var t := float(p_i) / 4.0
					points.append(center + Vector2(lerpf(-32.0, 34.0, t), -16.0 + float(i) * 8.0 + sin(t * PI * 2.0 + float(i)) * 6.0))
				wave.points = points
				_fade_free(wave, 0.34 + float(i) * 0.024)
		"blossom":
			for i in range(7):
				var angle := -0.7 + float(i) * 0.24
				var petal := _vfx_line(1.5, Color(1.0, 0.82, 0.86, 0.68), 2147)
				petal.points = PackedVector2Array([center + Vector2(-8, 4), center + Vector2(cos(angle) * 38.0, -8 + sin(angle) * 24.0)])
				_fade_free(petal, 0.15 + float(i % 3) * 0.02)
		"hex":
			for i in range(5):
				var curse := _vfx_line(1.7, Color(0.95, 0.40, 1.0, 0.72), 2147)
				var y := -24.0 + float(i) * 10.0
				curse.points = PackedVector2Array([center + Vector2(-34, y), center + Vector2(24, y - 9.0)])
				_fade_free(curse, 0.14 + float(i) * 0.015)
		_:
			for i in range(5):
				var ray := _vfx_line(1.7, spark_color, 2147)
				var y := -24.0 + float(i) * 12.0
				ray.points = PackedVector2Array([center + Vector2(-30.0 * side, y * 0.35), center + Vector2(38.0 * side, y)])
				_fade_free(ray, 0.14 + float(i) * 0.018)

func _show_hero_signature_accent(center: Vector2, profile: Dictionary) -> void:
	var tint: Color = profile["tint"]
	var index := int(profile.get("variant_index", 0))
	var radius := 18.0 + float(index % 8) * 1.8
	var base_angle := deg_to_rad(float((index * 47) % 360))
	var accent_color := Color(tint.r, tint.g, tint.b, 0.46)
	match index % 8:
		0:
			for i in range(3):
				var x := -18.0 + float(i) * 18.0
				var ray := _vfx_line(1.8, accent_color, 2140)
				ray.points = PackedVector2Array([center + Vector2(x * 0.35, -18), center + Vector2(x, -18 - radius * 0.55)])
				_fade_free(ray, 0.18)
		1:
			var underline := _vfx_line(2.0, accent_color, 2140)
			var points := PackedVector2Array()
			for i in range(7):
				var t := float(i) / 6.0
				points.append(center + Vector2(lerpf(-radius, radius, t), 20.0 + sin(t * PI) * 9.0))
			underline.points = points
			_fade_free(underline, 0.20)
		2:
			for angle in [base_angle, base_angle + PI * 0.5]:
				var seal := _vfx_line(1.7, accent_color, 2140)
				seal.points = PackedVector2Array([center + Vector2(-radius * 0.72, 0).rotated(angle), center + Vector2(radius * 0.72, 0).rotated(angle)])
				_fade_free(seal, 0.18)
		3:
			for i in range(2):
				var slash := _vfx_line(1.9, accent_color, 2140)
				var offset := float(i) * 9.0
				slash.points = PackedVector2Array([center + Vector2(-radius, -12 + offset), center + Vector2(radius * 0.55, 10 + offset)])
				_fade_free(slash, 0.17 + float(i) * 0.03)
		4:
			for i in range(4):
				var angle := base_angle - 0.75 + float(i) * 0.5
				var spark := _vfx_line(1.5, accent_color, 2140)
				spark.points = PackedVector2Array([center + Vector2(cos(angle) * 10.0, sin(angle) * 7.0), center + Vector2(cos(angle) * radius, sin(angle) * radius * 0.65)])
				_fade_free(spark, 0.16 + float(i) * 0.02)
		5:
			for i in range(3):
				var spear := _vfx_line(1.7, accent_color, 2140)
				var x := -10.0 + float(i) * 10.0
				spear.points = PackedVector2Array([center + Vector2(x, 18), center + Vector2(x * 0.35, -radius - float(i) * 3.0)])
				_fade_free(spear, 0.18 + float(i) * 0.02)
		6:
			for i in range(4):
				var angle := base_angle + float(i) * PI * 0.5
				var shard := _vfx_line(1.6, accent_color, 2140)
				shard.points = PackedVector2Array([center + Vector2(cos(angle) * 9.0, sin(angle) * 7.0), center + Vector2(cos(angle) * radius, sin(angle) * radius * 0.78)])
				_fade_free(shard, 0.17 + float(i % 2) * 0.02)
		7:
			var zig := _vfx_line(1.8, accent_color, 2140)
			zig.points = PackedVector2Array([center + Vector2(-radius, 12), center + Vector2(-radius * 0.35, -8), center + Vector2(radius * 0.28, 8), center + Vector2(radius, -14)])
			_fade_free(zig, 0.20)
func _show_aegis_barrier(center: Vector2, z: int) -> void:
	var barrier := _vfx_line(3.0, Color(1.0, 0.86, 0.34, 0.88), z)
	barrier.position = center
	barrier.points = PackedVector2Array([
		Vector2(0, -34),
		Vector2(30, -6),
		Vector2(22, 26),
		Vector2(0, 38),
		Vector2(-22, 26),
		Vector2(-30, -6),
		Vector2(0, -34),
	])
	var inner := _vfx_line(1.7, Color(1.0, 0.98, 0.58, 0.66), z + 1)
	inner.position = center
	inner.points = PackedVector2Array([
		Vector2(0, -22),
		Vector2(17, -4),
		Vector2(0, 22),
		Vector2(-17, -4),
		Vector2(0, -22),
	])
	barrier.scale = Vector2(0.70, 0.70)
	inner.scale = Vector2(0.64, 0.64)
	var tween := create_tween()
	tween.tween_property(barrier, "scale", Vector2(1.08, 1.02), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(barrier, "modulate:a", 0.0, 0.34)
	tween.parallel().tween_property(inner, "scale", Vector2(1.02, 0.98), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(inner, "modulate:a", 0.0, 0.32)
	tween.tween_callback(barrier.queue_free)
	tween.tween_callback(inner.queue_free)

func _vfx_line(width: float, color: Color, z: int) -> Line2D:
	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.z_index = z
	feedback_root.add_child(line)
	return line

func _fade_free(node: CanvasItem, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)
	tween.tween_callback(node.queue_free)

func _show_skill_cast_vfx(position: Vector2, profile: Dictionary, target_position := Vector2.ZERO) -> void:
	var side := 1.0 if target_position == Vector2.ZERO or target_position.x >= position.x else -1.0
	var aim := (target_position - position).normalized() if target_position != Vector2.ZERO and target_position.distance_to(position) > 0.0 else Vector2(side, 0.0)
	var anchor := position + Vector2(22 * side, -12)
	_spawn_vfx_sheet_animation("charge_hand_v51", anchor, SKILL_CHARGE_HAND_FRAMES, clampf(float(profile["cast_size"]) * 0.23, 40.0, 54.0), 2086, 0.048, 0.0, profile["tint"])
	var signature := String(profile.get("signature", ""))
	if signature == "guard" or signature == "aegis":
		_show_aegis_barrier(position + Vector2(0, -36), 2090)
	var personal_key := String(profile.get("personal_vfx", ""))
	if personal_key != "":
		var is_v101 := _is_v101_personal_profile(profile)
		var is_v102 := _is_v102_personal_profile(profile)
		var is_v103 := _is_v103_personal_profile(profile)
		var is_v104 := _is_v104_personal_profile(profile)
		var is_priority_personal := is_v102 or is_v103 or is_v104
		var personal_mode := _personal_vfx_runtime_mode(profile)
		var windup_size := 54.0
		if ["garuda", "tiger", "blow", "slash", "aegis", "guard"].has(signature):
			windup_size = 66.0
		elif ["arrow", "spear", "dart", "shot"].has(signature):
			windup_size = 58.0
		var windup_offset := Vector2(18.0 * side, -3.0)
		var windup_move := Vector2(18.0 * side, -3.0)
		var windup_rotation := aim.angle()
		var windup_alpha := 0.82
		if signature == "blossom":
			windup_size = 82.0 if is_v101 else 72.0
			windup_offset = Vector2(0.0, -18.0)
			windup_move = Vector2(0.0, -6.0)
			windup_rotation = 0.0
			windup_alpha = 0.84 if is_v101 else 0.74
		if is_priority_personal:
			windup_size = maxf(windup_size, 74.0)
			windup_alpha = 0.92
		match personal_mode:
			"v104_garuda_talon":
				windup_size = 52.0
				windup_offset = Vector2(16.0 * side, -8.0)
				windup_move = Vector2(8.0 * side, -2.0)
				windup_rotation = aim.angle()
				windup_alpha = 0.82
			"pulse_hold":
				windup_size = 94.0
				windup_offset = Vector2(10.0 * side, -14.0)
				windup_move = Vector2(4.0 * side, -4.0)
				windup_rotation = 0.0
				windup_alpha = 0.98
			"target_seal", "target_seal_compact":
				windup_size = 70.0 if personal_mode == "target_seal_compact" else 90.0
				windup_offset = Vector2(14.0 * side, -7.0) if personal_mode == "target_seal_compact" else Vector2(16.0 * side, -10.0)
				windup_move = Vector2(0.0, -3.0) if personal_mode == "target_seal_compact" else Vector2(0.0, -4.0)
				windup_rotation = 0.0
				windup_alpha = 0.88 if personal_mode == "target_seal_compact" else 0.96
			"melee_cleave":
				windup_size = 92.0
				windup_offset = Vector2(22.0 * side, -4.0)
				windup_move = Vector2(8.0 * side, -2.0)
				windup_rotation = 0.0
				windup_alpha = 0.96
			"melee_thrust":
				windup_size = 58.0
				windup_offset = Vector2(22.0 * side, -8.0)
				windup_move = Vector2(12.0 * side, -2.0)
				windup_rotation = aim.angle()
				windup_alpha = 0.90
			"leaf_projectile":
				windup_size = 86.0
				windup_alpha = 0.98
			"melee_seal":
				windup_size = 58.0
				windup_offset = Vector2(22.0 * side, -7.0)
				windup_move = Vector2(10.0 * side, -2.0)
				windup_rotation = aim.angle()
				windup_alpha = 0.90
			"melee_guard":
				windup_size = 58.0
				windup_offset = Vector2(20.0 * side, -2.0)
				windup_move = Vector2(8.0 * side, -1.0)
				windup_rotation = 0.0
				windup_alpha = 0.86
			"bow_release":
				windup_size = 56.0
				windup_offset = Vector2(18.0 * side, -6.0)
				windup_move = Vector2(8.0 * side, -2.0)
				windup_rotation = aim.angle()
				windup_alpha = 0.84
		_spawn_vfx_sheet_animation(personal_key, anchor + windup_offset, PERSONAL_VFX_FRAMES, windup_size, 2096, 0.040 if is_priority_personal or is_v101 else 0.028, windup_rotation, Color(1.0, 1.0, 1.0, windup_alpha), windup_move, false)
	_show_hero_cast_accent(anchor, profile)
	_add_ring_vfx(position + Vector2(0, -20), 24.0, Color(1.0, 0.78, 0.28, 0.26))

func _show_hero_cast_accent(center: Vector2, profile: Dictionary) -> void:
	var tint: Color = profile["tint"]
	var index := int(profile.get("variant_index", 0))
	var angle := deg_to_rad(float((index * 29) % 360))
	var accent := Color(tint.r, tint.g, tint.b, 0.58)
	match index % 8:
		0:
			for i in range(3):
				var local_angle := angle - 0.34 + float(i) * 0.34
				var spark := _vfx_line(1.5, accent, 2089)
				spark.points = PackedVector2Array([
					center + Vector2(cos(local_angle) * 7.0, sin(local_angle) * 4.0),
					center + Vector2(cos(local_angle) * (24.0 + float(index % 3) * 3.0), sin(local_angle) * (13.0 + float(index % 2) * 2.0))
				])
				_fade_free(spark, 0.18 + float(i) * 0.02)
		1:
			for i in range(2):
				var slash := _vfx_line(1.7, accent, 2089)
				var offset := float(i) * 7.0
				slash.points = PackedVector2Array([center + Vector2(-16, -10 + offset), center + Vector2(20 + float(index % 4) * 2.0, 6 + offset)])
				_fade_free(slash, 0.20 + float(i) * 0.02)
		2:
			var upper := _vfx_line(1.6, accent, 2089)
			upper.points = PackedVector2Array([center + Vector2(-10, -12), center + Vector2(0, -22), center + Vector2(18 + float(index % 3) * 2.0, -8)])
			_fade_free(upper, 0.22)
			var lower := _vfx_line(1.4, Color(1.0, 0.86, 0.38, 0.50), 2089)
			lower.points = PackedVector2Array([center + Vector2(-8, 8), center + Vector2(6, 16), center + Vector2(24, 4)])
			_fade_free(lower, 0.20)
		3:
			for i in range(4):
				var fleck_angle := angle + float(i) * 0.42
				var fleck := _vfx_line(1.3, accent, 2089)
				fleck.points = PackedVector2Array([
					center + Vector2(cos(fleck_angle) * 8.0, sin(fleck_angle) * 4.0),
					center + Vector2(cos(fleck_angle) * (16.0 + float(i) * 4.0), sin(fleck_angle) * (9.0 + float(i) * 2.0))
				])
				_fade_free(fleck, 0.15 + float(i) * 0.025)
		4:
			var wave := _vfx_line(1.6, accent, 2089)
			var points := PackedVector2Array()
			for i in range(6):
				var t := float(i) / 5.0
				points.append(center + Vector2(lerpf(-16.0, 26.0 + float(index % 3) * 3.0, t), -2.0 + sin(t * PI * 2.0 + angle) * 7.0))
			wave.points = points
			_fade_free(wave, 0.22)
		5:
			for i in range(3):
				var plume := _vfx_line(1.45, accent, 2089)
				var x := -8.0 + float(i) * 8.0
				plume.points = PackedVector2Array([center + Vector2(x, 10), center + Vector2(x * 0.5, -18 - float(i) * 2.0)])
				_fade_free(plume, 0.18 + float(i) * 0.018)
		6:
			for angle_offset in [-0.45, 0.45]:
				var cross := _vfx_line(1.55, accent, 2089)
				cross.points = PackedVector2Array([center + Vector2(-16, 0).rotated(angle + angle_offset), center + Vector2(22, 0).rotated(angle + angle_offset)])
				_fade_free(cross, 0.19)
		7:
			var step := _vfx_line(1.55, accent, 2089)
			step.points = PackedVector2Array([center + Vector2(-14, 10), center + Vector2(-4, -6), center + Vector2(7, 8), center + Vector2(20, -10)])
			_fade_free(step, 0.20)

func _show_target_telegraph(position: Vector2, profile: Dictionary) -> void:
	var tint: Color = profile["tint"]
	var ring := Line2D.new()
	ring.width = 2.4
	ring.default_color = Color(tint.r, tint.g, tint.b, 0.78)
	ring.z_index = 2075
	var radius: float = clampf(float(profile["radius"]) * 0.32, 34.0, 72.0)
	var points := PackedVector2Array()
	for i in range(37):
		var angle := TAU * float(i) / 36.0
		points.append(position + Vector2(cos(angle) * radius, 12.0 + sin(angle) * radius * 0.36))
	ring.points = points
	ring.scale = Vector2(0.45, 0.45)
	feedback_root.add_child(ring)
	var tween := create_tween()
	tween.tween_property(ring, "scale", Vector2.ONE, 0.13).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "modulate:a", 0.0, 0.13)
	tween.tween_callback(ring.queue_free)

func _show_reward_burst() -> void:
	var label := Label.new()
	label.text = "+ REWARD"
	label.position = Vector2(944, 156)
	label.size = Vector2(280, 34)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.z_index = 2200
	_apply_ui_font(label, ui_bold_font)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.34, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.06, 0.025, 0.0, 1.0))
	label.add_theme_constant_override("outline_size", 4)
	feedback_root.add_child(label)
	_add_ring_vfx(Vector2(1084, 124), 36.0, Color(1.0, 0.72, 0.24, 0.78))
	var tween := create_tween()
	tween.tween_property(label, "position", label.position + Vector2(0, -30), 0.48)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.48)
	tween.tween_callback(label.queue_free)

func _show_death_burst(position: Vector2) -> void:
	var burst := Polygon2D.new()
	burst.position = position + Vector2(0, -34)
	burst.z_index = 2050
	burst.color = Color(1.0, 0.44, 0.16, 0.38)
	burst.polygon = PackedVector2Array([
		Vector2(0, -12),
		Vector2(4, -4),
		Vector2(17, 0),
		Vector2(4, 4),
		Vector2(0, 12),
		Vector2(-4, 4),
		Vector2(-17, 0),
		Vector2(-4, -4),
	])
	feedback_root.add_child(burst)
	for shard_i in range(6):
		var angle := TAU * float(shard_i) / 6.0
		var shard := Polygon2D.new()
		shard.position = position + Vector2(0, -30)
		shard.z_index = 2051 + shard_i
		shard.color = Color(1.0, 0.64, 0.24, 0.54) if shard_i % 2 == 0 else Color(0.62, 0.24, 0.16, 0.46)
		var size := 3.0 + float(shard_i % 3)
		shard.polygon = PackedVector2Array([
			Vector2(0, -size),
			Vector2(size, 0),
			Vector2(0, size),
			Vector2(-size, 0),
		])
		feedback_root.add_child(shard)
		var shard_tween := create_tween()
		shard_tween.tween_property(shard, "position", shard.position + Vector2(cos(angle) * 22.0, sin(angle) * 10.0), 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		shard_tween.parallel().tween_property(shard, "modulate:a", 0.0, 0.20)
		shard_tween.tween_callback(shard.queue_free)
	var tween := create_tween()
	tween.tween_property(burst, "scale", Vector2(1.45, 1.45), 0.18)
	tween.parallel().tween_property(burst, "modulate:a", 0.0, 0.18)
	tween.tween_callback(burst.queue_free)

func _add_ring_vfx(center: Vector2, radius: float, color: Color) -> void:
	var ring := Line2D.new()
	ring.width = 3.0
	ring.default_color = color
	ring.z_index = 2105
	var points := PackedVector2Array()
	for i in range(49):
		var angle := TAU * float(i) / 48.0
		points.append(center + Vector2(cos(angle) * radius, sin(angle) * radius * 0.42))
	ring.points = points
	feedback_root.add_child(ring)
	var tween := create_tween()
	tween.tween_property(ring, "scale", Vector2(1.55, 1.55), 0.32)
	tween.parallel().tween_property(ring, "modulate:a", 0.0, 0.32)
	tween.tween_callback(ring.queue_free)

func _spawn_vfx_sprite(name: String, position: Vector2, target_size: float, z: int, start_scale: float, end_scale: float, duration: float, rotation := 0.0, tint := Color.WHITE, additive := true, spin := 0.0) -> void:
	var texture := vfx_textures.get(name) as Texture2D
	if texture == null:
		return
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = true
	sprite.position = position
	sprite.rotation = rotation
	sprite.z_index = z
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.modulate = tint
	if additive:
		var material := CanvasItemMaterial.new()
		material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		sprite.material = material
	var longest_edge: float = maxf(float(texture.get_width()), float(texture.get_height()))
	var base_scale: float = target_size / maxf(longest_edge, 1.0)
	sprite.scale = Vector2.ONE * base_scale * start_scale
	feedback_root.add_child(sprite)
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE * base_scale * end_scale, duration * 0.62).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if spin != 0.0:
		tween.parallel().tween_property(sprite, "rotation", rotation + spin, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(sprite.queue_free)

func _spawn_vfx_sheet_animation(name: String, position: Vector2, frame_count: int, target_size: float, z: int, frame_duration: float, rotation := 0.0, tint := Color.WHITE, move_offset := Vector2.ZERO, additive := true) -> void:
	var texture := vfx_textures.get(name) as Texture2D
	if texture == null or frame_count <= 0:
		return
	var frame_width := float(texture.get_width()) / float(frame_count)
	var frame_height := float(texture.get_height())
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = true
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0.0, 0.0, frame_width, frame_height)
	sprite.position = position
	sprite.rotation = rotation
	sprite.z_index = z
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.modulate = tint
	if additive:
		var material := CanvasItemMaterial.new()
		material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		sprite.material = material
	var base_scale := target_size / maxf(frame_width, frame_height)
	sprite.scale = Vector2.ONE * base_scale
	feedback_root.add_child(sprite)
	var frame_tween := create_tween()
	for frame in range(frame_count):
		frame_tween.tween_callback(_set_vfx_sheet_frame.bind(sprite, frame, frame_width, frame_height))
		frame_tween.tween_interval(frame_duration)
	frame_tween.tween_property(sprite, "modulate:a", 0.0, clampf(frame_duration * 1.5, 0.05, 0.10)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	frame_tween.tween_callback(sprite.queue_free)
	if move_offset != Vector2.ZERO:
		var motion_tween := create_tween()
		motion_tween.tween_property(sprite, "position", position + move_offset, frame_duration * float(frame_count)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _set_vfx_sheet_frame(sprite: Sprite2D, frame: int, frame_width: float, frame_height: float) -> void:
	if not is_instance_valid(sprite):
		return
	sprite.region_rect = Rect2(float(frame) * frame_width, 0.0, frame_width, frame_height)

func _update_skill_cooldown_ring() -> void:
	if skill_cooldown_ring == null:
		return
	if not battle_active or sim == null or sim.result != "running":
		skill_cooldown_ring.points = PackedVector2Array()
		return
	var radius := 61.0
	var center := Vector2(1196.0, 648.0)
	var ratio := 1.0 - clampf(skill_cooldown / skill_cooldown_seconds, 0.0, 1.0)
	var steps := maxi(3, int(ceil(48.0 * ratio)))
	var points := PackedVector2Array()
	for i in range(steps + 1):
		var angle := -PI * 0.5 + TAU * ratio * float(i) / float(steps)
		points.append(center + Vector2(cos(angle) * radius, sin(angle) * radius))
	skill_cooldown_ring.points = points
	skill_cooldown_ring.default_color = Color(1.0, 0.88, 0.42, 0.98) if skill_cooldown <= 0.05 else Color(1.0, 0.72, 0.25, 0.72)

func _load_vfx_textures() -> void:
	vfx_textures = {
		"charge_hand_v51": load(VFX_SKILL_CHARGE_HAND),
		"release_flash_v53": load(VFX_SKILL_RELEASE_FLASH),
		"projectile_trail_v52": load(VFX_SKILL_PROJECTILE_TRAIL),
		"impact_directional_hit_v52": load(VFX_SKILL_IMPACT_BURST_SHEET),
		"sig_garuda": load(VFX_SIGNATURE_GARUDA_WING),
		"sig_naga": load(VFX_SIGNATURE_NAGA_SPIRAL),
		"sig_yaksha": load(VFX_SIGNATURE_YAKSHA_STONE),
		"sig_kinnari": load(VFX_SIGNATURE_KINNARI_BLOSSOM),
		"sig_tiger": load(VFX_SIGNATURE_TIGER_CLAW),
		"sig_arrow_fan": load(VFX_SIGNATURE_HUMAN_ARROW_FAN),
		"sig_spirit": load(VFX_SIGNATURE_SPIRIT_WISP),
		"sig_arrow_trajectory_v62": load(VFX_SIGNATURE_ARROW_TRAJECTORY),
		"sig_naga_storm_v62": load(VFX_SIGNATURE_NAGA_STORM),
		"sig_naga_body_storm_v72": load(VFX_SIGNATURE_NAGA_BODY_STORM),
		"sig_aegis_shield_v62": load(VFX_SIGNATURE_AEGIS_SHIELD),
	}
	for hero_id in PERSONAL_VFX_BY_HERO.keys():
		var path := _personal_vfx_path_for_hero(String(hero_id))
		vfx_textures[_personal_vfx_key_from_path(path)] = load(path)
	for name in vfx_textures.keys():
		if vfx_textures[name] == null:
			push_warning("Missing VFX texture: %s" % name)

func _cache_battlefield_origins() -> void:
	background_origin = background.position
	lane_guides_origin = lane_guides.position
	units_origin = units_root.position
	feedback_origin = feedback_root.position

func _kick_battlefield_shake(strength: float, duration: float) -> void:
	battlefield_shake_strength = maxf(battlefield_shake_strength, strength)
	battlefield_shake_duration = maxf(battlefield_shake_duration, duration)
	battlefield_shake_timer = maxf(battlefield_shake_timer, duration)

func _update_battlefield_shake(delta: float) -> void:
	if battlefield_shake_timer <= 0.0 or battlefield_shake_duration <= 0.0:
		background.position = background_origin
		lane_guides.position = lane_guides_origin
		units_root.position = units_origin
		feedback_root.position = feedback_origin
		return
	battlefield_shake_timer = maxf(0.0, battlefield_shake_timer - delta)
	var ratio: float = battlefield_shake_timer / battlefield_shake_duration
	var power: float = battlefield_shake_strength * ratio * ratio
	var t: float = float(Time.get_ticks_msec()) * 0.043
	var offset := Vector2(sin(t * 1.7), cos(t * 2.3)) * power
	background.position = background_origin + offset * 0.32
	lane_guides.position = lane_guides_origin + offset
	units_root.position = units_origin + offset
	feedback_root.position = feedback_origin + offset
	if battlefield_shake_timer <= 0.0:
		battlefield_shake_strength = 0.0
		battlefield_shake_duration = 0.0

func _log_once(flag_key: String, event_name: String, params: Dictionary = {}) -> void:
	var flags: Dictionary = profile.get("analytics_flags", {}) as Dictionary
	if bool(flags.get(flag_key, false)):
		return
	analytics_client.log_event(event_name, params)
	flags[flag_key] = true
	profile["analytics_flags"] = flags
	LocalProfileScript.save_profile(profile, profile_path)
