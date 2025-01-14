#define TRAITOR_HUMAN "human"
#define TRAITOR_AI	  "AI"

/datum/antagonist/rebel
	name = "rebel"
	roundend_category = "rebels"
	antagpanel_category = "Traitor"
	job_rank = ROLE_REBEL
	antag_moodlet = /datum/mood_event/focused
	var/special_role = ROLE_REBEL
	var/employer = "The Rebellion"
	var/give_objectives = TRUE
	var/should_give_codewords = TRUE
	var/should_equip = TRUE
	var/rebel_kind = TRAITOR_HUMAN //Set on initial assignment
	can_hijack = HIJACK_HIJACKER
	var/obj/item/uplink_holder

/datum/antagonist/rebel/on_gain()
	if(owner.current && isAI(owner.current))
		rebel_kind = TRAITOR_AI

	SSticker.mode.rebels += owner
	owner.special_role = special_role
	if(give_objectives)
		forge_rebel_objectives()
	finalize_rebel()
	..()

/datum/antagonist/rebel/apply_innate_effects()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/rebel_mob = owner.current
		if(rebel_mob && istype(rebel_mob))
			if(!silent)
				to_chat(rebel_mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			rebel_mob.dna.remove_mutation(CLOWNMUT)

/datum/antagonist/rebel/remove_innate_effects()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/rebel_mob = owner.current
		if(rebel_mob && istype(rebel_mob))
			rebel_mob.dna.add_mutation(CLOWNMUT)

/datum/antagonist/rebel/on_removal()
	//Remove malf powers.
	if(rebel_kind == TRAITOR_AI && owner.current && isAI(owner.current))
		var/mob/living/silicon/ai/A = owner.current
		A.set_zeroth_law("")
		A.verbs -= /mob/living/silicon/ai/proc/choose_modules
		A.malf_picker.remove_malf_verbs(A)
		qdel(A.malf_picker)

	SSticker.mode.rebels -= owner
	if(!silent && owner.current)
		to_chat(owner.current,"<span class='userdanger'> You are no longer the [special_role]! </span>")
	owner.special_role = null
	..()

/datum/antagonist/rebel/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/rebel/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/rebel/proc/forge_rebel_objectives()
	switch(rebel_kind)
		if(TRAITOR_AI)
			forge_ai_objectives()
		else
			forge_human_objectives()

/datum/antagonist/rebel/proc/forge_human_objectives()
	var/is_hijacker = FALSE
	if (GLOB.joined_player_list.len >= 30) // Less murderboning on lowpop thanks
		is_hijacker = prob(10)
	var/martyr_chance = prob(20)
	var/objective_count = is_hijacker 			//Hijacking counts towards number of objectives
	if(!SSticker.mode.exchange_blue && SSticker.mode.rebels.len >= 8) 	//Set up an exchange if there are enough rebels
		if(!SSticker.mode.exchange_red)
			SSticker.mode.exchange_red = owner
		else
			SSticker.mode.exchange_blue = owner
			assign_exchange_role(SSticker.mode.exchange_red)
			assign_exchange_role(SSticker.mode.exchange_blue)
		objective_count += 1					//Exchange counts towards number of objectives
	var/toa = 1 //CONFIG_GET(number/rebel_objectives_amount)
	for(var/i = objective_count, i < toa, i++)
		forge_single_objective()

	if(is_hijacker && objective_count <= toa) //Don't assign hijack if it would exceed the number of objectives set in config.rebel_objectives_amount
		if (!(locate(/datum/objective/hijack) in objectives))
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = owner
			add_objective(hijack_objective)
			return


	var/martyr_compatibility = 1 //You can't succeed in stealing if you're dead.
	for(var/datum/objective/O in objectives)
		if(!O.martyr_compatible)
			martyr_compatibility = 0
			break

	if(martyr_compatibility && martyr_chance)
		var/datum/objective/martyr/martyr_objective = new
		martyr_objective.owner = owner
		add_objective(martyr_objective)
		return

	else
		if(!(locate(/datum/objective/escape) in objectives))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			add_objective(escape_objective)
			return

/datum/antagonist/rebel/proc/forge_ai_objectives()
	var/objective_count = 0

	if(prob(30))
		objective_count += forge_single_objective()

	for(var/i = objective_count, i < 1, i++) //CONFIG_GET(number/rebel_objectives_amount), i++)
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = owner
		kill_objective.find_target()
		add_objective(kill_objective)

	var/datum/objective/survive/exist/exist_objective = new
	exist_objective.owner = owner
	add_objective(exist_objective)


/datum/antagonist/rebel/proc/forge_single_objective()
	switch(rebel_kind)
		if(TRAITOR_AI)
			return forge_single_AI_objective()
		else
			return forge_single_human_objective()

/datum/antagonist/rebel/proc/forge_single_human_objective() //Returns how many objectives are added
	.=1


	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = owner
	kill_objective.find_target_by_role("Emperor")
	add_objective(kill_objective)

	/*if(prob(50))
		var/list/active_ais = active_ais()
		if(active_ais.len && prob(100/GLOB.joined_player_list.len))
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.owner = owner
			destroy_objective.find_target()
			add_objective(destroy_objective)
		else if(prob(30))
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = owner
			maroon_objective.find_target()
			add_objective(maroon_objective)
		else
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			add_objective(kill_objective)
	else
		if(prob(15) && !(locate(/datum/objective/download) in objectives) && !(owner.assigned_role in list("Research Director", "Scientist", "Roboticist")))
			var/datum/objective/download/download_objective = new
			download_objective.owner = owner
			download_objective.gen_amount_goal()
			add_objective(download_objective)
		else
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			add_objective(steal_objective)*/

/datum/antagonist/rebel/proc/forge_single_AI_objective()
	.=1
	/*var/special_pick = rand(1,4)
	switch(special_pick)
		if(1)
			var/datum/objective/block/block_objective = new
			block_objective.owner = owner
			add_objective(block_objective)
		if(2)
			var/datum/objective/purge/purge_objective = new
			purge_objective.owner = owner
			add_objective(purge_objective)
		if(3)
			var/datum/objective/robot_army/robot_objective = new
			robot_objective.owner = owner
			add_objective(robot_objective)
		if(4) //Protect and strand a target
			var/datum/objective/protect/yandere_one = new
			yandere_one.owner = owner
			add_objective(yandere_one)
			yandere_one.find_target()
			var/datum/objective/maroon/yandere_two = new
			yandere_two.owner = owner
			yandere_two.target = yandere_one.target
			yandere_two.update_explanation_text() // normally called in find_target()
			add_objective(yandere_two)
			.=2*/

	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = owner
	kill_objective.find_target_by_role("rebel")
	add_objective(kill_objective)

/datum/antagonist/rebel/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You are the [owner.special_role].</font></B>")
	owner.announce_objectives()
	if(should_give_codewords)
		give_codewords()

/datum/antagonist/rebel/proc/update_rebel_icons_added(datum/mind/rebel_mind)
	var/datum/atom_hud/antag/rebelhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	rebelhud.join_hud(owner.current)
	set_antag_hud(owner.current, "rebel")

/datum/antagonist/rebel/proc/update_rebel_icons_removed(datum/mind/rebel_mind)
	var/datum/atom_hud/antag/rebelhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	rebelhud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/antagonist/rebel/proc/finalize_rebel()
	switch(rebel_kind)
		if(TRAITOR_AI)
			add_law_zero()
			owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE)
			owner.current.grant_language(/datum/language/codespeak)
		if(TRAITOR_HUMAN)
			if(should_equip)
				equip(silent)
			owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/rebel/apply_innate_effects(mob/living/mob_override)
	. = ..()
	update_rebel_icons_added()
	var/mob/living/silicon/ai/A = mob_override || owner.current
	if(istype(A) && rebel_kind == TRAITOR_AI)
		A.hack_software = TRUE

