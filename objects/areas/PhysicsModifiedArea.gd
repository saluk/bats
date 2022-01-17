extends Sprite
class_name PhysicsModifiedArea

export var alter_move_scale = 0.5
export var alter_move_direction = Vector2(0,0)

var area:Area2D

func _ready():
	area = find_node("Area2D")
	material = material.duplicate()
	material.set_shader_param(
		"ratio",
		scale
	)
	material.set_shader_param(
		"scroll_direction", 
		alter_move_direction * 0.005
	)
	
func _process(_delta):
	for body in area.get_overlapping_bodies():
		# TODO Affect physics and health
		if "move" in body:
			body.move = body.move * alter_move_scale
			body.move = body.move + alter_move_direction
