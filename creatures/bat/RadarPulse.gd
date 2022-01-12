extends Node2D

var effect = ["do_stun", []]

var move:Vector2

var edge_radius = 0
var offset_radius = 0
var max_edge_radius = 100
var spacing = 10
var expand_speed = 100

var buffer_radius = 20

var start_angle = 0
var angle = 90
var point_count = 10
var color = Color.aquamarine
var width = 1

onready var area:Area2D = $Area2D
onready var shape = $Area2D/CollisionShape2D
var collision_circle:CircleShape2D

func _ready():
	collision_circle = shape.shape
	var _a = area.connect("body_entered", self, "hit_body")

func _process(delta):
	if edge_radius < max_edge_radius:
		edge_radius += delta * expand_speed
	else:
		if offset_radius < max_edge_radius:
			offset_radius += delta * expand_speed
		else:
			offset_radius = 0
		if buffer_radius < max_edge_radius:
			buffer_radius += expand_speed * delta
		else:
			queue_free()
	collision_circle.radius = edge_radius
	position += move * delta
	update()
	
func _draw():
	var radius = fmod((edge_radius + offset_radius), max_edge_radius * 2)
	while radius > buffer_radius:
		if radius < max_edge_radius:
			draw_arc(
				Vector2(0,0), 
				radius, 
				deg2rad(start_angle), 
				deg2rad(angle), 
				point_count, 
				color, 
				width, 
				true
			)
		radius -= spacing
	#draw_circle(position, edge_radius, Color(0,0,1,0.1))

func hit_body(body):
	if body.is_in_group("player"):
		return
	print("radar hit ", body)
	if body.has_method(effect[0]):
		if effect[1]:
			body.call(effect[0], effect[1])
		else:
			body.call(effect[0])
