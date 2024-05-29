/datum/map_template/holodeck/ape_exhibit
	name = "Holodeck - Ape Exhibit"
	template_id = "holodeck_ape_exhibit"
	description = "Allan please add details"
	mappath = "_maps/~monkestation/templates/holodeck_ape_exhibit.dmm"

/// A controller used to spawn the monkeys for the ape exhibit. We use this to ensure all spawned
/// monkeys are enemies of all other spawned monkeys, rather than their enemies being dependent on
/// the spawn order. We also use this to prevent the monkeys from attacking anything else.
/obj/effect/holodeck_effect/ape_exhibit_controller
	var/monkey_count = 7
	var/monkey_type = /mob/living/carbon/human/species/monkey/holodeck_ape_exhibit
	var/fight_area_turf = /turf/open/floor/holofloor/grass

	var/obj/machinery/computer/holodeck/cpu
	var/list/monkeys = list()
	var/list/fight_turfs = list()

/obj/effect/holodeck_effect/ape_exhibit_controller/activate(obj/machinery/computer/holodeck/holodeck_cpu)
	. = ..()
	cpu = holodeck_cpu

	// Set up our fight area...
	var/area/our_area = get_area(src)
	for(var/turf/area_turf in our_area.get_contained_turfs())
		if(istype(area_turf, fight_area_turf))
			RegisterSignal(area_turf, COMSIG_ATOM_ENTERED, PROC_REF(on_mob_entering_fight_turf))
			fight_turfs += area_turf

	// TODO: We should probably check if the fight area is currently occupied, and if so, emergency shutdown

	// Set up our monkeys...
	for(var/i in 1 to monkey_count)
		var/mob/monkey = new monkey_type
		monkeys += monkey
		monkey.forceMove(pick(fight_turfs))
		cpu.add_to_spawned(monkey)

	// Make the monkeys enemies of each other...
	for(var/mob/monkey in monkeys)
		var/list/other_monkeys = monkeys - monkey
		monkey.ai_controller.insert_blackboard_key(BB_MONKEY_ENEMIES, other_monkeys)
		monkey.ai_controller.set_blackboard_key(BB_MONKEY_CURRENT_ATTACK_TARGET, pick(other_monkeys))
		monkey.ai_controller.set_ai_status(AI_STATUS_ON)
	// ...and let the battle commence.

// TODO: CLEANUP MONKEY LIMBS AND BLOOD WHEN DEACTIVATING

/obj/effect/holodeck_effect/ape_exhibit_controller/proc/on_mob_entering_fight_turf(
	turf/open/source,
	atom/movable/arrived,
	atom/old_loc,
	list/atom/old_locs
)
	if(ismob(arrived) && !istype(arrived, monkey_type))
		cpu.emergency_shutdown()
		cpu.say("Runtime in holodeck-ape-exhibit.dm, line 52: Unexpected object [arrived] in fighting area. Emergency shutdown triggered.")

/// A variation of the monkey mob used for the Ape Exhibit holodeck.
/mob/living/carbon/human/species/monkey/holodeck_ape_exhibit
	ai_controller = /datum/ai_controller/monkey/holodeck_ape_exhibit
	// TODO LIST: Make it so bloodsuckers, changelings, etc. can't abuse this

/// The Ape Exhibit ape controller.
/datum/ai_controller/monkey/holodeck_ape_exhibit

/datum/ai_controller/monkey/holodeck_ape_exhibit/PossessPawn(atom/new_pawn)
	. = ..()
	set_blackboard_key(BB_MONKEY_TARGET_MONKEYS, TRUE)
	set_trip_mode(mode = FALSE)

// Below are some overrides to handle the holodeck ape
/datum/action/cooldown/bloodsucker/feed/can_feed_from(mob/living/target, give_warnings)
	. = ..()
	if(istype(target, /mob/living/carbon/human/species/monkey/holodeck_ape_exhibit))
		if(give_warnings)
			owner.balloon_alert(owner, "no blood...?")
		return FALSE
