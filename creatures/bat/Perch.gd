extends Area2D

var bat

func _ready():
	bat = get_parent()
	
func _physics_process(delta):
	check_for_rafters(delta)

func check_for_rafters(delta):
	if not bat.near_rafter:
		bat.rafter_gravity = 0
		bat.next_rafter_heal = bat.rafter_heal_rate
	bat.near_rafter = null
	if bat.charge_state() or not bat.alive:
		return
	for node in get_overlapping_bodies():
		if node.is_in_group("rafter"):
			bat.near_rafter = node
	DebugLogger.log_variable("rafter_gravity", bat.rafter_gravity)
	if bat.near_rafter:
		if bat.rafter_gravity < 1:
			bat.rafter_gravity += delta
			if bat.rafter_gravity >= 1:
				ManageGame.save_state()
		var diff = (bat.near_rafter.global_position - bat.global_position) * 20
		diff.y = -abs(diff.y)
		bat.move += Vector2(0, -abs(diff.y) * max(bat.rafter_gravity, 0))
		bat.move.x = bat.move.x * 0.8
		if bat.rafter_gravity >= 1:
			heal_from_rafters(delta)
	elif bat.rafter_gravity > 1:
		bat.rafter_gravity -= delta

func heal_from_rafters(delta):
	bat.next_rafter_heal -= delta
	if bat.next_rafter_heal <= 0:
		bat.next_rafter_heal = bat.rafter_heal_rate
		bat.get_node("HealthBar").heal(1)
