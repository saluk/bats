extends Node2D

export var enemy_group = ""
export var door_group = ""
export var door_move_amount = 100

var triggered = false

func _process(_delta):
	if not enemy_group or not door_group:
		return
	if triggered:
		return
	var enemies = get_tree().get_nodes_in_group(enemy_group)
	var alive_enemies = 0
	for e in enemies:
		if e.alive:
			alive_enemies += 1
	if alive_enemies == 0:
		triggered = 1
		for door in get_tree().get_nodes_in_group(door_group):
			door.trigger_open()
