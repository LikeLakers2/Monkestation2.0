/datum/pai_holoshell
	var/name
	/// Can the pAI be held and worn when in this holoshell?
	var/can_be_held = FALSE

	// ICON SETTINGS
	// The below variables determine which icon files will be used during certain situations.
	/// A string prefix used to identify which icon states from the `*_icon` variables will be used.
	/// The suffixes used for each state (standing, moving, sitting, held, etc.) are denoted under
	/// the relevant variables.
	var/icon_state_prefix
	/// The icon file used when this holoshell has folded out and is active.
	///
	/// This file should have the following icon states:
	/// * "[icon_state_prefix]" for standing (with an optional movement state)
	/// * "[icon_state_prefix]_rest" for resting
	/// * "[icon_state_prefix]_dead" for dead
	var/icon/normal_icon = 'icons/mob/silicon/pai.dmi'
	/// The icon file used when a mob is holding this holoshell in their left hand (only applicable
	/// if `can_be_held` is `TRUE`).
	///
	/// This file should have an icon state with the same name as `icon_state_prefix`.
	var/icon/held_lh_icon = 'icons/mob/inhands/pai_item_lh.dmi'
	/// The icon file used when a mob is holding this holoshell in their right hand (only applicable
	/// if `can_be_held` is `TRUE`).
	///
	/// This file should have an icon state with the same name as `icon_state_prefix`.
	var/icon/held_rh_icon = 'icons/mob/inhands/pai_item_rh.dmi'
	/// The icon file used when a mob is wearing this holoshell on their head (only applicable if
	/// `can_be_held` is `TRUE`).
	///
	/// This file should have an icon state with the same name as `icon_state_prefix`.
	var/icon/worn_head_icon = 'icons/mob/clothing/head/pai_head.dmi'

/datum/pai_holoshell/bat
	name = "Bat"
	icon_state_prefix = "bat"

/datum/pai_holoshell/butterfly
	name = "Butterfly"
	icon_state_prefix = "butterfly"

/datum/pai_holoshell/cat
	name = "Cat"
	icon_state_prefix = "cat"
	can_be_held = TRUE

/datum/pai_holoshell/chicken
	name = "Chicken"
	icon_state_prefix = "chicken"

/datum/pai_holoshell/corgi
	name = "Corgi"
	icon_state_prefix = "corgi"

/datum/pai_holoshell/crow
	name = "Crow"
	icon_state_prefix = "crow"
	can_be_held = TRUE

/datum/pai_holoshell/duffel_bag
	name = "Duffel Bag"
	icon_state_prefix = "duffel"
	can_be_held = TRUE

/datum/pai_holoshell/fox
	name = "Fox"
	icon_state_prefix = "fox"
	// should probably be holdable since the captain's pet fox is
	// but we need sprites for this

/datum/pai_holoshell/frog
	name = "Frog"
	icon_state_prefix = "frog"
	can_be_held = TRUE

/datum/pai_holoshell/hawk
	name = "Hawk"
	icon_state_prefix = "hawk"

/datum/pai_holoshell/kitten
	name = "Kitten"
	icon_state_prefix = "kitten"

/datum/pai_holoshell/lizard
	name = "Lizard"
	icon_state_prefix = "lizard"

/datum/pai_holoshell/monkey
	name = "Monkey"
	icon_state_prefix = "monkey"
	can_be_held = TRUE

/datum/pai_holoshell/mouse
	name = "Mouse"
	icon_state_prefix = "mouse"
	can_be_held = TRUE

/datum/pai_holoshell/puppy
	name = "Puppy"
	icon_state_prefix = "puppy"

/datum/pai_holoshell/rabbit
	name = "Rabbit"
	icon_state_prefix = "rabbit"
	can_be_held = TRUE

/datum/pai_holoshell/repairbot
	name = "Repairbot"
	icon_state_prefix = "repairbot"
	can_be_held = TRUE

/datum/pai_holoshell/spider
	name = "Spider"
	icon_state_prefix = "spider"
