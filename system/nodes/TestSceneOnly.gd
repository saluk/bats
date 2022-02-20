extends Node
class_name TestSceneOnly

func _ready():
	if not ManageGame.is_prototype():
		queue_free()
