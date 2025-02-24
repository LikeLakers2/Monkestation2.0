/obj/item/mail_bag_monke
	var/list/mail = list()

/obj/item/mail_bag_monke/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/mail_bag_monke/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MailBagStorage")
		ui.open()

/obj/item/mail_bag_monke/ui_data(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/list/data = list()

	return data

/obj/item/mail_bag_monke/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	//
