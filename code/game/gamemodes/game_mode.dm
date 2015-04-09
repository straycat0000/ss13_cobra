//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/*
 * GAMEMODES (by Rastaf0)
 *
 * In the new mode system all special roles are fully supported.
 * You can have proper wizards/traitors/changelings/cultists during any mode.
 * Only two things really depends on gamemode:
 * 1. Starting roles, equipment and preparations
 * 2. Conditions of finishing the round.
 *
 */


/datum/game_mode
	var/name = "invalid"
	var/config_tag = null
	var/votable = 1
	var/probability = 1
	var/station_was_nuked = 0 //see nuclearbomb.dm and malfunction.dm
	var/explosion_in_progress = 0 //sit back and relax
	var/list/datum/mind/modePlayer = new
	var/list/datum/mind/antag_candidates = list()	// List of possible starting antags goes here
	var/list/restricted_jobs = list()	// Jobs it doesn't make sense to be.  I.E chaplain or AI cultist
	var/list/protected_jobs = list()	// Jobs that can't be traitors because
	var/required_players = 0
	var/required_enemies = 0
	var/recommended_enemies = 0
	var/pre_setup_before_jobs = 0
	var/antag_flag = null //preferences flag such as BE_WIZARD that need to be turned on for players to be antag
	var/datum/mind/sacrifice_target = null
	var/list/datum/game_mode/replacementmode = null
	var/round_converted = 0 //0: round not converted, 1: round going to convert, 2: round converted
	var/reroll_friendly 	//During mode conversion only these are in the running
	var/enemy_minimum_age = 7 //How many days must players have been playing before they can play this antagonist

	var/const/waittime_l = 600
	var/const/waittime_h = 1800 // started at 1800


/datum/game_mode/proc/announce() //to be calles when round starts
	world << "<B>Notice</B>: [src] did not define announce()"


///can_start()
///Checks to see if the game can be setup and ran with the current number of players or whatnot.
/datum/game_mode/proc/can_start()
	var/playerC = 0
	for(var/mob/new_player/player in player_list)
		if((player.client)&&(player.ready))
			playerC++
	if(!Debug2)
		if(playerC < required_players)
			return 0
	antag_candidates = get_players_for_role(antag_flag)
	if(!Debug2)
		if(antag_candidates.len < required_enemies)
			return 0
		return 1
	else
		world << "<span class='notice'>DEBUG: GAME STARTING WITHOUT PLAYER NUMBER CHECKS, THIS WILL PROBABLY BREAK SHIT."
		return 1


///pre_setup()
///Attempts to select players for special roles the mode might have.
/datum/game_mode/proc/pre_setup()
	return 1


///post_setup()
///Everyone should now be on the station and have their normal gear.  This is the place to give the special roles extra things
/datum/game_mode/proc/post_setup(var/report=1)
	spawn (ROUNDSTART_LOGOUT_REPORT_TIME)
		display_roundstart_logout_report()

	feedback_set_details("round_start","[time2text(world.realtime)]")
	if(ticker && ticker.mode)
		feedback_set_details("game_mode","[ticker.mode]")
	if(revdata.revision)
		feedback_set_details("revision","[revdata.revision]")
	feedback_set_details("server_ip","[world.internet_address]:[world.port]")
	if(report)
		spawn (rand(waittime_l, waittime_h))
			send_intercept(0)
	start_state = new /datum/station_state()
	start_state.count()
	return 1

///make_antag_chance()
///Handles late-join antag assignments
/datum/game_mode/proc/make_antag_chance(var/mob/living/carbon/human/character)
	if(replacementmode && round_converted == 2)
		replacementmode.make_antag_chance(character)
	return

///convert_roundtype()
///Allows rounds to basically be "rerolled" should the initial premise fall through
/datum/game_mode/proc/convert_roundtype()
	var/living_crew = 0

	for(var/mob/Player in mob_list)
		if(Player.mind && Player.stat != DEAD && !isnewplayer(Player) &&!isbrain(Player))
			living_crew++
	if(living_crew / joined_player_list.len <= config.midround_antag_life_check) //If a lot of the player base died, we start fresh
		message_admins("Convert_roundtype failed due to too many dead people. Limit is [config.midround_antag_life_check * 100]% living crew")
		return null

	var/list/datum/game_mode/runnable_modes = config.get_runnable_midround_modes(living_crew)
	var/list/datum/game_mode/usable_modes = list()
	for(var/datum/game_mode/G in runnable_modes)
		if(G.reroll_friendly)
			usable_modes += G
		else
			del(G)

	SSshuttle.emergencyNoEscape = 0 //Time to get the fuck out of here

	if(!usable_modes)
		message_admins("Convert_roundtype failed due to no valid modes to convert to. Please report this error to the Coders.")
		return null

	replacementmode = pickweight(usable_modes)

	switch(SSshuttle.emergency.mode) //Rounds on the verge of ending don't get new antags, they just run out
		if(SHUTTLE_STRANDED, SHUTTLE_ESCAPE)
			return 1
		if(SHUTTLE_CALL)
			if(SSshuttle.emergency.timeLeft(1) < initial(SSshuttle.emergencyCallTime)*0.5)
				return 1

	if(world.time >= (config.midround_antag_time_check * 600))
		message_admins("Convert_roundtype failed due to round length. Limit is [config.midround_antag_time_check] minutes.")
		return null

	var/list/antag_canadates = list()

	for(var/mob/living/carbon/human/H in living_crew)
		if(H.client && H.client.prefs.allow_midround_antag)
			antag_canadates += H

	if(!antag_canadates)
		message_admins("Convert_roundtype failed due to no antag canadates.")
		return null

	antag_canadates = shuffle(antag_canadates)

	if(config.protect_roles_from_antagonist)
		replacementmode.restricted_jobs += replacementmode.protected_jobs
	if(config.protect_assistant_from_antagonist)
		replacementmode.restricted_jobs += "Assistant"

	message_admins("The roundtype will be converted. If you feel that the round should not continue, <A HREF='?_src_=holder;end_round=\ref[usr]'>end the round now</A>.")

	spawn(rand(1800,4200)) //somewhere between 3 and 7 minutes from now
		for(var/mob/living/carbon/human/H in antag_canadates)
			replacementmode.make_antag_chance(H)
		round_converted = 2
		message_admins("The roundtype has been converted, antagonists may have been created")
	return 1

