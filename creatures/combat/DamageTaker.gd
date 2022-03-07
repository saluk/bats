### This object can take damage
# Customize which areas or signals can cause this to take damage
# Customize what object actually handles damage being dealt
# Customize how many seconds of invincible time

extends Node2D
class_name DamageTaker

var enabled = true

onready var base = get_parent()
export var iseconds:float = 0.5
export var invincible = false
export var apply_damage_node_path:NodePath

signal applied_damage(source)

class DamageSourceRecord extends Reference:
	var collider
	var type
	var amount
	var direction
	func enabled():
		if "enabled" in collider:
			return collider.enabled
		return true
	func apply():
		if collider.has_method("_damage_given"):
			collider._damage_given()

var damage_sources = {}
var last_hurt = 0.0

func _ready():
	var apply_damage_node = get_node(apply_damage_node_path)
	var _a = connect("applied_damage", apply_damage_node, "do_damage")
	for area in get_children():
		var area2d = area as Area2D
		if area2d:
			area2d.connect("area_entered", self, "_area_or_body_entered")
			area2d.connect("body_entered", self, "_area_or_body_entered")
			area2d.connect("area_exited", self, "_area_or_body_exited")
			area2d.connect("body_exited", self, "_area_or_body_exited")
	get_parent().connect("is_dead", self, "end")
	
func end():
	enabled = false
			
func _area_or_body_entered(area_or_body):
	print("thing entered ", area_or_body.name)
	if "damage" in area_or_body:
		print("damage in thing")
		add_source(area_or_body)
	elif "damage" in area_or_body.get_parent():
		print("damage in parent")
		add_source(area_or_body.get_parent())
	else:
		print("no damage")
	_physics_process(0)
		
func _area_or_body_exited(area_or_body):
	if "damage" in area_or_body:
		remove_source(area_or_body)
	elif "damage" in area_or_body.get_parent():
		remove_source(area_or_body.get_parent())
	_physics_process(0)
		
func add_source(object):
	if not object in damage_sources.keys():
		damage_sources[object] = DamageSourceRecord.new()
		damage_sources[object].collider = object
		damage_sources[object].type = "normal"
		damage_sources[object].amount = object.damage
		damage_sources[object].direction = (object.global_position - base.global_position).normalized()
		print("added damage source")
		
func remove_source(object):
	if object in damage_sources:
		damage_sources.erase(object)
		print("removed damage source")

func _physics_process(delta):
	if not enabled:
		return
	DebugLogger.log_increment("damage taker physics")
	DebugLogger.log_variable("num_overlapping_damage", damage_sources.keys().size())
	if last_hurt < iseconds:
		last_hurt += delta
		return
	hurt()
	
func hurt():
	for source_object in damage_sources.keys():
		var source = damage_sources[source_object]
		if Util.valid_object(source):
			if source.enabled():
				DebugLogger.log_increment("damage_taken "+base.name)
				print("take damage "+base.name)
				if not invincible:
					emit_signal("applied_damage", source)
					source.apply()
				last_hurt = 0.0
				return
			else:
				print("source not enabled")
		else:
			print("source not valid")
		print("erasing damage source", source_object.name)
		damage_sources.erase(source_object)
