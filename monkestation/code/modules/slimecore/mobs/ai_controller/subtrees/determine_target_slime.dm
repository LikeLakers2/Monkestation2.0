/// So apparently, find_potential_target makes no attempt to actually let you choose its priority -
/// no matter what, it will always override the target key.
///
/// Alongside this, find_food explicitly tries to avoid letting you prioritize it at all - if the
/// target key has a value, it just doesn't run.
///
/// So as a hack, the two put their values into different target keys, and this subtree determines
/// which key becomes the ACTUAL target.
// TODO: This should be removed when https://github.com/tgstation/tgstation/pull/87166 is ported.
/datum/ai_planning_subtree/slime_determine_actual_target

/datum/ai_planning_subtree/slime_determine_actual_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	controller.queue_behavior(/datum/ai_behavior/slime_determine_actual_target)

// Yes the behavior is in the same file. Sue me.
/datum/ai_behavior/slime_determine_actual_target

/datum/ai_behavior/slime_determine_actual_target/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	if(controller.blackboard_key_exists(BB_SLIME_CURRENT_TARGET_FOOD))
		// Food first
		controller.override_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, controller.blackboard[BB_SLIME_CURRENT_TARGET_FOOD])
	else if(controller.blackboard_key_exists(BB_SLIME_CURRENT_TARGET_MOB))
		// Then mobs
		controller.override_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, controller.blackboard[BB_SLIME_CURRENT_TARGET_MOB])
