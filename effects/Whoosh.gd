extends Node2DComponent

export var detect_motion_from:NodePath
export var detect_motion_variable:String

func enable():
	$Sprite.visible = true

func disable():
	$Sprite.visible = false

func set_facing(motion_vector:Vector2):
	rotation_degrees = rad2deg(motion_vector.angle())

func _physics_process(delta):
	set_facing(
		get_node(detect_motion_from).get(detect_motion_variable)
	)
