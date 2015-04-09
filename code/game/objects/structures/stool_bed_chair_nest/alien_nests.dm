//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.

/obj/structure/stool/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/mob/alien.dmi'
	icon_state = "nest"
	var/health = 100

/obj/structure/stool/bed/nest/user_unbuckle_mob(mob/user as mob)
	if(buckled_mob && buckled_mob.buckled == src)
		var/mob/living/M = buckled_mob
		if(M != user)
			M.visible_message(\
				"<span class='notice'>[user.name] pulls [M.name] free from the sticky nest!</span>",\
				"<span class='notice'>[user.name] pulls you free from the gelatinous resin.</span>",\
				"You hear squelching...")
		else
			M.visible_message(\
				"<span class='warning'>[M.name] struggles to break free from the gelatinous resin!</span>",\
				"<span class='warning'>You struggle to break free from the gelatinous resin. (Stay still for two minutes.)</span>",\
				"You hear squelching...")
			if(!do_after(M, 1200))
				if(M && M.buckled)
					M << "<span class='warning'>You fail to unbuckle yourself!</span>"
				return
			if(!M.buckled)
				return
			M.visible_message(\
				"<span class='warning'>[M.name] breaks free from the gelatinous resin!</span>",\
				"<span class='warning'>You break free from the gelatinous resin!</span>",\
				"You hear squelching...")

		unbuckle_mob()
		add_fingerprint(user)

/obj/structure/stool/bed/nest/user_buckle_mob(mob/M as mob, mob/user as mob)
	if ( !ismob(M) || (get_dist(src, user) > 1) || (M.loc != src.loc) || user.restrained() || user.stat || M.buckled || istype(user, /mob/living/silicon/pai) )
		return

	if(istype(M,/mob/living/carbon/alien))
		return
	if(!istype(user,/mob/living/carbon/alien/humanoid))
		return

	unbuckle_mob()

	if(buckle_mob(M))
		M.visible_message(\
			"<span class='notice'>[user.name] secretes a thick vile goo, securing [M.name] into [src]!</span>",\
			"<span class='warning'>[user.name] drenches you in a foul-smelling resin, trapping you in [src]!</span>",\
			"<span class='notice'>You hear squelching...</span>")

/obj/structure/stool/bed/nest/post_buckle_mob(mob/living/M)
	if(M == buckled_mob)
		M.pixel_y = 0
		M.pixel_x = initial(M.pixel_x) + 2
		overlays += image('icons/mob/alien.dmi', "nestoverlay", layer=6)
	else
		M.pixel_x = initial(M.pixel_x)
		M.pixel_y = initial(M.pixel_y)
		if(M.lying)
			M.pixel_y = M.lying_pixel_offset
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
