extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var scene = PackedScene.new()
	var slug = get_node("Slug")
	scene.pack(slug)
	for copy in range(0, 100):
		slug = scene.instance()
		add_child(slug)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
