extends SceneTree

const EconomyClientScript := preload("res://scripts/backend/economy_client.gd")
const PurchaseClientScript := preload("res://scripts/backend/purchase_client.gd")

func _initialize() -> void:
	var failures: Array[String] = []
	var economy := EconomyClientScript.new()
	economy.configure("https://gamesiam.example.supabase.co", "anon-key")
	var locked_purchase := PurchaseClientScript.new()
	var locked_result: Dictionary = locked_purchase.start_purchase("premium_small")
	if bool(locked_result.get("ok", false)):
		failures.append("PurchaseClient should not allow stub purchases by default.")
	var purchase := PurchaseClientScript.new()
	purchase.allow_stub_purchases = true

	var one: Dictionary = economy.pull_gacha("profile-1", "pull-1", 1)
	var ten: Dictionary = economy.pull_gacha("profile-1", "pull-10", 10)
	var banner: Dictionary = economy.get_gacha_banner()
	var pending: Dictionary = purchase.start_purchase("premium_small")
	var grant: Dictionary = purchase.grant_request(economy, "profile-1", pending)

	if JSON.parse_string(one["body"])["count"] != 1:
		failures.append("1x pull payload should request count 1.")
	if JSON.parse_string(ten["body"])["count"] != 10:
		failures.append("10x pull payload should request count 10.")
	if not String(banner["url"]).ends_with("/get_gacha_banner"):
		failures.append("Banner request should call get_gacha_banner.")
	if purchase.resume_pending().size() != 1:
		failures.append("PurchaseClient should retain pending purchase for resume.")
	if JSON.parse_string(grant["body"])["purchaseToken"] != pending["purchaseToken"]:
		failures.append("Grant purchase request should forward purchase token.")

	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("Phase 7 validation passed: gacha requests, odds endpoint, pending purchase grant")
	quit(0)
