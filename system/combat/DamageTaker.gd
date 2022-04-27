### This object can take damage
# Customize which areas or signals can cause this to take damage
# Customize what object actually handles damage being dealt
# Customize how many seconds of invincible time

extends Node2DComponent
class_name DamageTaker

var enabled = true

export var iseconds:float = 0.5
export var invincible = false
export var apply_damage_node_path:NodePath
export var damage_knockback_force = 250

# key is just an identifier, value is an array of damage types
export var excluded_damage_type_masks:Dictionary

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
	._ready()
	var apply_damage_node = get_node(apply_damage_node_path)
	var _a = connect("applied_damage", apply_damage_node, "do_damage")
	for area in get_children():
		var area2d = area as Area2D
		if area2d:
			area2d.connect("area_entered", self, "_area_or_body_entered")
			area2d.connect("body_entered", self, "_area_or_body_entered")
			area2d.connect("area_exited", self, "_area_or_body_exited")
			area2d.connect("body_exited", self, "_area_or_body_exited")
	var _b = get_parent().connect("is_dead", self, "end")
	
func end():
	enabled = false
			
func _area_or_body_entered(area_or_body):
	if "damage" in area_or_body:
		add_source(area_or_body)
	elif "damage" in area_or_body.get_parent():
		add_source(area_or_body.get_parent())
		
func _area_or_body_exited(area_or_body):
	if "damage" in area_or_body:
		remove_source(area_or_body)
	elif "damage" in area_or_body.get_parent():
		remove_source(area_or_body.get_parent())
		
func add_source(object):
	if not object in damage_sources.keys():
		damage_sources[object] = DamageSourceRecord.new()
		damage_sources[object].collider = object
		damage_sources[object].type = object.damage_type
		damage_sources[object].amount = object.damage
		damage_sources[object].direction = (object.global_position - base_node.global_position).normalized()
		print("added damage source")
		_physics_process(0)
		
func remove_source(object):
	if object in damage_sources:
		damage_sources.erase(object)
		print("removed damage source")
		_physics_process(0)

func _physics_process(delta):
	if not enabled:
		return
	DebugLogger.log_variable("num_overlapping_damage "+get_parent().name, damage_sources.keys().size())
	if last_hurt < iseconds:
		last_hurt += delta
		return
	#DebugLogger.show_at("masks", excluded_damage_type_masks.keys().size(), base_node.global_position)
	hurt()
	
func apply_knockback(source):
	base_node.move += -source.direction * damage_knockback_force
	
func set_type_mask(key, types):
	excluded_damage_type_masks[key] = types

func clear_type_mask(key):
	if key in excluded_damage_type_masks:
		excluded_damage_type_masks.erase(key)
	
func damage_allowed(source):
	if invincible:
		return false
	for types in excluded_damage_type_masks.values():
		if source.type in types:
			return false
	return true
	
func hurt():
	for source_object in damage_sources.keys():
		var source = damage_sources[source_object]
		if Util.valid_object(source):
			if source.enabled():
				DebugLogger.log_increment("damage_taken "+base_node.name)
				print("take damage "+base_node.name)
				if damage_allowed(source):
					emit_signal("applied_damage", source)
					source.apply()
					apply_knockback(source)
				last_hurt = 0.0
				return
		else:
			print("source not valid")
			print("erasing damage source", source_object.name)
			damage_sources.erase(source_object)
