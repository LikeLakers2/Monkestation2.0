/*
 * # Multi-character verbs
 *
 * Verbs that can be used by a client to switch instantaneously between different mobs that they've
 * been assigned by admins.
 *
 * This multi-character system is meant as an alternative to the "Assume Direct Control" and "Give
 * Control" actions that admins have, when the mobs that a player will be using are known ahead of
 * time. This makes them very useful for storytelling purposes.
 *
**/

/// Adds the option to assign a mob to a client, via the View-Variables window
/mob/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_ASSIGN_MOB_TO_CLIENT, "Assign Mob to Client")

/// Handles assigning mobs to a client.
/mob/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_ASSIGN_MOB_TO_CLIENT])
		if(!check_rights(NONE))
			return
		usr.client.cmd_assign_mob_to_client(src)

/client/proc/cmd_assign_mob_to_client(mob/mob_to_assign in GLOB.mob_list)
	set category = "Admin.Game"
	set name = "Assign Mob to Client"

	// Just in case someone convinces the server to somehow call this...
	if(!check_rights(NONE))
		return

	if(!mob_to_assign)
		// How did you even get here...?
		CRASH("Assign Mob to Client verb called without a client.")

	// Ask which client to assign this mob to
	var/client/assign_to = input(src, "Assign this mob to which admin client?", "Assigning mob...") as null|anything in sort_list(GLOB.admins)
	if(!assign_to)
		return

	// If the client we're assigning this mob to isn't an admin (somehow), alert the admin of this
	// and refuse to continue.
	if(!assign_to.holder)
		tgui_alert(
			src,
			title = "Not an Admin",
			message = "The client you selected is (somehow) not an admin."
		)
		return

	// If the client is already assigned this mob, alert the admin of this and refuse to continue.
	if(assign_to.is_mob_assigned(mob_to_assign))
		tgui_alert(
			src,
			title = "Mob Already Assigned",
			message = "This mob is already assigned to the client you selected.",
		)
		return

	// If the mob is already being controlled by a different client than we selected, ensure the
	// admin is aware that they will not be immediately able to take control.
	if(mob_to_assign.ckey && !mob_to_assign.is_controlled_by_client(assign_to))
		var/understands = tgui_alert(
			src,
			title = "This Mob Is Already Under Control",
			message = "This mob is already being controlled by [mob_to_assign.ckey]. If you assign this mob to [assign_to], they will be able to kick out the previous controller at any time. Do you wish to continue?",
			buttons = list("Yes", "No"),
		)
		if(understands != "Yes")
			return

	// Log this to the admins, for investigative purposes.
	log_admin("[key_name(src)] assigned a mob ([key_name(mob_to_assign)]) to [key_name(assign_to)].")
	message_admins("[key_name_admin(src)] assigned a mob ([ADMIN_LOOKUPFLW(mob_to_assign)]) to [key_name_admin(assign_to)].")
	// Notify the acting admin of how to undo this action...
	to_chat(src, span_notice("You have granted [assign_to] control of a mob. To undo this action, remove the relevant /datum/component/mob_assigned_to_client from this mob."))

	// Add the mob to the client's assigned mob list...
	AddComponent(/datum/component/mob_assigned_to_client, assign_to)

	// ...and notify the user that they've been granted control.
	to_chat(assign_to, span_notice("You have been granted control of a mob. Use the Switch Character verb in the OOC tab to switch to the mob."))

// TODO: Add a admin verb that lets them see the mob assignment list as a VV window
