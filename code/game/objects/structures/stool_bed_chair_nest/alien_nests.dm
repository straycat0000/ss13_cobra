//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.

/obj/structure/stool/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/mob/alien.dmi'
	icon_state = "nest"
	var/health = 100

/*
/obj/structure/stool/bed/nest/unbuckle_other(mob/user as mob)
	buckled_mob.visible_message(\
		"<span class='notice'>[user.name] pulls [buckled_mob.name] free from the sticky nest!</span>",\
		"[user.name] pulls you free from the gelatinous resin.",\
		"You hear squelching...")
	unbuckle()

/obj/structure/stool/bed/nest/unbuckle_myself(mob/user as mob)
	buckled_mob.visible_message(\
		"<span class='warning'>[buckled_mob.name] struggles to break free of the gelatinous resin...</span>",\
		"<span class='warning'>You struggle to break free from the gelatinous resin...</span>",\
		"You hear squelching...")
	spawn(600)
		if(user && buckled_mob && user.buckled == src)
			unbuckle()
*/

/obj/structure/stool/bed/nest/user_buckle_mob(mob/M as mob, mob/user as mob)
	if ( !ismob(M) || (get_dist(src, user) > 1) || (M.loc != src.loc) || user.restrained() || usr.stat || M.buckled || istype(user, /mob/living/silicon/pai) )
		return

	if(istype(M,/mob/living/carbon/alien))
		return
	if(!istype(user,/mob/living/carbon/alien/humanoid))
		return

	unbuckle_mob()

	if(M == usr)
		return
	else
		M.visible_message(\
			"<span class='notice'>[user.name] secretes a thick vile goo, securing [M.name] into [src]!</span>",\
			"<span class='warning'>[user.name] drenches you in a foul-smelling resin, trapping you in [src]!</span>",\
			"<span class='notice'>You hear squelching...</span>")
	return

/obj/structure/stool/bed/nest/post_buckle_mob(mob/living/M)
	if(M == buckled_mob)
		M.pixel_y += 1
		M.pixel_x += 2
		overlays += image('icons/mob/alien.dmi', "nestoverlay", layer=6)
	else
		buckled_mob.pixel_y -= 1
		buckled_mob.pixel_x -= 2
		overlays.Cut()



/obj/structure/stool/bed/nest/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	var/aforce = W.force
	health = max(0, health - aforce)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	visible_message("<span class='danger'>[user] hits [src] with [W]!</span>")
	healthcheck()

/obj/structure/stool/bed/nest/proc/healthcheck()
	if(health <=0)
		density = 0
		qdel(src)
	return
