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
	
func is_prototype():
	return get_tree().root.has_node("prototype")

func check_deleted(node):
	if node.mob_id in saved_object_states:
		if 'deleted' in saved_object_states[node.mob_id]:
			if saved_object_states[node.mob_id]['deleted'] == true:
				node.queue_free()
				return true
	return false

func set_deleted(node):
	if not node.mob_id in saved_object_states:
		saved_object_states[node.mob_id] = {}
	saved_object_states[node.mob_id]['deleted'] = true
	
func load_props(node):
	if node.mob_id in saved_object_states:
		for prop in node.save_props:
			if prop in saved_object_states[node.mob_id]:
				node.set(prop, saved_object_states[node.mob_id][prop])
				
func set_props(node):
	if not node.mob_id in saved_object_states:
		saved_object_states[node.mob_id] = {}
	for prop in node.save_props:
		print("saving ",prop," as ", node.get(prop))
		saved_object_states[node.mob_id][prop] = node.get(prop)
	print(saved_object_states)

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
	
func load_state():
	var file = File.new()
	if file.file_exists("user://state"):
		file.open("user://state", File.READ)
		var state = file.get_var()
		file.close()
		var bat = get_tree().get_nodes_in_group("player")[0]
		saved_object_states = state["saved_object_states"]
		bat.position.x = state["player_pos"]["x"]
		bat.position.y = state["player_pos"]["y"]
		bat.move = Vector2.ZERO
		

func save_state():
	var bat = get_tree().get_nodes_in_group("player")[0]
	var state = {
		"player_pos": {"x":bat.position.x, "y":bat.position.y},
		"saved_object_states": saved_object_states
	}
	var file = File.new()
	file.open("user://state", File.WRITE)
	file.store_var(state)
	file.close()
