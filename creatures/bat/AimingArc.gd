extends Node2D

var radius = 20
var start_angle = 20
var angle = start_angle
var max_angle = 140
var point_count = 10
var color = Color(0.5,0.2,0.2,0.5)
var width = 10

onready var bat = get_parent()
var dir = 1

func _process(delta):
	if bat.charge.what_action() != "toss":
		visible = false
		return
	visible = true
	if bat.charge.is_active_charge():
		dir = -bat.is_charging()
		if angle < max_angle:
			angle += (delta*120)
	else:
		angle = start_angle
		visible = false
	update()
	
func get_vector():
	return Vector2(1,0).rotated(deg2rad(angle*-bat.charge.charge_direction+90))
	
func _draw():
	if not bat.is_charging():
		return
	draw_line(
		position,
		position + get_vector() * radius,
		Color.red,
		2.0,
		true
	)
	#draw_arc(
	#	position, 
	#	radius, 
	#	deg2rad(start_angle), 
	#	deg2rad(angle), 
	#	point_count, 
	#	color, 
	#	width, 
	#	true
	#)
