extends Area2D

export var pickup_object:PackedScene = null
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
	if body and body.has_method("pickup_object_from_pile"):
		body.pickup_object_from_pile(self.pickup_object)
	elif body and body.match_name == pickup_object_name:
		body.stack = self
		body.stack_time = 0.2
