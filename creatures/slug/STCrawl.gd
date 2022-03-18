extends SMState
class_name STCrawl

# TODO this is probably wrong
var turn = false

func make_active():
	machine.state_time = 0.25
func can_switch():
	return true
func process(delta):
	if not enabled:
		return

	machine.apply_attach_force(delta)
		
	base_node.move += machine.attach_move_direction() * 125 * delta
	if machine.check_hit_wall():
		if not turn:
			machine.attach_direction = -machine.attach_move_direction()
			machine.direction = -machine.direction
			turn = true
	elif machine.check_hit_gap():
		# TODO we are bad at gaps
		if not turn:
			base_node.position += machine.attach_move_direction() * 4
			machine.attach_direction = machine.attach_move_direction()
			machine.direction = -machine.direction
			base_node.position += machine.attach_move_direction() * 4
			turn = true
	else:
		turn = false

