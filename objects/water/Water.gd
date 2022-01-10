extends Node2D
class_name Water

var area:Area2D

func _ready():
	area = find_node("Area2D")
	
func _process(delta):
	for body in area.get_overlapping_bodies():
		# TODO Affect physics and health
		if "move" in body:
			body.move = body.move/2
