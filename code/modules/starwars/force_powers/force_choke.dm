/obj/effect/proc_holder/spell/targeted/forceck
	name = "Force Choke"
	desc = "Choke your target, to death! (Using the force)."
	clothes_req = FALSE
	invocation = "Force Choke!"
	invocation_type = "shout"
	var/amt_knockdown = 0
	var/amt_unconscious = 20
	var/amt_stun = 0

	//set to negatives for healing
	var/amt_dam_fire = 0
	var/amt_dam_brute = 30
	var/amt_dam_oxy = 10
	var/amt_dam_tox = 0

	var/amt_eye_blind = 0
	var/amt_eye_blurry = 0

	var/destroys = "none" //can be "none", "gib" or "disintegrate"

	var/summon_type = null //this will put an obj at the target's location

	var/check_anti_magic = TRUE
	var/check_holy = FALSE
	action_icon = 'icons/starwars/force_powers.dmi'
	action_icon_state = "force_choke"

/obj/effect/proc_holder/spell/targeted/forceck/cast(list/targets,mob/user = usr)
	for(var/mob/living/target in targets)
		playsound(target,sound, 50,1)
		if(target.anti_magic_check(check_anti_magic, check_holy))
			return
		switch(destroys)
			if("gib")
				target.gib()
			if("disintegrate")
				target.dust()

		if(!target)
			continue
		//damage/healing
		target.adjustBruteLoss(amt_dam_brute)
		target.adjustFireLoss(amt_dam_fire)
		target.adjustToxLoss(amt_dam_tox)
		target.adjustOxyLoss(amt_dam_oxy)
		//disabling
		target.Knockdown(amt_knockdown)
		target.Unconscious(amt_unconscious)
		target.Stun(amt_stun)

		target.blind_eyes(amt_eye_blind)
		target.blur_eyes(amt_eye_blurry)
		//summoning
		if(summon_type)
			new summon_type(target.loc, target)