extends Node2D

export var firing_speed = 1
export var projectile:PackedScene = null


var fire_time = 0.0


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func shoot():
	var ob = projectile.instance()
	ob.position = $ShootPosition.global_position
	get_parent().add_child(ob)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if firing_speed and projectile:
		fire_time += delta
		if fire_time >= firing_speed:
			fire_time = 0
			shoot()
