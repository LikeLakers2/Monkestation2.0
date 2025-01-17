/mob/living/silicon/pai/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	client.perspective = EYE_PERSPECTIVE
	/* //MONKESTATION EDIT START - pAIs are being refactored
	if(holoform)
	*/ //MONKESTATION EDIT ORIGINAL
	if(src.holo_in_use)
	//MONKESTATION EDIT END
		client.set_eye(src)
	else
		client.set_eye(card)
