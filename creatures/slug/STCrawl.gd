extends SMState
class_name STCrawl

func make_active():
	machine.state_time = 0.25
func can_switch():
	return true
func process(_delta):
	if not enabled:
		return
	machine.attached = true
	machine.creature.move += machine.attach_move_direction() * 25
	if machine.hit_wall:
		machine.attach_direction = -machine.attach_move_direction()
		machine.direction = -machine.direction
	elif machine.hit_gap:
		# TODO we are bad at gaps
		machine.creature.position += machine.attach_move_direction() * 4
		machine.attach_direction = machine.attach_move_direction()
		machine.direction = -machine.direction
		machine.creature.position += machine.attach_move_direction() * 4
