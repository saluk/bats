extends NodeComponent
class_name Cooldown

export var cooldown_time = 1.0
var last_trigger = null

func start() -> bool:
	if not is_ready():
		return false
	last_trigger = OS.get_ticks_msec()
	return true

func is_ready() -> bool:
	if last_trigger and OS.get_ticks_msec() - last_trigger < cooldown_time*1000 :
		return false
	return true
