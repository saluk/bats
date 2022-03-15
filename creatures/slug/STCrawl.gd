extends SMState
class_name STCrawl

func make_active():
	machine.state_time = 0.25
func can_switch():
	return true
func process(delta):
	if not enabled:
		return
		
	machine.apply_attach_force(delta)
		
	base_node.move += machine.attach_move_direction() * 125 * delta
	if machine.hit_wall:
		machine.attach_direction = -machine.attach_move_direction()
		machine.direction = -machine.direction
	elif machine.hit_gap:
		# TODO we are bad at gaps
		base_node.position += machine.attach_move_direction() * 4
		machine.attach_direction = machine.attach_move_direction()
		machine.direction = -machine.direction
		base_node.position += machine.attach_move_direction() * 4

