class_name EconomyClient
extends RefCounted

const REQUIRED_FUNCTIONS := [
	"get_profile",
	"sync_client_state",
	"start_battle",
	"finish_battle",
	"claim_offline_reward",
	"upgrade_hero",
	"get_gacha_banner",
	"pull_gacha",
	"validate_google_purchase",
	"grant_purchase",
]

var supabase_url := ""
var anon_key := ""
var access_token := ""

func configure(next_supabase_url: String, next_anon_key: String, next_access_token := "") -> void:
	supabase_url = next_supabase_url.trim_suffix("/")
	anon_key = next_anon_key
	access_token = next_access_token

func is_configured() -> bool:
	return supabase_url != "" and anon_key != ""

func is_live_configured() -> bool:
	if not is_configured():
		return false
	var lower_url := supabase_url.to_lower()
	var lower_key := anon_key.to_lower()
	if lower_url.contains("example") or lower_url.contains("replace") or lower_url.contains("placeholder"):
		return false
	if lower_key in ["anon-key", "dev-anon-key", "staging-anon-key", "prod-anon-key"]:
		return false
	if lower_key.contains("replace") or lower_key.contains("placeholder"):
		return false
	return lower_url.begins_with("https://") or lower_url.begins_with("http://localhost") or lower_url.begins_with("http://127.0.0.1")

func function_url(function_name: String) -> String:
	if not REQUIRED_FUNCTIONS.has(function_name):
		push_error("Unknown economy function: %s" % function_name)
		return ""
	return "%s/functions/v1/%s" % [supabase_url, function_name]

func headers() -> PackedStringArray:
	var bearer := access_token if access_token != "" else anon_key
	return PackedStringArray([
		"Content-Type: application/json",
		"apikey: %s" % anon_key,
		"Authorization: Bearer %s" % bearer,
	])

func build_request(function_name: String, body: Dictionary) -> Dictionary:
	return {
		"url": function_url(function_name),
		"headers": headers(),
		"method": HTTPClient.METHOD_POST,
		"body": JSON.stringify(body),
	}

func send(http_request: HTTPRequest, function_name: String, body: Dictionary) -> Error:
	if not is_live_configured():
		return ERR_UNCONFIGURED
	var request := build_request(function_name, body)
	if String(request["url"]) == "":
		return ERR_INVALID_PARAMETER
	return http_request.request(request["url"], request["headers"], request["method"], request["body"])

func get_profile(profile_id: String) -> Dictionary:
	return build_request("get_profile", {"profileId": profile_id})

func sync_client_state(profile_id: String, client_state: Dictionary) -> Dictionary:
	return build_request("sync_client_state", {"profileId": profile_id, "clientState": client_state})

func start_battle(profile_id: String, request_id: String, wave_id: int, formation: Array) -> Dictionary:
	return build_request("start_battle", {
		"profileId": profile_id,
		"requestId": request_id,
		"waveId": wave_id,
		"formation": formation,
	})

func finish_battle(profile_id: String, ticket_id: String, result: String, summary: Dictionary) -> Dictionary:
	return build_request("finish_battle", {
		"profileId": profile_id,
		"ticketId": ticket_id,
		"result": result,
		"summary": summary,
	})

func claim_offline_reward(profile_id: String) -> Dictionary:
	return build_request("claim_offline_reward", {"profileId": profile_id})

func upgrade_hero(profile_id: String, hero_id: String) -> Dictionary:
	return build_request("upgrade_hero", {"profileId": profile_id, "heroId": hero_id})

func get_gacha_banner() -> Dictionary:
	return build_request("get_gacha_banner", {})

func pull_gacha(profile_id: String, request_id: String, count: int) -> Dictionary:
	return build_request("pull_gacha", {"profileId": profile_id, "requestId": request_id, "count": count})

func validate_google_purchase(purchase_token: String, product_id: String) -> Dictionary:
	return build_request("validate_google_purchase", {"purchaseToken": purchase_token, "productId": product_id})

func grant_purchase(profile_id: String, purchase_token: String, product_id: String) -> Dictionary:
	return build_request("grant_purchase", {
		"profileId": profile_id,
		"purchaseToken": purchase_token,
		"productId": product_id,
	})
