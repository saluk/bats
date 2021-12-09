extends Area2D

export var direction:Vector2 = Vector2()
export var speed = 0

signal collide_body(body)

func _process(delta):
	if speed:
		position += (direction*speed*delta)


func _on_KinematicBody2D_body_entered(body):
	emit_signal("collide_body", body)
