extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var reload_in_seconds = 0.0
var saved_object_states = {}


func reload():
	if reload_in_seconds <= 0:
		reload_in_seconds = 2
	
func _process(delta):
	if reload_in_seconds > 0:
		reload_in_seconds -= delta
		if reload_in_seconds <= 0:
			_reload()
	
func _reload():
	saved_object_states = {}
	var _scene = get_tree().change_scene("res://scenes/prototype.tscn")

func check_deleted(node):
	if node.mob_id in saved_object_states:
		if saved_object_states[node.mob_id]['deleted'] == true:
			node.queue_free()

func set_deleted(node):
	if not node.mob_id in saved_object_states:
		saved_object_states[node.mob_id] = {}
	saved_object_states[node.mob_id]['deleted'] = true

func ensure_node(node, script_path):
	var found_script = false
	for child in node.get_children():
		if not child.get_script():
			continue
		if child.get_script().resource_path == script_path:
			found_script = true
			return
	print(node, node.name, " requires child script ", script_path)
	assert(found_script)
