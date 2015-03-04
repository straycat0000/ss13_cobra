// Foam
// Similar to smoke, but spreads out more

/obj/effect/effect/foam
	name = "foam"
	icon_state = "foam"
	opacity = 0
	anchored = 1
	density = 0
	layer = TURF_LAYER + 0.1
	mouse_opacity = 0
	var/amount = 3
	var/expand = 1
	animate_movement = 0
	var/metal = 0
	var/lifetime = 6


/obj/effect/effect/foam/metal/aluminium
	name = "aluminium foam"
	metal = 1
	icon_state = "mfoam"


/obj/effect/effect/foam/metal/iron
	name = "iron foam"
	metal = 2


/obj/effect/effect/foam/New(loc)
	..(loc)
	create_reagents(1000) //limited by the size of the reagent holder anyway.
	SSobj.processing.Add(src)
	playsound(src, 'sound/effects/bubbles2.ogg', 80, 1, -3)


/obj/effect/effect/foam/metal/New(loc)
	..()
	var/obj/structure/foamedmetal/M = new(src.loc)
	M.metal = metal
	M.updateicon()


/obj/effect/effect/foam/proc/kill_foam()
	SSobj.processing.Remove(src)
	flick("[icon_state]-disolve", src)
	spawn(5)
		delete()


/obj/effect/effect/foam/process()
	lifetime--
	if(lifetime < 1)
		kill_foam()
	if(--amount < 0)
		return
	for(var/atom/M in view(1,src))
		if(M == src)
			continue
		reagents.reaction(M, TOUCH)
	spread_foam()


/obj/effect/effect/foam/Crossed(var/atom/movable/AM)
	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		M.slip(5, 2, src)


/obj/effect/effect/foam/metal/Crossed(var/atom/movable/AM)
	return


/obj/effect/effect/foam/proc/spread_foam()
	for(var/direction in cardinal)
		var/turf/T = get_step(src,direction)
		if(!T)
			continue

		if(!T.Enter(src))
			continue

		var/obj/effect/effect/foam/foundfoam = locate() in T //Don't spread foam where there's already foam!
		if(foundfoam)
			continue

		var/obj/effect/effect/foam/F = new type(T)
		F.amount = amount
		reagents.copy_to(F, (reagents.total_volume))
		F.color = color


/obj/effect/effect/foam/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 475))) //foam dissolves when heated
		kill_foam()


/obj/effect/effect/foam/metal/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return


///////////////////////////////////////////////
//FOAM EFFECT DATUM
/datum/effect/effect/system/foam_spread
	var/amount = 5		// the size of the foam spread.
	var/obj/chemholder
	var/obj/effect/effect/foam/foamtype = /obj/effect/effect/foam
	var/metal = 0


/datum/effect/effect/system/foam_spread/metal
	foamtype = /obj/effect/effect/foam/metal


/datum/effect/effect/system/foam_spread/New()
	..()
	chemholder = new/obj()
	var/datum/reagents/R = new/datum/reagents(1000)
	chemholder.reagents = R
	R.my_atom = chemholder


/datum/effect/effect/system/foam_spread/set_up(amt=5, loca, var/datum/reagents/carry = null)
	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)

	amount = round(sqrt(amt / 3), 1)
	carry.copy_to(chemholder, carry.total_volume)


/datum/effect/effect/system/foam_spread/metal/set_up(amt=5, loca, var/datum/reagents/carry = null, var/metaltype)
	..()
	metal = metaltype

/datum/effect/effect/system/foam_spread/start()
	var/obj/effect/effect/foam/foundfoam = locate()
	if(foundfoam)//If there was already foam where we start, we add our foaminess to it.
		foundfoam.amount += amount
	else
		var/obj/effect/effect/foam/F = new foamtype(src.location)
		var/foamcolor = mix_color_from_reagents(chemholder.reagents.reagent_list)
		chemholder.reagents.copy_to(F, chemholder.reagents.total_volume)
		F.color = foamcolor
		F.amount = amount
		F.metal = metal


//////////////////////////////////////////////////////////
// FOAM STRUCTURE. Formed by metal foams. Dense and opaque, but easy to break
/obj/structure/foamedmetal
	icon = 'icons/effects/effects.dmi'
	icon_state = "metalfoam"
	density = 1
	opacity = 1 	// changed in New()
	anchored = 1
	unacidable = 1
	name = "foamed metal"
	desc = "A lightweight foamed metal wall."
	gender = PLURAL
	var/metal = 1		// 1=aluminium, 2=iron

/obj/structure/foamedmetal/New()
	..()
	air_update_turf(1)


/obj/structure/foamedmetal/Destroy()
	density = 0
	air_update_turf(1)
	..()


/obj/structure/foamedmetal/Move()
	var/turf/T = loc
	..()
	move_update_air(T)


/obj/structure/foamedmetal/proc/updateicon()
	if(metal == 1)
		icon_state = "metalfoam"
	else
		icon_state = "ironfoam"


/obj/structure/foamedmetal/ex_act(severity, target)
	qdel(src)


/obj/structure/foamedmetal/blob_act()
	qdel(src)


/obj/structure/foamedmetal/bullet_act()
	..()
	if(metal==1 || prob(50))
		qdel(src)


/obj/structure/foamedmetal/attack_paw(var/mob/user)
	attack_hand(user)
	return


/obj/structure/foamedmetal/attack_animal(var/mob/living/simple_animal/M)
	if(M.environment_smash >= 1)
		M.do_attack_animation(src)
		M << "<span class='notice'>You smash apart the foam wall.</span>"
		qdel(src)
		return


/obj/structure/foamedmetal/attack_hulk(mob/living/carbon/human/user)
	..(user, 1)
	if(prob(75 - metal*25))
		user.visible_message("<span class='danger'>[user] smashes through the foamed metal.</span>", \
						"<span class='danger'>You smash through the metal foam wall.</span>")
		qdel(src)
	return 1


/obj/structure/foamedmetal/attack_hand(var/mob/user)
	user << "<span class='notice'>You hit the metal foam but bounce off it.</span>"


/obj/structure/foamedmetal/attackby(var/obj/item/I, var/mob/user, params)
	if (istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		G.affecting.loc = src.loc
		visible_message("<span class='danger'>[G.assailant] smashes [G.affecting] through the foamed metal wall.</span>")
		qdel(I)
		qdel(src)
		return

	if(prob(I.force*20 - metal*25))
		user.visible_message("<span class='danger'>[user] smashes through the foamed metal.</span>", \
						"<span class='danger'>You smash through the foamed metal with \the [I].</span>")
		qdel(src)
	else
		user << "<span class='notice'>You hit the metal foam to no effect.</span>"


/obj/structure/foamedmetal/CanPass(atom/movable/mover, turf/target, height=1.5)
	return !density


/obj/structure/foamedmetal/CanAtmosPass()
	return !density