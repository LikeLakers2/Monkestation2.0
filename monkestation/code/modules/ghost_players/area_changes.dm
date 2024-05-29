/area/centcom/central_command_areas
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA
	ban_explosions = TRUE
	grace = TRUE

/area/centcom/tdome
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA
	ban_explosions = TRUE

/area/centcom/tdome/arena/actual
	name = "Thunder Dome Arena Area"
	ban_explosions = FALSE
	// the grace effect has special handling for dueling

/area/centcom/central_command_areas/ghost_spawn
	name = "Centcom Ghost Spawn"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_ghostspawn"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA

/area/centcom/central_command_areas/supply
	area_flags = UNIQUE_AREA | NOTELEPORT

/area/centcom/central_command_areas/pre_shuttle
	name = "Centcomm Pre Shuttle"
	area_flags = UNIQUE_AREA | NOTELEPORT

/area/centcom/central_command_areas/supply
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_GHOSTS_DURING_ROUND

/area/centcom/central_command_areas/borbop
	name = "Borbop's Bar"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "borbop"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA

/area/centcom/central_command_areas/kitchen
	name = "Papa's Pizzeria"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_kitchen"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA

/area/centcom/central_command_areas/medical
	name = "Centcom Medical"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_medical"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA

/area/centcom/central_command_areas/botany
	name = "Centcom Botany"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_botany"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA

/// The centcom engineering areas, for letting people mess about with engineering tools
/area/centcom/central_command_areas/engineering
	name = "Centcom Engineering"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_engineering"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA

/// The area used before and after the transit tubes, meant as a intermediary between Centcom
/// Engineering and the rest of Centcom.
///
/// In-universe, the two transit areas are connected by transit tubes, both to reduce costs and to
/// show off engineering's prowess. Alongside the transit tube is a catwalk, meant to allow for
/// transit tube maintenance, and doubly serving as an alternative route to/from the engineering
/// area, should Centcom's power go out.
/area/centcom/central_command_areas/engineering/transit
	name = "Centcom Engineering Transit"
	icon_state = "centcom_engineering_transit"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA

/area/centcom/central_command_areas/hall
	name = "Centcom Hall"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_hall"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA

/area/centcom/central_command_areas/admin_hangout
	name = "Admin Hangout"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_hangout"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_GHOSTS_DURING_ROUND

/area/centcom/central_command_areas/ghost_blocker
	name = "During Round Ghost Blocker"
	area_flags = NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_GHOSTS_DURING_ROUND

/area/centcom/central_command_areas/evacuation
	area_flags = NOTELEPORT | GHOST_AREA | NO_GHOSTS_DURING_ROUND

/area/centcom/central_command_areas/admin
	area_flags = NOTELEPORT | GHOST_AREA | NO_GHOSTS_DURING_ROUND

/area/centcom/central_command_areas/firing_range
	name = "Centcom Firing Range"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_firingrange"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA
	ban_explosions = FALSE
	grace = FALSE

/area/centcom/central_command_areas/firing_range_checkpoint_control
	area_flags = UNIQUE_AREA | NOTELEPORT

/area/centcom/central_command_areas/arcade
	name = "Centcom Arcade"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "centcom_arcade"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA

/area/centcom
	/// Whether to ban explosions in this area.
	var/ban_explosions = FALSE
	/// Whether this area gives the "grace" status effect or not.
	var/grace = FALSE

/area/centcom/Initialize(mapload)
	. = ..()
	RegisterSignals(src, list(COMSIG_AREA_INTERNAL_EXPLOSION, COMSIG_AREA_EXPLOSION_SHOCKWAVE), PROC_REF(explosion_check))

/area/centcom/Entered(atom/movable/thing)
	. = ..()
	if(grace && isliving(thing))
		var/mob/living/thingy = thing
		thingy.apply_status_effect(/datum/status_effect/centcom_grace)

/area/centcom/proc/explosion_check()
	SIGNAL_HANDLER
	if(ban_explosions)
		return COMSIG_CANCEL_EXPLOSION

// Override that handles teleporting ghost player's mobs back to Centcom ghostspawn, if they try to
// move out of it during the round.
/area/Entered(atom/movable/thing)
	. = ..()

	if(istype(thing, /mob/living/carbon/human/ghost))
		// If this is a ghost, run the teleport checks
		teleport_ghost_mob_if_needed(thing)
	else
		// Else, loop through this thing's contents...
		for(var/atom/movable/atom_inside in thing.get_all_contents())
			if(istype(atom_inside, /mob/living/carbon/human/ghost))
				// ...and for any ghosts, run the checks
				teleport_ghost_mob_if_needed(atom_inside)

// Teleports a ghost's mob to ghostspawn, if this area does not meet certain requirements.
/area/proc/teleport_ghost_mob_if_needed(mob/living/carbon/human/ghost/ghost)
	// We should teleport, if...
	var/should_teleport = FALSE
	// ...this is not an area allowed to be inhabited by ghost characters
	should_teleport |= (!(area_flags & GHOST_AREA))
	// ...this is an area ghosts are prohibited to inhabit during a round, and the round is ongoing
	should_teleport |= ((area_flags & NO_GHOSTS_DURING_ROUND) && SSticker.current_state != GAME_STATE_FINISHED)
	// Note: I realize the above bits seem sort of like the same thing. But in refactoring this, I
	// decided to leave both checks in.

	if(should_teleport)
		ghost.move_to_ghostspawn()

// Area used for space near centcom, where we might want lighting.
/area/space/nearstation/centcom
	name = "Space (near Centcom)"
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA

/area/space/nearstation/centcom/Initialize(mapload)
	. = ..()
	// The code I want to run worked when I placed it here - but I don't want to rely on turfs being
	// initialized before areas. So, I'm going to run it in late-initialization, even if it means it
	// takes a bit longer to be fully ready.
	return INITIALIZE_HINT_LATELOAD

/area/space/nearstation/centcom/LateInitialize()
	. = ..()
	// By this point, the area is already colored like it's lit by starlight, and fullbright
	// overlays have been applied. However, for the centcom areas, we want to include lights, and
	// those are not handled properly if the turfs are still considered space_lit.
	for(var/turf/T in src)
		T.space_lit = FALSE
		//T.force_setup_lighting()
		T.lighting_build_overlay()

// /turf/proc/force_setup_lighting()
//	SETUP_SMOOTHING()
//	if (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
//		QUEUE_SMOOTH(src)

// Variant that prevents ghosts during the round.
/area/space/nearstation/centcom/no_ghosts_during_round
	area_flags = UNIQUE_AREA | NOTELEPORT | GHOST_AREA | PASSIVE_AREA | NO_GHOSTS_DURING_ROUND

/*
/obj/effect/mapping_helpers/force_lighting
	late = TRUE

/obj/effect/mapping_helpers/force_lighting/LateInitialize()
	. = ..()
	var/turf/where = get_turf(src)
	if(where)
		where.update_light()
	qdel(src)
*/
