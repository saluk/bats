extends Area2D

export var direction:Vector2 = Vector2()
export var speed = 0
export var rotate_sprite = false

signal collide_body(body)

func _physics_process(delta):
	if speed:
		position += (direction*speed*delta)
	if rotate_sprite: 
		rotation = direction.angle()


func _on_KinematicBody2D_body_entered(body):
	emit_signal("collide_body", body)
