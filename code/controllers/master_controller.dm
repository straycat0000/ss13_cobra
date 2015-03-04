//simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
//It ensures master_controller.process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)

//Update: all core-systems are now placed inside subsystem datums. This makes them highly configurable and easy to work with.

var/global/datum/controller/game_controller/master_controller = new()

/datum/controller/game_controller
	var/processing_interval = 1	//The minimum length of time between MC ticks (in deciseconds). The highest this can be without affecting schedules, is the GCD of all subsystem var/wait. Set to 0 to disable all processing.
	var/iteration = 0
	var/cost = 0
	var/last_thing_processed

	var/list/subsystems = list()

/datum/controller/game_controller/New()
	//There can be only one master_controller. Out with the old and in with the new.
	if(master_controller != src)
		if(istype(master_controller))
			Recover()
			master_controller.Del()
		else
			init_subtypes(/datum/subsystem, subsystems)

		master_controller = src

/*
calculate the longest number of ticks the MC can wait between each cycle without causing subsystems to not fire on schedule
Note: you can set the datum's defined processing_interval to some integer to set an -absolute- minimum wait duration.
*/
	var/GCD
	for(var/datum/subsystem/SS in subsystems)
		if(SS.wait)
			GCD = Gcd(SS.wait, GCD)
	GCD = round(GCD)
	if(GCD > processing_interval)
		processing_interval = GCD

/datum/controller/game_controller/proc/setup()
	world << "<span class='userdanger'>Initializing Subsystems...</span>"

	//sort subsystems by priority, so they initialize in the correct order
	sortTim(subsystems, /proc/cmp_subsystem_priority)

	createRandomZlevel()	//gate system
	setup_map_transitions()
	for(var/i=0, i<max_secret_rooms, i++)
		make_mining_asteroid_secret()

	//Eventually all this other setup stuff should be contained in subsystems and done in subsystem.Initialize()
	for(var/datum/subsystem/S in subsystems)
		S.Initialize(world.timeofday)
		sleep(-1)

	world << "<span class='userdanger'>Initializations complete</span>"
	world.log << "Initializations complete"

	world.sleep_offline = 1
	world.fps = config.fps

	sleep(-1)

	process()

//used for smoothing out the cost values so they don't fluctuate wildly
#define MC_AVERAGE(average, current) (0.8*(average) + 0.2*(current))

/datum/controller/game_controller/proc/process()
	if(!Failsafe)	new /datum/controller/failsafe()
	spawn(0)
		var/timer = world.time
		for(var/datum/subsystem/SS in subsystems)
			timer += processing_interval
			SS.next_fire = timer

		var/start_time
		var/cpu

		while(1)	//far more efficient than recursively calling ourself
			if(processing_interval > 0)
				++iteration

				start_time = world.timeofday

				for(var/datum/subsystem/SS in subsystems)
					if(SS.can_fire > 0)
						if(SS.next_fire <= world.time)
							SS.next_fire += SS.wait

							timer = world.timeofday
							cpu = world.cpu
							last_thing_processed = SS.type
							SS.last_fire = world.time
							SS.fire()
							SS.cpu = MC_AVERAGE(SS.cpu, world.cpu - cpu)
							SS.cost = MC_AVERAGE(SS.cost, world.timeofday - timer)
							++SS.times_fired
							sleep(-1)

				cost = MC_AVERAGE(cost, world.timeofday - start_time)

				sleep(processing_interval)
			else
				sleep(50)

#undef MC_AVERAGE

/datum/controller/game_controller/proc/roundHasStarted()
	for(var/datum/subsystem/SS in subsystems)
		SS.can_fire = 1
		SS.next_fire = world.time

/datum/controller/game_controller/proc/Recover()
	var/msg = "## DEBUG: [time2text(world.timeofday)] MC restarted. Reports:\n"
	for(var/varname in master_controller.vars)
		switch(varname)
			if("tag","bestF","type","parent_type","vars")	continue
			else
				var/varval = master_controller.vars[varname]
				if(istype(varval,/datum))
					var/datum/D = varval
					msg += "\t [varname] = [D.type]\n"
				else
					msg += "\t [varname] = [varval]\n"
	world.log << msg

	subsystems = master_controller.subsystems