extends Area2DComponent
class_name DamageSource

export var damage = 1
export var damage_type = 'blunt'
export var enabled = true
var enabled_time = null

export var disable_on_damage = false
export var disable_when_timeout = false

signal damage_given

func _ready():
	._ready()
	if base_node.has_signal("is_dead"):
		var _a = get_parent().connect("is_dead", self, "end")
	
func end():
	enabled = false
	DebugLogger.log_increment("attack ended")

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
