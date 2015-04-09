/obj/item/weapon/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = 1
	var/amount_per_transfer_from_this = 5
	var/possible_transfer_amounts = list(5,10,15,25,30)
	var/volume = 30
	var/list/banned_reagents = list() //List of reagent IDs we reject.
	var/list/list_reagents = null
	var/spawned_disease = null
	var/disease_amount = 20

/obj/item/weapon/reagent_containers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in range(0)
	if(usr.stat || !usr.canmove || usr.restrained())
		return
	var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
	if (N)
		amount_per_transfer_from_this = N

/obj/item/weapon/reagent_containers/New(location, vol = 0)
	..()
	if (!possible_transfer_amounts)
		src.verbs -= /obj/item/weapon/reagent_containers/verb/set_APTFT
	if (vol > 0)
		volume = vol
	create_reagents(volume)
	if(spawned_disease)
		var/datum/disease/F = new spawned_disease(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", disease_amount, data)
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/weapon/reagent_containers/attack_self(mob/user as mob)
	return

/obj/item/weapon/reagent_containers/attack(mob/M as mob, mob/user as mob, def_zone)
	return

/obj/item/weapon/reagent_containers/afterattack(obj/target, mob/user , flag)
	return

/obj/item/weapon/reagent_containers/proc/reagentlist(var/obj/item/weapon/reagent_containers/snack) //Attack logs for regents in pills
	var/data
	if(snack.reagents.reagent_list && snack.reagents.reagent_list.len) //find a reagent list if there is and check if it has entries
		for (var/datum/reagent/R in snack.reagents.reagent_list) //no reagents will be left behind
			data += "[R.id]([R.volume] units); " //Using IDs because SOME chemicals(I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
		return data
	else return "No reagents"

/obj/item/weapon/reagent_containers/proc/canconsume(mob/eater, mob/user)
	if(!eater.SpeciesCanConsume())
		return 0
	//Check for covering mask
	var/obj/item/clothing/cover = eater.get_item_by_slot(slot_wear_mask)

	if(isnull(cover)) // No mask, do we have any helmet?
		cover = eater.get_item_by_slot(slot_head)
	else
		var/obj/item/clothing/mask/covermask = cover
		if(covermask.alloweat) // Specific cases, clownmask for example.
			return 1

	if(!isnull(cover))
		if((cover.flags & HEADCOVERSMOUTH) || (cover.flags & MASKCOVERSMOUTH))
			var/who = (isnull(user) || eater == user) ? "your" : "their"

			if(istype(cover, /obj/item/clothing/mask/))
				user << "<span class='warning'>You have to remove [who] mask first!</span>"
			else
				user << "<span class='warning'>You have to remove [who] helmet first!</span>"

			return 0
	return 1

/obj/item/weapon/reagent_containers/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	..()

/obj/item/weapon/reagent_containers/fire_act()
	reagents.chem_temp += 30
	reagents.handle_reactions()
	..()