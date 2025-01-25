/datum/status_effect/temporary_pushover
	id = "temporary_pushover"
	// We don't have a `tick()` override, so there's no need to tick.
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	remove_on_fullheal = TRUE

/datum/status_effect/temporary_pushover/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/temporary_pushover/on_apply()
	// The dead is already a pushover
	if(owner.stat == DEAD)
		return FALSE

	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(clear_pushover))
	ADD_TRAIT(owner, TRAIT_GRABWEAKNESS, TEMPORARY_PUSHOVER_STATUS)

/datum/status_effect/temporary_pushover/on_remove()
	REMOVE_TRAIT(owner, TRAIT_GRABWEAKNESS, TEMPORARY_PUSHOVER_STATUS)
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)

/datum/status_effect/temporary_pushover/proc/clear_pushover(datum/source)
	SIGNAL_HANDLER
	qdel(src)
