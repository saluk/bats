extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var move = Vector2()
var max_pressure = 20

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
	print(target_y)
	var k = $KinematicBody2D
	#k.position.y = target_y
	if k.position.y < target_y:
		move.y = 2
	if k.position.y > target_y:
		move.y = -2
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
