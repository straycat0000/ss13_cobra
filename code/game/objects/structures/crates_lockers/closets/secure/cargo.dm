/obj/structure/closet/secure_closet/cargotech
	name = "cargo technician's locker"
	req_access = list(access_cargo)
	icon_state = "cargo"

/obj/structure/closet/secure_closet/cargotech/New()
	..()
	new /obj/item/clothing/under/rank/cargotech(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/device/radio/headset/headset_cargo(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/head/soft(src)

/obj/structure/closet/secure_closet/quartermaster
	name = "\proper quartermaster's locker"
	req_access = list(access_qm)
	icon_state = "qm"

/obj/structure/closet/secure_closet/quartermaster/New()
	..()
	new /obj/item/clothing/suit/hooded/wintercoat/cargo(src)
	new /obj/item/clothing/under/rank/cargo(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/device/radio/headset/headset_cargo(src)
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/device/megaphone/cargo(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/clothing/head/soft(src)
