/datum/config_entry/flag/log_cargo

/datum/log_category/cargo
	category = LOG_CATEGORY_CARGO
	config_flag = /datum/config_entry/flag/log_cargo

/datum/log_category/cargo_manifest
	category = LOG_CATEGORY_CARGO_MANIFEST
	config_flag = /datum/config_entry/flag/log_cargo
	master_category = /datum/log_category/cargo

/proc/log_cargo_manifest(text, list/manifest_errors)
	logger.Log(LOG_CATEGORY_CARGO_MANIFEST, text, list(
		"manifest_errors" = manifest_errors
	))
	return
