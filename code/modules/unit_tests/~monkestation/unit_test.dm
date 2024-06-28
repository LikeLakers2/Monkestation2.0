// Adds our own types to the list of uncreatables.
/datum/unit_test/build_list_of_uncreatables()
	RETURN_TYPE(/list)
	. = ..()
	. += list(
		/obj/effect/spawner/random_engines,
		/obj/effect/spawner/random_bar,
		///this instant starts a timer, and if its being instantly deleted it can cause issues
		/obj/machinery/atm,
		/datum/hotspot,
		/obj/machinery/ocean_elevator,
		/atom/movable/outdoor_effect,
		/turf/closed/mineral/random/regrowth,
	)
	///we need to use json_decode to run randoms properly
	. += typesof(/obj/item/device/cassette_tape)
	. += typesof(/datum/cassette/cassette_tape)
	. += typesof(/mob/living/basic/aquatic)
	. += typesof(/obj/machinery/station_map)
