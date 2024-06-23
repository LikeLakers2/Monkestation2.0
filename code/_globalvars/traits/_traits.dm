// This file should contain every single global trait in the game in a type-based list, as well as any additional trait-related information that's useful to have on a global basis.
// This file is used in linting, so make sure to add everything alphabetically and what-not.
// Do consider adding your trait entry to the similar list in `admin_tooling.dm` if you want it to be accessible to admins (which is probably the case for 75% of traits).

// Please do note that there is absolutely no bearing on what traits are added to what subtype of `/datum`, this is just an easily referenceable list sorted by type.
// The only thing that truly matters about traits is the code that is built to handle the traits, and where that code is located. Nothing else.

GLOBAL_LIST_INIT(traits_by_type, list(
	/atom = list(
		"TRAIT_KEEP_TOGETHER" = TRAIT_KEEP_TOGETHER,
	),
	/atom/movable = list(
		"TRAIT_ASHSTORM_IMMUNE" = TRAIT_ASHSTORM_IMMUNE,
		"TRAIT_LAVA_IMMUNE" = TRAIT_LAVA_IMMUNE,
		"TRAIT_MOVE_FLOATING" = TRAIT_MOVE_FLOATING,
		"TRAIT_MOVE_FLYING" = TRAIT_MOVE_FLYING,
		"TRAIT_MOVE_GROUND" = TRAIT_MOVE_GROUND,
		"TRAIT_MOVE_PHASING" = TRAIT_MOVE_PHASING,
		"TRAIT_MOVE_VENTCRAWLING" = TRAIT_MOVE_VENTCRAWLING,
		"TRAIT_RUNECHAT_HIDDEN" = TRAIT_RUNECHAT_HIDDEN,
		"TRAIT_SNOWSTORM_IMMUNE" = TRAIT_SNOWSTORM_IMMUNE,
		"TRAIT_VOIDSTORM_IMMUNE" = TRAIT_VOIDSTORM_IMMUNE,
		"TRAIT_WEATHER_IMMUNE" = TRAIT_WEATHER_IMMUNE,
	),
	/datum/controller/subsystem/economy = list(
	),
	// AKA SSstation
	/datum/controller/subsystem/processing/station = list(
	),
	/datum/wound = list(
	),
	/mob = list(
	),
	/obj/item = list(
		"TRAIT_APC_SHOCKING" = TRAIT_APC_SHOCKING,
		"TRAIT_DANGEROUS_OBJECT" = TRAIT_DANGEROUS_OBJECT,
		"TRAIT_HAUNTED" = TRAIT_HAUNTED,
		"TRAIT_NO_STORAGE_INSERT" = TRAIT_NO_STORAGE_INSERT,
		"TRAIT_NO_TELEPORT" = TRAIT_NO_TELEPORT,
		"TRAIT_NODROP" = TRAIT_NODROP,
		"TRAIT_T_RAY_VISIBLE" = TRAIT_T_RAY_VISIBLE,
		"TRAIT_UNCATCHABLE" = TRAIT_UNCATCHABLE,
	),
	/obj/item/bodypart = list(
	),
	/obj/item/bodypart = list(
	),
	/obj/item/card/id = list(
		"TRAIT_MAGNETIC_ID_CARD" = TRAIT_MAGNETIC_ID_CARD,
	),
	/obj/item/clothing = list(
	),
	/obj/item/fish = list(
		"TRAIT_FISH_CROSSBREEDER" = TRAIT_FISH_CROSSBREEDER,
		"TRAIT_FISH_FED_LUBE" = TRAIT_FISH_FED_LUBE,
		"TRAIT_FISH_NO_HUNGER" = TRAIT_FISH_NO_HUNGER,
		"TRAIT_FISH_NO_MATING" = TRAIT_FISH_NO_MATING,
		"TRAIT_FISH_SELF_REPRODUCE" = TRAIT_FISH_SELF_REPRODUCE,
		"TRAIT_FISH_TOXIN_IMMUNE" = TRAIT_FISH_TOXIN_IMMUNE,
		"TRAIT_RESIST_EMULSIFY" = TRAIT_RESIST_EMULSIFY,
		"TRAIT_YUCKY_FISH" = TRAIT_YUCKY_FISH,
	),
	/obj/item/integrated_circuit = list(
	),
	/obj/item/modular_computer = list(
	),
	/obj/item/organ = list(
	),
	/obj/item/organ/internal/liver = list(
		"TRAIT_BALLMER_SCIENTIST" = TRAIT_BALLMER_SCIENTIST,
		"TRAIT_COMEDY_METABOLISM" = TRAIT_COMEDY_METABOLISM,
		"TRAIT_CULINARY_METABOLISM" = TRAIT_CULINARY_METABOLISM,
		"TRAIT_ENGINEER_METABOLISM" = TRAIT_ENGINEER_METABOLISM,
		"TRAIT_LAW_ENFORCEMENT_METABOLISM" = TRAIT_LAW_ENFORCEMENT_METABOLISM,
		"TRAIT_MEDICAL_METABOLISM" = TRAIT_MEDICAL_METABOLISM,
		"TRAIT_PRETENDER_ROYAL_METABOLISM" = TRAIT_PRETENDER_ROYAL_METABOLISM,
		"TRAIT_ROYAL_METABOLISM" = TRAIT_ROYAL_METABOLISM,
	),
	/obj/item/organ/internal/lungs = list(
		"TRAIT_SPACEBREATHING" = TRAIT_SPACEBREATHING,
	),
	/obj/item/reagent_containers = list(
	),
	/obj/projectile = list(
	),
	/obj/structure = list(
	),
	/obj/vehicle = list(
	),
	/turf = list(
	),
))

/// value -> trait name, list of ALL traits that exist in the game, used for any type of accessing.
GLOBAL_LIST(global_trait_name_map)

/proc/generate_global_trait_name_map()
	. = list()
	for(var/key in GLOB.traits_by_type)
		for(var/tname in GLOB.traits_by_type[key])
			var/val = GLOB.traits_by_type[key][tname]
			.[val] = tname

	return .

GLOBAL_LIST_INIT(movement_type_trait_to_flag, list(
	TRAIT_MOVE_GROUND = GROUND,
	TRAIT_MOVE_FLYING = FLYING,
	TRAIT_MOVE_VENTCRAWLING = VENTCRAWLING,
	TRAIT_MOVE_FLOATING = FLOATING,
	TRAIT_MOVE_PHASING = PHASING,
))

GLOBAL_LIST_INIT(movement_type_addtrait_signals, set_movement_type_addtrait_signals())
GLOBAL_LIST_INIT(movement_type_removetrait_signals, set_movement_type_removetrait_signals())

/proc/set_movement_type_addtrait_signals(signal_prefix)
	. = list()
	for(var/trait in GLOB.movement_type_trait_to_flag)
		. += SIGNAL_ADDTRAIT(trait)

	return .

/proc/set_movement_type_removetrait_signals(signal_prefix)
	. = list()
	for(var/trait in GLOB.movement_type_trait_to_flag)
		. += SIGNAL_REMOVETRAIT(trait)

	return .
