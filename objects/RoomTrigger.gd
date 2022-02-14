extends Node2D

export var enemy_group = ""
export var door_group = ""
export var door_move_amount = 100

var triggered = false
var door_move = 0

func _process(delta):
	if not enemy_group or not door_group:
		return
	if door_move>0:
		for door in get_tree().get_nodes_in_group(door_group):
			door.position.y -= 10*delta
			door_move -= 10*delta
	if triggered:
		return
	var enemies = get_tree().get_nodes_in_group(enemy_group)
	var alive_enemies = 0
	for e in enemies:
		if e.alive:
			alive_enemies += 1
	if alive_enemies == 0:
		triggered = 1
		door_move = door_move_amount
