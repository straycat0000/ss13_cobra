/mob/living/silicon/robot/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if(ending == "?")
		return "queries, \"<span class = 'robot'>[text]</span>\"";
	else if(copytext(text, length(text) - 1) == "!!")
		return "alarms, \"<span class = 'robot'><span class = 'yell'>[text]</span></span>\"";
	else if(ending == "!")
		return "declares, \"<span class = 'robot'>[text]</span>\"";

	return "states, \"<span class = 'robot'>[text]</span>\"";

/mob/living/silicon/robot/IsVocal()
	return !config.silent_borg
