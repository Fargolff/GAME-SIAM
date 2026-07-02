class_name GameEnvironment
extends RefCounted

const DEFAULT_ENVIRONMENT := "dev"

const ENVIRONMENTS := {
	"dev": {
		"supabase_url": "https://gamesiam-dev.example.supabase.co",
		"supabase_anon_key": "dev-anon-key",
		"feedback_url": "https://forms.gle/REPLACE_WITH_DEV_FEEDBACK_FORM",
	},
	"staging": {
		"supabase_url": "https://gamesiam-staging.example.supabase.co",
		"supabase_anon_key": "staging-anon-key",
		"feedback_url": "https://forms.gle/REPLACE_WITH_STAGING_FEEDBACK_FORM",
	},
	"prod": {
		"supabase_url": "https://gamesiam.example.supabase.co",
		"supabase_anon_key": "prod-anon-key",
		"feedback_url": "https://forms.gle/REPLACE_WITH_PROD_FEEDBACK_FORM",
	},
}

static func current_name() -> String:
	return String(ProjectSettings.get_setting("application/config/gamesiam_environment", DEFAULT_ENVIRONMENT))

static func current() -> Dictionary:
	return config(current_name())

static func config(environment_name: String) -> Dictionary:
	return (ENVIRONMENTS.get(environment_name, ENVIRONMENTS[DEFAULT_ENVIRONMENT]) as Dictionary).duplicate()
