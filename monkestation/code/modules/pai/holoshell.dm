/mob/living/silicon/pai
	/// The pAI's currently selected holoshell
	// ORIGINAL: mob.chassis
	var/datum/pai_holoshell/current_holoshell = new /datum/pai_holoshell/repairbot
	/// If the pAI can become a holoshell (i.e. someone has not disabled this function)
	// ORIGINAL: mob.can_holo
	var/holo_enabled = TRUE
	/// The remaining health of the pAI's holoshell before it is forcibly returned to card form
	// ORIGINAL: mob.holochassis_health
	var/holo_health = 20
	/// If the holoshell is ready for use (i.e. the emitters are done recycling)
	// ORIGINAL: mob.holochassis_ready
	var/holo_ready = FALSE
	/// If the pAI is currently in holoshell form
	// ORIGINAL: mob.holoform
	var/holo_in_use = FALSE

/mob/living/silicon/pai/examine(mob/user)
	. = ..()
	. += "This one appears in the form of a [lowertext(src.current_holoshell.name)]."
	// TODO: Need to move master name to the card, me thinks.
	. += "Its master ID string seems to be [(!master_name || emagged) ? "empty" : master_name]."

/mob/living/silicon/pai/on_lying_down()
	. = ..()
	if(loc != card)
		src.visible_message(span_notice("[src] lays down for a moment..."))
/mob/living/silicon/pai/on_standing_up()
	. = ..()
	if(loc != card)
		src.visible_message(span_notice("[src] perks up from the ground."))

/mob/living/silicon/pai/mob_try_pickup(mob/living/user, instant=FALSE)
	if(holo_in_use && !current_holoshell.can_be_held)
		to_chat(user, span_warning("[src]'s current form isn't able to be carried!"))
		return FALSE
	return ..()

/mob/living/silicon/pai/update_appearance(updates)
	. = ..()
	src.update_resting()

/mob/living/silicon/pai/update_resting()
	. = ..()
	if(src.resting)
		src.icon_state = "[src.current_holoshell.icon_state_prefix]_rest"
	else
		src.icon_state = src.current_holoshell.icon_state_prefix

/mob/living/silicon/pai/wabbajack(what_to_randomize, change_flags = WABBAJACK)
	var/list/chassis_options = subtypesof(/datum/pai_holoshell) - src.current_holoshell.type
	if(length(chassis_options) < 2)
		// This branch should never be taken unless something is messy with BYOND.
		return FALSE
	var/datum/pai_holoshell/new_shell = pick(chassis_options)
	set_holochassis(new_shell)
	balloon_alert(src, "[new_shell] composite engaged")
	return TRUE

/// Sets the pAI's holochassis, changing its current appearance if it's already folded out.
///
/// @param {typepath deriving /datum/pai_holoshell} shell_typepath - A typepath to the holoshell
/// we want to set our holochassis to.
///
/// @returns {boolean} - TRUE if the holochassis was set successfully. FALSE otherwise.
/mob/living/silicon/pai/proc/set_holochassis(datum/pai_holoshell/shell_typepath)
	if(!ispath(shell_typepath))
		CRASH("set_holochassis was given a non-typepath argument")
	if(!ispath(shell_typepath, /datum/pai_holoshell))
		CRASH("set_holochassis was given a typepath not deriving from /datum/pai_holoshell")
	var/datum/pai_holoshell/shell_instance = new shell_typepath
	src.current_holoshell = shell_instance
	src.icon = shell_instance.normal_icon
	src.held_lh = shell_instance.held_lh_icon
	src.held_rh = shell_instance.held_rh_icon
	src.held_state = shell_instance.icon_state_prefix
	src.head_icon = shell_instance.worn_head_icon
	// Apply the new holoshell's icon states
	src.update_appearance()
	src.update_resting()
	return TRUE

/// Toggles the pAI between having its holochassis folded out and folded in.
///
/// @param {boolean} force - Force the toggle to happen.
///
/// @returns {boolean} - TRUE if the toggle was successful. FALSE otherwise.
/mob/living/silicon/pai/proc/toggle_holochassis(force = FALSE)
	// NOTE: This should probably be moved into the card, so we aren't dealing with the logistics
	// on the mob side of things.
	if(src.holo_in_use)
		src.fold_in(force)
	else
		src.fold_out(force)

/// Engage the pAI's holochassis form.
///
/// @param {boolean} force - Force the form to engage.
///
/// @returns {boolean} - TRUE if the form was successfully engaged, or was already engaged. FALSE
/// otherwise.
/mob/living/silicon/pai/fold_out(force = FALSE)
	if(src.holo_in_use)
		return TRUE
	if(!src.holo_enabled && !force)
		balloon_alert(src, "emitters are disabled")
		return FALSE
	if(!src.holo_health < 0)
		balloon_alert(src, "emitter repair incomplete")
		return FALSE
	if(!src.holo_ready)
		balloon_alert(src, "emitters recycling...")
		return FALSE
	. = ..()

/// Returns the pAI to card mode.
///
/// @param {boolean} force - If TRUE, the pAI will be forced to card mode.
///
/// @returns {boolean} - TRUE if the pAI successfully returned to card mode, or was already in card
/// mode. FALSE otherwise.
/mob/living/silicon/pai/fold_in(force = FALSE)
	if(!src.holo_in_use)
		return TRUE
	. = ..()
