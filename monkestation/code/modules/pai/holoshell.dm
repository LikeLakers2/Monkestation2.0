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

/mob/living/silicon/pai/proc/set_holochassis(datum/pai_holoshell/choice)
	if(!choice)
		return FALSE
	src.current_holoshell = choice
	src.icon = choice.normal_icon
	src.held_lh = choice.held_lh_icon
	src.held_rh = choice.held_rh_icon
	src.held_state = choice.icon_state_prefix
	src.head_icon = choice.worn_head_icon
	// Apply the new holoshell's icon states
	src.update_appearance()
	src.update_resting()
	// TODO: Should probably change this description to be dynamic...
	desc = "A pAI mobile hard-light holographics emitter. This one appears in the form of a [lowertext(choice.name)]."
	return TRUE

/mob/living/silicon/pai/update_appearance(updates)
	. = ..()
	src.update_resting()

/mob/living/silicon/pai/update_resting()
	. = ..()
	if(src.resting)
		src.icon_state = "[src.current_holoshell.icon_state_prefix]_rest"
	else
		src.icon_state = src.current_holoshell.icon_state_prefix

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
