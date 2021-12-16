extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if WorldSettings.room:
		var bounds = WorldSettings.room.get_bounds()
		#print(bounds)
		limit_left = bounds[0]
		limit_right = bounds[1]
		limit_top = bounds[2]
		limit_bottom = bounds[3]
