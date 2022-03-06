extends Area2D
class_name DamageSource

var damage = 1
var enabled = false
var enabled_time = null

export var disable_on_damage = true
export var disable_when_timeout = true

signal damage_given

func _physics_process(delta):
	if disable_when_timeout:
		if enabled_time != null:
			enabled_time -= delta
			if enabled_time <= 0:
				enabled = false

func _damage_given():
	if disable_on_damage:
		enabled = false
	emit_signal("damage_given", self)
