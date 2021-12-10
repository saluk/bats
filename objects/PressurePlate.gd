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
	var dist = abs(k.position.y - target_y)
	if dist > 0.5:
		if k.position.y < target_y:
			move.y = down_speed
		if k.position.y > target_y:
			move.y = -up_speed
	$Label.text = "w:" + str(weight) + " ty:" + str(target_y) + " ry:" + str(k.position.y) + " mv:" + str(move.y)
	k.position.y += move.y * delta
	if door_group:
		for door in get_tree().get_nodes_in_group(door_group):
			var d = door.get_node("KinematicBody2D")
			d.position.y = -(k.position.y * door_move_scale)
