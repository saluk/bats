extends Node2D

export var damage = 1

var enabled = true

func _on_Area2D_body_entered(body):
	if body.has_method("do_damage"):
		body.do_damage(self.damage)
