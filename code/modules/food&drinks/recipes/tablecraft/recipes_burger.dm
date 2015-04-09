
// see code/module/crafting/table.dm

////////////////////////////////////////////////BURGERS////////////////////////////////////////////////


/datum/table_recipe/humanburger
	name = "Human burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak/plain/human = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/human

/datum/table_recipe/burger
	name = "Burger"
	reqs = list(
			/obj/item/weapon/reagent_containers/food/snacks/meatsteak/plain = 1,
			/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)

	result = /obj/item/weapon/reagent_containers/food/snacks/burger/plain

/datum/table_recipe/appendixburger
	name = "Appendix burger"
	reqs = list(
		/obj/item/organ/appendix = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/appendix

/datum/table_recipe/brainburger
	name = "Brain burger"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/brain

/datum/table_recipe/xenoburger
	name = "Xeno burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak/xeno = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/xeno

datum/table_recipe/bearger
	name = "Bearger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak/bear = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/bearger

/datum/table_recipe/fishburger
	name = "Fish burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/fish

/datum/table_recipe/tofuburger
	name = "Tofu burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/tofu

/datum/table_recipe/ghostburger
	name = "Ghost burger"
	reqs = list(
		/obj/item/weapon/ectoplasm = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/ghost

/datum/table_recipe/clownburger
	name = "Clown burger"
	reqs = list(
		/obj/item/clothing/mask/gas/clown_hat = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/clown

/datum/table_recipe/mimeburger
	name = "Mime burger"
	reqs = list(
		/obj/item/clothing/mask/gas/mime = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/mime

/datum/table_recipe/redburger
	name = "Red burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak/plain = 1,
		/obj/item/toy/crayon/red = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/red

/datum/table_recipe/orangeburger
	name = "Orange burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak/plain = 1,
		/obj/item/toy/crayon/orange = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/orange

/datum/table_recipe/yellowburger
	name = "Yellow burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak/plain = 1,
		/obj/item/toy/crayon/yellow = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/yellow

/datum/table_recipe/greenburger
	name = "Green burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak/plain = 1,
		/obj/item/toy/crayon/green = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/green

/datum/table_recipe/blueburger
	name = "Blue burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak/plain = 1,
		/obj/item/toy/crayon/blue = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/blue

/datum/table_recipe/purpleburger
	name = "Purple burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak/plain = 1,
		/obj/item/toy/crayon/purple = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/purple

/datum/table_recipe/spellburger
	name = "Spell burger"
	reqs = list(
		/obj/item/clothing/head/wizard/fake,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/spell

/datum/table_recipe/spellburger2
	name = "Spell burger"
	reqs = list(
		/obj/item/clothing/head/wizard = 1,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/spell

/datum/table_recipe/bigbiteburger
	name = "Big bite burger"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak/plain = 3,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/bigbite

/datum/table_recipe/superbiteburger
	name = "Super bite burger"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 5,
		/datum/reagent/consumable/blackpepper = 5,
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak/plain = 5,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 4,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 3,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg = 2,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1

	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/superbite

/datum/table_recipe/slimeburger
	name = "Jelly burger"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/jelly/slime

/datum/table_recipe/jellyburger
	name = "Jelly burger"
	reqs = list(
			/datum/reagent/consumable/cherryjelly = 5,
			/obj/item/weapon/reagent_containers/food/snacks/bun = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burger/jelly/cherry