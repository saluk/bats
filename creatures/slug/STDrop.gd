extends SMState
class_name STDrop

func can_switch():
	if machine.attach_direction.length() == 0:
		return true
	machine.target = machine.get_target()
	if machine.target:
		return abs(machine.target.global_position.x-base_node.global_position.x) < 10 and machine.target.global_position.y > base_node.global_position.y
	return false
func process(_delta):
	machine.attach_direction = Vector2.ZERO
	base_node.move.x = 0
	
	base_node.animation.animatedSprite.rotation_degrees = 0
	base_node.get_node("Attack").rotation_degrees = 0
func make_active():
	machine.state_time = 1.0
	base_node.move.y = 100
