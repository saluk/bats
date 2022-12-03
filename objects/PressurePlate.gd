extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var max_pressure = 20
export var door_group = ""
export var door_move_scale = 1.0
export var down_speed = 2
export var up_speed = 0.1

func _ready():
	pass

func _physics_process(delta):
	var weight = 0
	for body in $PhysicalPart/Area2D.get_overlapping_bodies():
		weight += 1
	var target_y = weight*2
	var k = $PhysicalPart
	var move = Vector2()
	var dir = k.position.y - target_y
	var dist = abs(dir)
	if dist > 0.02:
		if k.position.y < target_y:
			move.y = down_speed
		if k.position.y > target_y:
			move.y = -up_speed
		if k.position.y > target_y and dir < 0 or k.position.y < target_y and dir > 0:
			move.y = 0
			k.position.y = target_y
	k.position.y += move.y * delta
	if door_group:
		for door in get_tree().get_nodes_in_group(door_group):
			door.percent_open = k.position.y * door_move_scale
