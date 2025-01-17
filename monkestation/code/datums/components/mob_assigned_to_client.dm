GLOBAL_LIST_EMPTY(mob_assignments)

/datum/component/mob_assigned_to_client
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/client_ckey
	var/mob/parent_mob

/// Used to make the mob name show up when converting this mob assignment to a string. Makes the
/// code a little cleaner when generating a tgui input list.
/datum/component/mob_assigned_to_client/proc/operator""()
	return "[parent_mob || type]"

/datum/component/mob_assigned_to_client/Initialize(client/assigned_to)
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	if(!IS_CLIENT_OR_MOCK(assigned_to))
		stack_trace("Attempted to assign a client to a mob without specifying a client.")
		return COMPONENT_INCOMPATIBLE

	log_admin("[key_name(parent)] was assigned to the client [key_name(assigned_to)].")
	message_admins("[key_name_admin(parent)] was assigned to the client [key_name_admin(assigned_to)]")

	parent_mob = parent
	client_ckey = assigned_to.ckey

	GLOB.mob_assignments += src

/datum/component/mob_assigned_to_client/Destroy(force, silent)
	log_admin("[key_name(parent_mob)] was de-assigned from the client [client_ckey].")
	message_admins("[key_name_admin(parent_mob)] was de-assigned to the client [client_ckey]")
	GLOB.mob_assignments -= src
	return ..()

/datum/component/mob_assigned_to_client/RegisterWithParent()
	. = ..()
	to_chat(parent_mob, span_notice("You have been granted control of a mob. Use the Switch Character verb in the OOC tab to switch to the mob."))

/datum/component/mob_assigned_to_client/proc/perform_switch()
	if(!parent_mob.is_controlled_by_client(src.client_ckey))
		to_chat(parent_mob.client, span_notice("Another player has forcefully taken over this mob."))
		parent_mob.ghostize(FALSE)

	var/mob/old_mob = get_mob_by_ckey(client_ckey)
	parent_mob.ckey = src.client_ckey
	parent_mob.client?.init_verbs()
	// If the client's previous mob was an observer, we have no more work to do but to delete the ghost.
	if(isobserver(old_mob))
		qdel(old_mob)
		return

	// I'm not sure if there's a need for this, but the aghost verb does this as a hack for
	// something, so...
	old_mob.ckey = "@[src.client_ckey]"
	// Prevents the mob from showing the usual "Zz" icon when someone is disconnected.
	if(isliving(old_mob))
		var/mob/living/old_mob_living = old_mob
		old_mob_living.set_ssd_indicator(FALSE)

/client/proc/get_mob_assignments()
	. = list()
	for(var/datum/component/mob_assigned_to_client/assignment as anything in GLOB.mob_assignments)
		if(assignment.client_ckey == src.ckey)
			. += assignment

/client/proc/get_assigned_mobs()
	. = list()
	for(var/datum/component/mob_assigned_to_client/assignment as anything in GLOB.mob_assignments)
		if(assignment.client_ckey == src.ckey)
			. += assignment.parent_mob

/client/proc/is_mob_assigned(mob/who)
	. = FALSE
	for(var/datum/component/mob_assigned_to_client/assignment as anything in GLOB.mob_assignments)
		if(assignment.parent_mob == who && assignment.client_ckey == src.ckey)
			return TRUE

/mob/proc/is_controlled_by_client(who_ckey)
	if(!who_ckey)
		CRASH("who parameter not specified")
	if(!src.ckey)
		return FALSE
	// We check for "@ckey" because that's the format used by aghost.
	return (src.ckey == who_ckey || src.ckey == "@[who_ckey]")

/// Verb given to clients which allows them to instantly swap between any characters assigned to
/// them.
/client/verb/switch_character()
	set category = "OOC"
	set name = "Switch Character"

	var/list/mobs_assignments = src.get_mob_assignments()
	// Does the player have any assigned mobs at all?
	if(!length(mobs_assignments))
		to_chat(src, span_notice("You have no mobs assigned to you by an admin."))
		return

	var/datum/component/mob_assigned_to_client/selected_assignment = tgui_input_list(
		src,
		title = "Character Selection",
		message = "Select a character to swap to",
		items = sort_list(mobs_assignments),
	)
	if(!selected_assignment)
		return

	// Is this mob the same mob as they're already controlling?
	if(selected_assignment.parent_mob == src.mob)
		return

	// Is the selected mob not being controlled by someone else?
	if(!selected_assignment.parent_mob.is_controlled_by_client(src))
		var/force_switch = tgui_alert(
			src,
			title = "Character In Use",
			message = "The mob you selected is being controlled by [selected_assignment.parent_mob.key]. You can switch to this mob, but this will ghost the current controller. Switch anyways?",
			buttons = list("Yes", "No")
		)
		if(force_switch != "Yes")
			return

	// Final check: Is this mob still within the mobs assigned to them?
	// This check is placed last since tgui alerts pause the current proc - and we want to check
	// this at as close a point to switching as possible, to prevent abuse.
	mobs_assignments = src.get_mob_assignments()
	if(!(selected_assignment in mobs_assignments))
		tgui_alert(
			src,
			title = "Switching Canceled",
			message = "The mob you selected is no longer in your assigned mobs list.",
		)
		return

	// And finally, switch this client's control to the mob.
	selected_assignment.perform_switch()
