extends SMState
class_name STWalk

func make_active():
	machine.state_time = 2
func can_switch():
	return true
func process(delta):
	if machine.direction < 0:
		machine.creature.walk_left()
	elif machine.direction > 0:
		machine.creature.walk_right()
	machine.creature.move = machine.creature.move.move_toward(
		Vector2(40 * machine.direction, 0), delta*150
	)
	if machine.direction < 0:
		if machine.creature.last_collision.left and machine.creature.last_collision.left.type == "terrain":
			machine.direction = -machine.direction
	if machine.direction > 0:
		if machine.creature.last_collision.right and machine.creature.last_collision.right.type == "terrain":
			machine.direction = -machine.direction
