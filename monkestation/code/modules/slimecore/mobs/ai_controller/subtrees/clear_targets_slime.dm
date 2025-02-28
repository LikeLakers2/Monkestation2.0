// A hack to ensure that we're 
/datum/ai_planning_subtree/slime_clear_targets

/datum/ai_planning_subtree/slime_clear_targets/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(BB_SLIME_CURRENT_TARGET_FOOD) && !controller.blackboard_key_exists(BB_SLIME_CURRENT_TARGET_MOB))
		return

/datum/ai_behavior/slime_clear_targets

/datum/ai_behavior/slime_clear_targets/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	if(controller.blackboard_key_exists(BB_SLIME_CURRENT_TARGET_FOOD))
		controller.clear_blackboard_key(BB_SLIME_CURRENT_TARGET_FOOD)
	if(controller.blackboard_key_exists(BB_SLIME_CURRENT_TARGET_MOB))
		controller.clear_blackboard_key(BB_SLIME_CURRENT_TARGET_MOB)
