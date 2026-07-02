class_name PurchaseClient
extends RefCounted

const PRODUCTS := {
	"premium_small": 300,
	"premium_large": 1200,
}

var pending := []
var allow_stub_purchases := OS.get_environment("GAME_SIAM_ALLOW_STUB_PURCHASE") == "1"

func start_purchase(product_id: String) -> Dictionary:
	if not PRODUCTS.has(product_id):
		return {"ok": false, "error": "unknown_product"}
	if not allow_stub_purchases:
		return {"ok": false, "error": "google_billing_not_configured"}
	# ponytail: local pending token; replace with Google Play Billing token when plugin is wired.
	var purchase := {
		"ok": true,
		"productId": product_id,
		"purchaseToken": "pending_%s_%d" % [product_id, Time.get_unix_time_from_system()],
	}
	pending.append(purchase)
	return purchase

func resume_pending() -> Array:
	return pending.duplicate()

func clear_pending(purchase_token: String) -> void:
	pending = pending.filter(func(purchase): return purchase["purchaseToken"] != purchase_token)

func grant_request(economy_client, profile_id: String, purchase: Dictionary) -> Dictionary:
	if String(purchase.get("purchaseToken", "")).begins_with("pending_") and not allow_stub_purchases:
		return {"ok": false, "error": "stub_purchase_disabled"}
	return economy_client.grant_purchase(profile_id, purchase["purchaseToken"], purchase["productId"])
