extends Area2D

export var enabled = false setget set_enabled, get_enabled
func set_enabled(val):
	enabled = val
	$Graphics.visible = val
func get_enabled():
	return enabled


func _ready():
	set_enabled(enabled)
	var _a = connect("body_entered", self, "pickup")


func do_reveal():
	set_enabled(true)

func pickup(body):
	if body in get_tree().get_nodes_in_group("player"):
		print("pickup the pickup")
		queue_free()
