extends Area2DComponent
class_name DamageSource

export var damage = 1
export var damage_type = 'blunt'
export var enabled = true setget set_enabled, get_enabled
var enabled_time = null

export var disable_on_damage = false
export var disable_when_timeout = false

signal damage_given
signal enable
signal disable

func get_enabled():
	return enabled

func set_enabled(val):
	if val:
		emit_signal("enable")
	else:
		emit_signal("disable")
	enabled = val

func _ready():
	._ready()
	if base_node.has_signal("is_dead"):
		var _a = get_parent().connect("is_dead", self, "end")
	
func end():
	self.enabled = false

func _physics_process(delta):
	if disable_when_timeout:
		if enabled_time != null:
			enabled_time -= delta
			if enabled_time <= 0:
				self.enabled = false

func _damage_given():
	if disable_on_damage:
		self.enabled = false
	emit_signal("damage_given", self)
