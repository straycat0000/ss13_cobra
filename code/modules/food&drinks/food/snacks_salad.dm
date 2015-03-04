//this category is very little but I think that it has great potential to grow
////////////////////////////////////////////SALAD////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/snacks/salad
	trash = /obj/item/weapon/reagent_containers/glass/bowl
	bitesize = 3
	w_class = 3

/obj/item/weapon/reagent_containers/food/snacks/salad/New()
	..()
	eatverb = pick("crunch","devour","nibble","gnaw","gobble","chomp")

/obj/item/weapon/reagent_containers/food/snacks/salad/aesirsalad
	name = "\improper Aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	list_reagents = list("omnizine" = 8, "vitamin" = 6)

/obj/item/weapon/reagent_containers/food/snacks/salad/herbsalad
	name = "herb salad"
	desc = "A tasty salad with apples on top."
	icon_state = "herbsalad"
	list_reagents = list("vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/salad/validsalad
	name = "valid salad"
	desc = "It's just an herb salad with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	list_reagents = list("doctorsdelight" = 5, "vitamin" = 4)
