extends SMState
class_name STChase

var spot_distance = 500

func make_active():
	machine.state_time = 2
func can_switch():
	machine.target = machine.get_target()
	if not machine.target or not machine.target.alive:
		return false
	if machine.target.position.distance_to(machine.creature.position) > spot_distance:
		print("too far away")
		return false
	return true
func process(_delta):
	var d = machine.creature.global_position.direction_to(machine.target.global_position) * 50
	if d.x<0:
		machine.creature.walk_left()
	elif d.x>0:
		machine.creature.walk_right()
	machine.creature.move = machine.creature.move.move_toward(
		Vector2(d.x, 0), machine.delta*150)
	machine.switch_to_state_if_possible(machine.get_state_by_name('STFire'))
