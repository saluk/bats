extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var reload_in_seconds = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func reload():
	if reload_in_seconds <= 0:
		reload_in_seconds = 2
	
func _process(delta):
	if reload_in_seconds > 0:
		reload_in_seconds -= delta
		if reload_in_seconds <= 0:
			_reload()
	
func _reload():
	var _scene = get_tree().change_scene("res://scenes/prototype.tscn")
