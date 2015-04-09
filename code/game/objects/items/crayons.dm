/obj/item/toy/crayon/red
	icon_state = "crayonred"
	colour = "#DA0000"
	colourName = "red"

/obj/item/toy/crayon/orange
	icon_state = "crayonorange"
	colour = "#FF9300"
	colourName = "orange"

/obj/item/toy/crayon/yellow
	icon_state = "crayonyellow"
	colour = "#FFF200"
	colourName = "yellow"

/obj/item/toy/crayon/green
	icon_state = "crayongreen"
	colour = "#A8E61D"
	colourName = "green"

/obj/item/toy/crayon/blue
	icon_state = "crayonblue"
	colour = "#00B7EF"
	colourName = "blue"

/obj/item/toy/crayon/purple
	icon_state = "crayonpurple"
	colour = "#DA00FF"
	colourName = "purple"

/obj/item/toy/crayon/white
	icon_state = "crayonwhite"
	colour = "#FFFFFF"
	colourName = "white"

/obj/item/toy/crayon/mime
	icon_state = "crayonmime"
	desc = "A very sad-looking crayon."
	colour = "#FFFFFF"
	colourName = "mime"
	uses = 0

/obj/item/toy/crayon/mime/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/mime/update_window(mob/living/user as mob)
	dat += "<center><span style='border:1px solid #161616; background-color: [colour];'>&nbsp;&nbsp;&nbsp;</span><a href='?src=\ref[src];color=1'>Change color</a></center>"
	..()

/obj/item/toy/crayon/mime/Topic(href,href_list)
	if ((usr.restrained() || usr.stat || usr.get_active_hand() != src))
		return
	if(href_list["color"])
		if(colour != "#FFFFFF")
			colour = "#FFFFFF"
		else
			colour = "#000000"
		update_window(usr)
	else
		..()

/obj/item/toy/crayon/rainbow
	icon_state = "crayonrainbow"
	colour = "#FFF000"
	colourName = "rainbow"
	uses = 0

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/rainbow/update_window(mob/living/user as mob)
	dat += "<center><span style='border:1px solid #161616; background-color: [colour];'>&nbsp;&nbsp;&nbsp;</span><a href='?src=\ref[src];color=1'>Change color</a></center>"
	..()

/obj/item/toy/crayon/rainbow/Topic(href,href_list[])

	if(href_list["color"])
		var/temp = input(usr, "Please select colour.", "Crayon colour") as color
		if ((usr.restrained() || usr.stat || usr.get_active_hand() != src))
			return
		colour = temp
		update_window(usr)
	else
		..()


//Spraycan stuff

/obj/item/toy/crayon/spraycan
	icon_state = "spraycan_cap"
	desc = "A metallic container containing tasty paint."
	var/capped = 1
	instant = 1
	validSurfaces = list(/turf/simulated/floor,/turf/simulated/wall)

/obj/item/toy/crayon/spraycan/New()
	..()
	name = "NanoTrasen-brand Rapid Paint Applicator"
	update_icon()

/obj/item/toy/crayon/spraycan/attack_self(mob/living/user as mob)
	var/choice = input(user,"Spraycan options") in list("Toggle Cap","Change Drawing","Change Color")
	switch(choice)
		if("Toggle Cap")
			user << "<span class='notice'>You [capped ? "Remove" : "Replace"] the cap of the [src]</span>"
			capped = capped ? 0 : 1
			icon_state = "spraycan[capped ? "_cap" : ""]"
			update_icon()
		if("Change Drawing")
			..()
		if("Change Color")
			colour = input(user,"Choose Color") as color
			update_icon()

/obj/item/toy/crayon/spraycan/afterattack(atom/target, mob/user as mob, proximity)
	if(capped)
		return
	else
		if(iscarbon(target))
			var/mob/living/carbon/human/C = target
			user.visible_message("<span class='danger'> [user] sprays [src] into the face of [target]!</span>")
			if(C.client)
				C.eye_blurry = max(C.eye_blurry, 3)
				C.eye_blind = max(C.eye_blind, 1)
				C.confused = max(C.confused, 3)
				C.Weaken(3)
			C.lip_style = "spray_face"
			C.lip_color = colour
			C.update_body()
		playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)
		..()

/obj/item/toy/crayon/spraycan/update_icon()
	overlays.Cut()
	var/image/I = image('icons/obj/crayons.dmi',icon_state = "[capped ? "spraycan_cap_colors" : "spraycan_colors"]")
	I.color = colour
	overlays += I
