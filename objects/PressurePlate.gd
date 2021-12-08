extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var move = Vector2()
var max_pressure = 20
export var door_group = ""
export var door_move_scale = 1.0
export var down_speed = 2
export var up_speed = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	var weight = 0
	for body in $KinematicBody2D/Area2D.get_overlapping_bodies():
		weight += 1
	var target_y = weight*2
	var k = $KinematicBody2D
	#k.position.y = target_y
	if k.position.y < target_y:
		move.y = down_speed
	if k.position.y > target_y:
		move.y = -up_speed
	#k.position += move
	var x = k.position.x
	k.move_and_slide(move)
	k.position.x = x
	#if k.position.y > max_pressure:
	#	k.position.y = max_pressure
	#	move.y = 0
	#if k.position.y < 0:
	#	k.position.y = 0
	#	move.y = 0
	if door_group:
		for door in get_tree().get_nodes_in_group(door_group):
			var d = door.get_node("KinematicBody2D")
			d.position.y = -(k.position.y * door_move_scale)
