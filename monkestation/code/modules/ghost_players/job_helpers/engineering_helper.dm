
/// A barrier used for the Centcom Engineering area, meant to prevent engineering items from exiting
/// the area.
/obj/effect/centcom_engineering_barrier
	name = "centcom engineering barrier"
	desc = "An advanced version of the standard engineering barrier, blocking the passage of gases, and additionally preventing tool theft from engineering areas."
	icon = 'goon/icons/obj/meteor_shield.dmi'
	icon_state = "shieldw"
	color = COLOR_YELLOW
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	can_atmos_pass = ATMOS_PASS_NO

/// The types listed below, as well as their subtypes, are prevented from going through the barrier.
GLOBAL_LIST_INIT(centcom_engineering_barrier_blocked_items, list(
	/obj/item/paper,
))
// NOTE: Should the above list be a typecache? This would make it use much more RAM, as it needs to
// hold a list of all the types specified, as well as all of their subtypes... but it'd be very
// fast, as you only need to perform a single quick access, instead of looping through the entire
// list. entire loop. Plus, being a global list, instead of being instantiated once per instance of
// the barrier, means we only eat the RAM cost once.

/obj/effect/centcom_engineering_barrier/Initialize(mapload)
	. = ..()
	// Tells the atmos system to stop processing the turf this barrier is on.
	air_update_turf(TRUE, TRUE)

/obj/effect/centcom_engineering_barrier/Destroy()
	// Tell the atmos system to restart processing of the turf this barrier is on.
	air_update_turf(TRUE, FALSE)
	. = ..()

/obj/effect/centcom_engineering_barrier/CanPass(atom/movable/mover, border_dir)
	var/atoms_to_check = mover.get_all_contents()
	for(var/atom_to_check in atoms_to_check)
		if(is_type_in_list(atom_to_check, GLOB.centcom_engineering_barrier_blocked_items))
			return FALSE
		// Typecache variant below
		/*
		if(is_type_in_typecache(atom_to_check, items_disallowed_typecache))
			return FALSE
		*/
	return ..()

// Yes, I'm aware /obj/structure/centcom_item_spawner exists. It doesn't fit the requirements for
// what I want.
/obj/structure/centcom_engineering_item_spawner
	name = "engineering tools and materials requester"
	desc = "A device capable of requesting engineering tools and materials from Centcom's reserves. Most requests will be approved automatically, with the requested objects appearing next to the device. However, these items will be restricted to the Centcom engineering area, unless you have proper approval."
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	icon = 'icons/obj/money_machine.dmi'
	icon_state = "bogdanoff"
	// The list of
	var/list/spawnable_materials = list()
	var/list/spawnable_tools = list(
		/obj/item/screwdriver,
		/obj/item/wrench,
	)

/obj/structure/centcom_engineering_item_spawner/Initialize(mapload)
	. = ..()

	// Build up the list of spawnable materials
	spawnable_materials = build_spawnable_materials_list()

	// Now that we have lists of types in `spawnable_materials` and `spawnable_tools`, process them
	// for later - i.e. by making them associative, with the key being the name to show in tgui, and
	// the value being the typepath.
	pass()

/obj/structure/centcom_engineering_item_spawner/proc/build_spawnable_materials_list()
	. = subtypesof(/datum/material)
	// Below are those excluded from the materials list, whether because they're abstract items, or
	// otherwise not meant to be used on their own.
	. -= list(
		// Abstract datum - not meant to be used directly.
		/datum/material/alloy
	)

	// Meat (at least its subtypes) require a source to be instantiated, and cannot be instantiated
	// without one.
	. -= typesof(/datum/material/meat)
