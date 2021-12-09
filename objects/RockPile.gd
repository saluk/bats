extends Area2D

export var pickup_object_scene:PackedScene = null
export var pickup_object_name:String = ""


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func put_object_in_stack(object):
	object.get_parent().remove_child(object)


func _on_RockPile_body_entered(body:KinematicBody2D):
	if body and "match_name" in body and body.match_name == pickup_object_name:
		body.stack = self
		body.stack_time = 0.2

func pickup_object():
	return pickup_object_scene.instance()
