# TODO - Deprecated, currently the firetrail generates damageareas, but they
# should really be damage sources

# A damage area can initialized from an Area2D or a KinematicBody2D
# A damage area registers a callback to be emitted periodically on
# all overlappying areas or bodies

# TODO good candidate for component system

extends Node
class_name DamageArea

export var callback_name_from_parent = "do_damage"
export var call_frequency = 0.5
export var call_on_enter = true
var next_call = 0

onready var area:Area2D = get_parent()

var colliding = []

func _ready():
	assert(area.has_method(callback_name_from_parent), "DamageArea parent must implement "+callback_name_from_parent)
	if get_parent() is Area2D:
		_ready_area2D()
	elif get_parent() is KinematicBody2D:
		_ready_kinematicBody2D()
		
func _ready_area2D():
	var _a = area.connect("area_entered", self, "_thing_entered")
	_a = area.connect("area_exited", self, "_thing_exited")
	_a = area.connect("body_entered", self, "_thing_entered")
	_a = area.connect("body_exited", self, "_thing_exited")
	
# TODO implement
func _ready_kinematicBody2D():
	pass
	
func _thing_entered(thing):
	if not thing in colliding:
		colliding.append(thing)
		if call_on_enter:
			area.call(callback_name_from_parent, thing)
	
func _thing_exited(thing):
	if thing in colliding:
		colliding.erase(thing)

func _physics_process(delta):
	next_call += delta
	if next_call > call_frequency:
		call_next()
		next_call -= call_frequency
		
func call_next():
	Nodes.clean_node_array(colliding)
	for node in colliding:
		area.call(callback_name_from_parent, node)
