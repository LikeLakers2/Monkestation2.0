/// Similar to `/datum/ai_planning_subtree/find_food`, but for slimes, which need to set a different
/// key than `BB_BASIC_MOB_CURRENT_TARGET`.
// TODO: This should be removed when https://github.com/tgstation/tgstation/pull/87166 is ported.
/datum/ai_planning_subtree/slime_find_food

/datum/ai_planning_subtree/slime_find_food/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	controller.queue_behavior(/datum/ai_behavior/find_and_set/in_list, BB_SLIME_CURRENT_TARGET_FOOD, controller.blackboard[BB_BASIC_FOODS])
