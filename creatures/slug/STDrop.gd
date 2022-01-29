extends SMState
class_name STDrop

func can_switch():
	if not machine.attached:
		print("not attached cant drop")
		return false
	machine.target = machine.get_target()
	if machine.target:
		#print("target range:", abs(machine.target.global_position.x-machine.creature.global_position.x))
		#print("target below:", machine.target.global_position.y > machine.creature.global_position.y)
		return abs(machine.target.global_position.x-machine.creature.global_position.x) < 10 and machine.target.global_position.y > machine.creature.global_position.y
func process(_delta):
	machine.attached = false
	machine.attach_direction = Vector2.ZERO
	machine.creature.move.x = 0
func make_active():
	machine.state_time = 1.0
	machine.creature.move.y = 100
