/mob/living/silicon/pai
	var/datum/pai_holochassis_info/holo_info = new

/datum/pai_holochassis_info
	/// The pAI's currently selected holoshell
	// ORIGINAL: mob.chassis
	var/datum/pai_holoshell/current_shell = new /datum/pai_holoshell/repairbot
	/// If the pAI can become a holoshell (i.e. someone has not disabled this function)
	// ORIGINAL: mob.can_holo
	var/enabled = TRUE
	/// The remaining health of the pAI's holoshell before it is forcibly returned to card form
	// ORIGINAL: mob.holochassis_health
	var/health = 20
	/// If the holoshell is ready for use (i.e. the emitters are done recycling)
	// ORIGINAL: mob.holochassis_ready
	var/ready = FALSE
	/// If the pAI is currently in holoshell form
	// ORIGINAL: mob.holoform
	var/in_use = FALSE

/datum/pai_holochassis_info/proc/can_be_picked_up()
	return current_shell.can_be_held
