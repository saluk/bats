extends Node2D

var radius = 20
var start_angle = 20
var angle = start_angle
var max_angle = 180-start_angle*2
var point_count = 10
var color = Color(0.5,0.2,0.2,0.5)
var width = 10

onready var bat = get_parent()

func _process(delta):
	if bat.charge.what_action() != "radar":
		visible = false
		return
	visible = true
	if bat.is_charging() and bat.charge_state():
		if angle < max_angle:
			angle += delta*90
		scale.y = -bat.is_charging()
	else:
		angle = start_angle
	update()
	
func _draw():
	if not bat.is_charging():
		return
	draw_arc(
		position, 
		radius, 
		deg2rad(start_angle), 
		deg2rad(angle), 
		point_count, 
		color, 
		width, 
		true
	)
