# A component that forces its parent to be unparented from the scene tree
# if you want to change the position of the parent, 
# change the position on this node instead

extends Node
class_name Unparented

onready var parent:Node2D = get_parent()
var position
export var active = true

func _ready():
	position = parent.global_position
	
func _process(_delta):
	if active:
		parent.global_position = position
	else:
		position = parent.global_position
