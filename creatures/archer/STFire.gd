extends SMState
class_name STFire

var fire_time = 0
export var arrow_path = "res://objects/projectiles/Arrow.tscn"

func make_active():
	machine.state_time = 2
func can_switch():
	if not machine.target or not machine.target.alive:
		return false
	if machine.target.global_position.y - 15 > machine.creature.global_position.y:
		return false
	if fire_time > 0:
		return false
	return true
func process(_delta):
	var d = machine.creature.global_position.direction_to(machine.target.global_position)
	if fire_time <= 0:
		machine.creature.get_node("AnimatedSprite").play("shoot_med")
	if machine.creature.get_node("AnimatedSprite").frame >= 4 and fire_time <= 0:
		var arrow = Spawner.spawn(arrow_path, {"position": machine.creature.position})
		arrow.mover_node.direction = d
		arrow.mover_node.rotate_sprite = true
		machine.state_time = 0
		fire_time = rand_range(1, 2)

func _physics_process(delta):
	fire_time -= delta
