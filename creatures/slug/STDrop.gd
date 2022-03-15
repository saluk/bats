extends SMState
class_name STDrop

func can_switch():
	machine.target = machine.get_target()
	if machine.target:
		#print("target range:", abs(machine.target.global_position.x-machine.creature.global_position.x))
		#print("target below:", machine.target.global_position.y > machine.creature.global_position.y)
		return abs(machine.target.global_position.x-machine.creature.global_position.x) < 10 and machine.target.global_position.y > machine.creature.global_position.y
	return false
func process(_delta):
	machine.attach_direction = Vector2.ZERO
	machine.creature.move.x = 0
	
	machine.creature.animation.animatedSprite.rotation_degrees = 0
	machine.creature.get_node("Attack").rotation_degrees = 0
func make_active():
	machine.state_time = 1.0
	machine.creature.move.y = 100
