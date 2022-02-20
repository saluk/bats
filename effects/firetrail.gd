extends Node2D

onready var particles:Particles2D = get_node("Particles2D")
var collision_template:Area2D
var cycle = 0.0
var next_col = 0

var shapes = []

export var max_shapes = 8
export var move = Vector2(0,0)

func _ready():
	cycle = particles.lifetime/max_shapes
	collision_template = get_node("CollisionTemplate").duplicate()
	remove_child(get_node("CollisionTemplate"))

func _physics_process(delta):
	position += move*delta
	if particles.emitting:
		create_collision_shapes(delta)
	process_collision_shapes(delta)

func create_collision_shapes(delta):
	next_col += delta
	if next_col > cycle:
		next_col -= cycle
		make_shape()
		
func process_collision_shapes(delta):
	var new_shapes = []
	for shape in shapes:
		shape.life += delta
		shape.move += particles.process_material.get("gravity").y*delta
		if shape.life < shape.ttl and new_shapes.size() < max_shapes:
			new_shapes.append(shape)
		else:
			shape.queue_free()
		shape.position.y += shape.move*delta
		shape.moved += shape.move*delta
		shape.scale.x = lerp(shape.start_scale, shape.end_scale, shape.moved/particles.visibility_rect.size.y)
		shape.scale.y = lerp(shape.start_scale, shape.end_scale, shape.moved/particles.visibility_rect.size.y)
	shapes = new_shapes

func make_shape():
	var shape = collision_template.duplicate()
	shape.global_position = global_position
	# TODO we are assuming our parent is a Mob and we want to add the collision to the world level above the mob
	if get_parent().get_parent():
		get_parent().get_parent().add_child(shape)
	else:
		get_parent().add_child(shape)
	shapes.append(shape)
	shape.ttl = particles.lifetime/2
