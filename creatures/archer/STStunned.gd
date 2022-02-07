extends SMState
class_name STStunned

func make_active():
	machine.state_time = 3
	machine.creature.get_node("Star").visible = true
func can_switch():
	return false
func process(_delta):
	machine.creature.get_node("AnimatedSprite").play("idle")
func exit():
	machine.creature.get_node("Star").visible = false