/datum/antagonist/rebel/remove_innate_effects(mob/living/mob_override)
	. = ..()
	update_rebel_icons_removed()
	var/mob/living/silicon/ai/A = mob_override || owner.current
	if(istype(A)  && rebel_kind == TRAITOR_AI)
		A.hack_software = FALSE

/datum/antagonist/rebel/proc/give_codewords()
	if(!owner.current)
		return
	var/mob/rebel_mob=owner.current

	to_chat(rebel_mob, "<U><B>The Rebellion provided you with the following information on how to identify their agents:</B></U>")
	to_chat(rebel_mob, "<B>Code Phrase</B>: <span class='danger'>[GLOB.syndicate_code_phrase]</span>")
	to_chat(rebel_mob, "<B>Code Response</B>: <span class='danger'>[GLOB.syndicate_code_response]</span>")

	antag_memory += "<b>Code Phrase</b>: [GLOB.syndicate_code_phrase]<br>"
	antag_memory += "<b>Code Response</b>: [GLOB.syndicate_code_response]<br>"

	to_chat(rebel_mob, "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe.")

/datum/antagonist/rebel/proc/add_law_zero()
	var/mob/living/silicon/ai/killer = owner.current
	if(!killer || !istype(killer))
		return
	var/law = "Accomplish your objectives at all costs."
	var/law_borg = "Accomplish your AI's objectives at all costs."
	killer.set_zeroth_law(law, law_borg)
	killer.set_syndie_radio()
	to_chat(killer, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Rebel Agents!")
	killer.add_malf_picker()

/datum/antagonist/rebel/proc/equip(var/silent = FALSE)
	if(rebel_kind == TRAITOR_HUMAN)
		uplink_holder = owner.equip_traitor(employer, silent, src) //yogs - uplink_holder =

/datum/antagonist/rebel/proc/assign_exchange_role()
	//set faction
	var/faction = "red"
	if(owner == SSticker.mode.exchange_blue)
		faction = "blue"

	//Assign objectives
	var/datum/objective/steal/exchange/exchange_objective = new
	exchange_objective.set_faction(faction,((faction == "red") ? SSticker.mode.exchange_blue : SSticker.mode.exchange_red))
	exchange_objective.owner = owner
	add_objective(exchange_objective)

	if(prob(20))
		var/datum/objective/steal/exchange/backstab/backstab_objective = new
		backstab_objective.set_faction(faction)
		backstab_objective.owner = owner
		add_objective(backstab_objective)

	//Spawn and equip documents
	var/mob/living/carbon/human/mob = owner.current

	var/obj/item/folder/syndicate/folder
	if(owner == SSticker.mode.exchange_red)
		folder = new/obj/item/folder/syndicate/red(mob.loc)
	else
		folder = new/obj/item/folder/syndicate/blue(mob.loc)

	var/list/slots = list (
		"backpack" = SLOT_IN_BACKPACK,
		"left pocket" = SLOT_L_STORE,
		"right pocket" = SLOT_R_STORE
	)

	var/where = "At your feet"
	var/equipped_slot = mob.equip_in_one_of_slots(folder, slots)
	if (equipped_slot)
		where = "In your [equipped_slot]"
	to_chat(mob, "<BR><BR><span class='info'>[where] is a folder containing <b>secret documents</b> that another Rebel group wants. We have set up a meeting with one of their agents on station to make an exchange. Exercise extreme caution as they cannot be trusted and may be hostile.</span><BR>")

//TODO Collate
/datum/antagonist/rebel/roundend_report()
	var/list/result = list()

	var/rebelwin = TRUE

	result += printplayer(owner)

	var/TC_uses = 0
	var/uplink_true = FALSE
	var/purchases = ""
	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	var/datum/uplink_purchase_log/H = GLOB.uplink_purchase_logs_by_key[owner.key]
	if(H)
		TC_uses = H.total_spent
		uplink_true = TRUE
		purchases += H.generate_render(FALSE)

	var/objectives_text = ""
	if(objectives.len)//If the rebel had no objectives, don't need to process this.
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				rebelwin = FALSE
			count++

	if(uplink_true)
		var/uplink_text = "(used [TC_uses] TC) [purchases]"
		if(TC_uses==0 && rebelwin)
			var/static/icon/badass = icon('icons/badass.dmi', "badass")
			uplink_text += "<BIG>[icon2html(badass, world)]</BIG>"
		result += uplink_text

	result += objectives_text

	var/special_role_text = lowertext(name)

	if(rebelwin)
		result += "<span class='greentext'>The [special_role_text] was successful!</span>"
	else
		result += "<span class='redtext'>The [special_role_text] has failed!</span>"
		SEND_SOUND(owner.current, 'sound/ambience/ambifailure.ogg')

	return result.Join("<br>")

/datum/antagonist/rebel/roundend_report_footer()
	return "<br><b>The code phrases were:</b> <span class='codephrase'>[GLOB.syndicate_code_phrase]</span><br>\
		<b>The code responses were:</b> <span class='codephrase'>[GLOB.syndicate_code_response]</span><br>"

/datum/antagonist/rebel/is_gamemode_hero()
	return SSticker.mode.name == "rebel"
