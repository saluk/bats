extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var track_vector = ""
export var color:Color = Color(0)
export var width = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	var vec = get_parent().get(track_vector)
	draw_line(position, (
		position + (vec * width)
	), color)
	
func _process(delta):
	update()
