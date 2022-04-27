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
		
	#base_node.move += machine.attach_move_direction() * 125 * delta