///process()
///Called by the gameticker
/datum/game_mode/process()
	return 0


/datum/game_mode/proc/check_finished() //to be called by ticker
	if(SSshuttle.emergency.mode >= SHUTTLE_ENDGAME || station_was_nuked)
		return 1
	return 0


/datum/game_mode/proc/declare_completion()
	send2irc("Server", "Round just ended.")
	return 0


/datum/game_mode/proc/check_win() //universal trigger to be called at mob death, nuke explosion, etc. To be called from everywhere.
	return 0


/datum/game_mode/proc/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Centcom Update</B> Requested staus information:</FONT><HR>"
	intercepttext += "<B> Centcom has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "malf", "changeling", "cult")
	possible_modes -= "[ticker.mode]" //remove current gamemode to prevent it from being randomly deleted, it will be readded later

	var/number = pick(1, 2)
	var/i = 0
	for(i = 0, i < number, i++) //remove 1 or 2 possibles modes from the list
		possible_modes.Remove(pick(possible_modes))

	possible_modes[rand(1, possible_modes.len)] = "[ticker.mode]" //replace a random game mode with the current one

	possible_modes = shuffle(possible_modes) //shuffle the list to prevent meta

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		if(modePlayer.len == 0)
			intercepttext += i_text.build(A)
		else
			intercepttext += i_text.build(A, pick(modePlayer))

	print_command_report(intercepttext,"Centcom Status Summary")
	priority_announce("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.", 'sound/AI/intercept.ogg')
	if(security_level < SEC_LEVEL_BLUE)
		set_security_level(SEC_LEVEL_BLUE)


/datum/game_mode/proc/get_players_for_role(var/role)
	var/list/players = list()
	var/list/candidates = list()
	var/list/drafted = list()
	var/datum/mind/applicant = null

	var/roletext
	switch(role)
		if(BE_CHANGELING)	roletext="changeling"
		if(BE_TRAITOR)		roletext="traitor"
		if(BE_OPERATIVE)	roletext="operative"
		if(BE_WIZARD)		roletext="wizard"
		if(BE_REV)			roletext="revolutionary"
		if(BE_GANG)			roletext="gangster"
		if(BE_CULTIST)		roletext="cultist"
		if(BE_MONKEY)		roletext="monkey"


	// Ultimate randomizing code right here
	for(var/mob/new_player/player in player_list)
		if(player.client && player.ready)
			players += player

	// Shuffling, the players list is now ping-independent!!!
	// Goodbye antag dante
	players = shuffle(players)

	for(var/mob/new_player/player in players)
		if(player.client && player.ready)
			if(player.client.prefs.be_special & role)
				if(!jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, roletext)) //Nodrak/Carn: Antag Job-bans
					if(age_check(player.client)) //Must be older than the minimum age
						candidates += player.mind				// Get a list of all the people who want to be the antagonist for this round

	if(restricted_jobs)
		for(var/datum/mind/player in candidates)
			for(var/job in restricted_jobs)					// Remove people who want to be antagonist but have a job already that precludes it
				if(player.assigned_role == job)
					candidates -= player

	if(candidates.len < recommended_enemies)
		for(var/mob/new_player/player in players)
			if(player.client && player.ready)
				if(!(player.client.prefs.be_special & role)) // We don't have enough people who want to be antagonist, make a seperate list of people who don't want to be one
					if(!jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, roletext)) //Nodrak/Carn: Antag Job-bans
						drafted += player.mind

	if(restricted_jobs)
		for(var/datum/mind/player in drafted)				// Remove people who can't be an antagonist
			for(var/job in restricted_jobs)
				if(player.assigned_role == job)
					drafted -= player

	drafted = shuffle(drafted) // Will hopefully increase randomness, Donkie

	while(candidates.len < recommended_enemies)				// Pick randomlly just the number of people we need and add them to our list of candidates
		if(drafted.len > 0)
			applicant = pick(drafted)
			if(applicant)
				candidates += applicant
				drafted.Remove(applicant)

		else												// Not enough scrubs, ABORT ABORT ABORT
			break
