extends Node2D

var radius = 20
var start_angle = 0
var angle = 0
var point_count = 10
var color = Color.rosybrown
var width = 10

onready var bat = get_parent()

func _process(delta):
	if bat.is_charging():
		if angle < 180:
			angle += delta*90
		scale.y = -bat.is_charging()
	else:
		angle = 0
	update()
	
func _draw():
	if not bat.is_charging():
		return
	draw_arc(
		position, 
		radius, 
		start_angle, 
		deg2rad(angle), 
		point_count, 
		color, 
		width, 
		true
	)
