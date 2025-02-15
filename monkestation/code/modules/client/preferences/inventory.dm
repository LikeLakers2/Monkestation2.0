#define DONATOR_ROUNDEND_BONUS 25 //25 monkecoin for donators

/datum/preferences/proc/load_inventory(ckey)
	if(!ckey || !SSdbcore.IsConnected())
		return

	if(SSdbcore.IsConnected())
		var/datum/db_query/query_gear = SSdbcore.NewQuery(
			"SELECT item_id,amount FROM [format_table_name("metacoin_item_purchases")] WHERE ckey = :ckey",
			list("ckey" = ckey)
		)
		if(!query_gear.Execute())
			qdel(query_gear)
			return
		while(query_gear.NextRow())
			var/key = query_gear.item[1]
			inventory += text2path(key)
		qdel(query_gear)
	else
		var/items = savefile.get_entry("metacoin_item_purchases", list())
		for(var/key in items)
			inventory += text2path(key)

// Adds an item to the player's inventory.
//
// Items will always be added to the player's current-round inventory. However, adding the item to
// the player's persistent inventory may fail - and as such, this returns a boolean describing
// whether adding the item to the player's persistent inventory succeeded.
//
// The following is a (potentially non-exhaustive) list of reasons why this might return FALSE:
// * The database is enabled in the config, but is not currently connected
// * The database query failed for one reason or another
/datum/preferences/proc/add_item_to_inventory(item_id)
	if(inventory[item_id])
		return TRUE

	inventory += item_id
	if(CONFIG_GET(flag/sql_enabled))
		if(!SSdbcore.IsConnected())
			return FALSE

		var/datum/db_query/query_add_gear_purchase = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("metacoin_item_purchases")] (`ckey`, `item_id`, `amount`) VALUES (:ckey, :item_id, :amount)"},
			list("ckey" = parent.ckey, "item_id" = item_id, "amount" = 1))
		if(!query_add_gear_purchase.Execute())
			qdel(query_add_gear_purchase)
			return FALSE
		qdel(query_add_gear_purchase)
	else
		//File fallback - intended for use only during debugging
		var/list/metacoin_items = savefile.get_entry("metacoin_item_purchases", list())
		metacoin_items[item_id] = 1
		savefile.set_entry("metacoin_item_purchases", metacoin_items)
		savefile.save()
	return TRUE

/datum/preferences/proc/load_metacoins(ckey)
	if(!ckey)
		metacoins = 5000
		return

	if(SSdbcore.IsConnected())
		var/datum/db_query/query_get_metacoins = SSdbcore.NewQuery("SELECT metacoins FROM [format_table_name("player")] WHERE ckey = '[ckey]'")
		var/mc_count = 0
		if(query_get_metacoins.warn_execute())
			if(query_get_metacoins.NextRow())
				mc_count = query_get_metacoins.item[1]

		qdel(query_get_metacoins)
		metacoins = text2num(mc_count)
	else
		//File fallback - intended for use only during debugging
		metacoins = savefile.get_entry("metacoins", 5000)


/datum/preferences/proc/adjust_metacoins(ckey, amount, reason = null, announces = TRUE, donator_multipler = TRUE, respects_roundcap = FALSE)
	if(!ckey)
		return FALSE

	//RoundCap Checks
	if(!max_round_coins && respects_roundcap)
		to_chat(parent, "You've hit the Monkecoin limit for this shift, please try again next shift.")
		return
	if(respects_roundcap)
		if(max_round_coins <= amount)
			amount = max_round_coins
		max_round_coins -= amount

	//Patreon Flat Roundend Bonus
	if((parent.player_details.patreon?.has_access(2)) && donator_multipler)
		amount += DONATOR_ROUNDEND_BONUS

	//Twitch Flat Roundend Bonus
	if((parent.player_details.twitch?.has_access(1)) && donator_multipler)
		amount += DONATOR_ROUNDEND_BONUS

	//Donator Multiplier
	if(amount > 0 && donator_multipler)
		switch(parent.player_details.patreon.access_rank)
			if(ACCESS_COMMAND_RANK)
				amount *= 1.5
			if(ACCESS_TRAITOR_RANK)
				amount *= 2
			if(ACCESS_NUKIE_RANK)
				amount *= 3

	amount = round(amount, 1) //make sure whole number
	metacoins += amount //store the updated metacoins in a variable, but not the actual game-to-game storage mechanism (load_metacoins() pulls from database)

	logger.Log(LOG_CATEGORY_META, "[parent]'s monkecoins were changed by [amount] Reason: [reason]", list("currency_left" = metacoins, "reason" = reason))

	save_metacoins(ckey)

	//Output to chat
	if(announces)
		if(reason)
			to_chat(parent, "<span class='rose bold'>[abs(amount)] Monkecoins have been [amount >= 0 ? "deposited to" : "withdrawn from"] your account! Reason: [reason]</span>")
		else
			to_chat(parent, "<span class='rose bold'>[abs(amount)] Monkecoins have been [amount >= 0 ? "deposited to" : "withdrawn from"] your account!</span>")
	return TRUE

/datum/preferences/proc/save_metacoins(ckey)
	if(!ckey)
		return FALSE

	if(SSdbcore.IsConnected())
		//SQL query - updates the metacoins in the database (this is where the storage actually happens)
		var/datum/db_query/query_inc_metacoins = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET metacoins = [metacoins] WHERE ckey = '[ckey]'")
		query_inc_metacoins.warn_execute()
		qdel(query_inc_metacoins)
	else
		//File fallback - intended for use only during debugging
		savefile.set_entry("metacoins", metacoins)
		savefile.save()

/datum/preferences/proc/has_coins(amount)
	if(amount > metacoins)
		return FALSE
	return TRUE