/*
	if(candidates.len < recommended_enemies && override_jobbans) //If we still don't have enough people, we're going to start drafting banned people.
		for(var/mob/new_player/player in players)
			if (player.client && player.ready)
				if(jobban_isbanned(player, "Syndicate") || jobban_isbanned(player, roletext)) //Nodrak/Carn: Antag Job-bans
					drafted += player.mind
*/
	if(restricted_jobs)
		for(var/datum/mind/player in drafted)				// Remove people who can't be an antagonist
			for(var/job in restricted_jobs)
				if(player.assigned_role == job)
					drafted -= player

	drafted = shuffle(drafted) // Will hopefully increase randomness, Donkie

	while(candidates.len < recommended_enemies)				// Pick randomlly just the number of people we need and add them to our list of candidates
		if(drafted.len > 0)
			applicant = pick(drafted)
			if(applicant)
				candidates += applicant
				drafted.Remove(applicant)

		else												// Not enough scrubs, ABORT ABORT ABORT
			break

	return candidates		// Returns: The number of people who had the antagonist role set to yes, regardless of recomended_enemies, if that number is greater than recommended_enemies
							//			recommended_enemies if the number of people with that role set to yes is less than recomended_enemies,
							//			Less if there are not enough valid players in the game entirely to make recommended_enemies.

/*
/datum/game_mode/proc/check_player_role_pref(var/role, var/mob/new_player/player)
	if(player.preferences.be_special & role)
		return 1
	return 0
*/

/datum/game_mode/proc/num_players()
	. = 0
	for(var/mob/new_player/P in player_list)
		if(P.client && P.ready)
			. ++

///////////////////////////////////
//Keeps track of all living heads//
///////////////////////////////////
/datum/game_mode/proc/get_living_heads()
	var/list/heads = list()
	for(var/mob/living/carbon/human/player in mob_list)
		if(player.stat!=2 && player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads


////////////////////////////
//Keeps track of all heads//
////////////////////////////
/datum/game_mode/proc/get_all_heads()
	var/list/heads = list()
	for(var/mob/player in mob_list)
		if(player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads

//////////////////////////
//Reports player logouts//
//////////////////////////
proc/display_roundstart_logout_report()
	var/msg = "<span class='boldnotice'>Roundstart logout report\n\n</span>"
	for(var/mob/living/L in mob_list)

		if(L.ckey)
			var/found = 0
			for(var/client/C in clients)
				if(C.ckey == L.ckey)
					found = 1
					break
			if(!found)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"


		if(L.ckey && L.client)
			if(L.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2))	//Connected, but inactive (alt+tabbed or something)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				continue //AFK client
			if(L.stat)
				if(L.suiciding)	//Suicider
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<span class='boldannounce'>Suicide</span>)\n"
					continue //Disconnected client
				if(L.stat == UNCONSCIOUS)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dying)\n"
					continue //Unconscious
				if(L.stat == DEAD)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dead)\n"
					continue //Dead

			continue //Happy connected client
		for(var/mob/dead/observer/D in mob_list)
			if(D.mind && D.mind.current == L)
				if(L.stat == DEAD)
					if(L.suiciding)	//Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<span class='boldannounce'>Suicide</span>)\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<span class='boldannounce'>This shouldn't appear.</span>)\n"
						continue //Lolwhat
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<span class='boldannounce'>Ghosted</span>)\n"
						continue //Ghosted while alive



	for(var/mob/M in mob_list)
		if(M.client && M.client.holder)
			M << msg

/datum/game_mode/proc/printplayer(var/datum/mind/ply)
	var/role = "\improper[ply.assigned_role]"
	var/text = "<br><b>[ply.name]</b>(<b>[ply.key]</b>) as \a <b>[role]</b> ("
	if(ply.current)
		if(ply.current.stat == DEAD)
			text += "died"
		else
			text += "survived"
		if(ply.current.real_name != ply.name)
			text += " as <b>[ply.current.real_name]</b>"
	else
		text += "body destroyed"
	text += ")"

	return text

//If the configuration option is set to require players to be logged as old enough to play certain jobs, then this proc checks that they are, otherwise it just returns 1
/datum/game_mode/proc/age_check(client/C)
	if(get_remaining_days(C) == 0)
		return 1	//Available in 0 days = available right now = player is old enough to play.
	return 0


/datum/game_mode/proc/get_remaining_days(client/C)
	if(!C)
		return 0
	if(!config.use_age_restriction_for_jobs)
		return 0
	if(!isnum(C.player_age))
		return 0 //This is only a number if the db connection is established, otherwise it is text: "Requires database", meaning these restrictions cannot be enforced
	if(!isnum(enemy_minimum_age))
		return 0

	return max(0, enemy_minimum_age - C.player_age)
