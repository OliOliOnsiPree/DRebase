/obj/item/cartridge/virus
	name = "Generic Virus PDA cart"
	var/charges = 5

/obj/item/cartridge/virus/proc/send_virus(obj/item/pda/target, mob/living/U)
	return

/obj/item/cartridge/virus/message_header()
	return "<b>[charges] viral files left.</b><HR>"

/obj/item/cartridge/virus/message_special(obj/item/pda/target)
	if (!istype(loc, /obj/item/pda))
		return ""  //Sanity check, this shouldn't be possible.
	return " (<a href='byond://?src=[REF(loc)];choice=cart;special=virus;target=[REF(target)]'>*Send Virus*</a>)"

/obj/item/cartridge/virus/special(mob/living/user, list/params)
	var/obj/item/pda/P = locate(params["target"])//Leaving it alone in case it may do something useful, I guess.
	send_virus(P,user)

/obj/item/cartridge/virus/syndicate
	name = "\improper Detomatix cartridge"
	access = CART_REMOTE_DOOR
	remote_door_id = "smindicate" //Make sure this matches the syndicate shuttle's shield/door id!!	//don't ask about the name, testing.
	charges = 4

/obj/item/cartridge/virus/syndicate/send_virus(obj/item/pda/target, mob/living/U)
	if(charges <= 0)
		to_chat(U, span_notice("Out of charges."))
		return
	if(!isnull(target) && !target.toff)
		charges--
		var/difficulty = 0
		if(target.cartridge)
			difficulty += BitCount(target.cartridge.access&(CART_MEDICAL | CART_SECURITY | CART_ENGINE | CART_JANITOR | CART_MANIFEST))
			if(target.cartridge.access & CART_MANIFEST)
				difficulty++ //if cartridge has manifest access it has extra snowflake difficulty
			else
				difficulty += 2
		var/datum/component/uplink/hidden_uplink = target.GetComponent(/datum/component/uplink)
		if(!target.detonatable || prob(difficulty * 15) || (hidden_uplink))
			U.show_message(span_danger("An error flashes on your [src]."), MSG_VISUAL)
		else
			message_admins("[!is_special_character(U) ? "Non-antag " : ""][ADMIN_LOOKUPFLW(U)] triggered a PDA explosion on [target.name] at [ADMIN_VERBOSEJMP(target)].")
			var/message_log = "triggered a PDA explosion on [target.name] at [AREACOORD(target)]."
			U.log_message(message_log, LOG_ATTACK)
			U.show_message(span_notice("Success!"), MSG_VISUAL)
			target.explode()
	else
		to_chat(U, "PDA not found.")

/obj/item/cartridge/virus/frame
	name = "\improper F.R.A.M.E. cartridge"
	icon_state = "cart-f"
	var/telecrystals = 0

/obj/item/cartridge/virus/frame/send_virus(obj/item/pda/target, mob/living/U)
	if(charges <= 0)
		to_chat(U, span_notice("Out of charges."))
		return
	if(!isnull(target) && !target.toff)
		charges--
		var/lock_code = "[rand(100,999)] [pick(GLOB.phonetic_alphabet)]"
		to_chat(U, span_notice("Virus Sent!  The unlock code to the target is: [lock_code]"))
		var/datum/component/uplink/hidden_uplink = target.GetComponent(/datum/component/uplink)
		if(!hidden_uplink)
			hidden_uplink = target.AddComponent(/datum/component/uplink)
			hidden_uplink.unlock_code = lock_code
		else
			hidden_uplink.hidden_crystals += hidden_uplink.telecrystals //Temporarially hide the PDA's crystals, so you can't steal telecrystals.
		hidden_uplink.telecrystals = telecrystals
		telecrystals = 0
		hidden_uplink.active = TRUE
	else
		to_chat(U, "PDA not found.")
