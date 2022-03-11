extends Node

var spawned_elements = []
var scene_cache = {}

class SpawnInfo extends Reference:
	var path_or_scene
	var node:Node
	var time_spawned:int
	var time_limit:int
	
class CacheInfo extends Reference:
	var scene:PackedScene
	var time_cached:int
	func _init(path:String):
		if path:
			scene = load(path)
		time_cached = Engine.get_physics_frames()
	func spawn():
		return scene.instance()
		
#props dictionary:
#{
#	'singular': boolean - if true, only one node with this path can be spawned at a time
#	'time_limit': int - object will be destroyed after this amount of time
#	'parent': Node - object will spawn parented to this node
#	'position': Vector2 - object will be set to this global position
#}

func spawn(path_or_scene, props:Dictionary):
	var scene
	var info = SpawnInfo.new()
	if path_or_scene is String:
		if not path_or_scene in scene_cache:
			scene_cache[path_or_scene] = CacheInfo.new(path_or_scene)
		scene = scene_cache[path_or_scene]
	elif path_or_scene is PackedScene:
		scene = CacheInfo.new("")
		scene.scene = path_or_scene
	info.path_or_scene = path_or_scene
	if "singular" in props and props["singular"]:
		for s_info in spawned_elements:
			if s_info.path_or_scene == info.path_or_scene:
				return
	info.node = scene.spawn()
	info.time_spawned = Engine.get_physics_frames()
	if "time_limit" in props:
		info.time_limit = props["time_limit"]
	var parent
	if "parent" in props:
		parent = props["parent"]
	else:
		parent = get_tree().get_nodes_in_group("spawner")[0]
	if parent:
		parent.add_child(info.node)
	if "position" in props:
		info.node.global_position = props["position"]
	info.node.connect("tree_exited", self, "exit_node", [info.node])
	spawned_elements.append(info)
	return info.node
	
func exit_node(node):
	for info in spawned_elements:
		if info.node == node:
			spawned_elements.erase(info)
			return
		
func _physics_process(_delta):
	# There may be a performance issue here - we can optimize be scheduling when objects should be removed
	# and use signals to determine when to clear them
	for s_info in spawned_elements:
		if s_info.time_limit:
			if Engine.get_physics_frames()-s_info.time_spawned > s_info.time_limit:
				s_info.node.queue_free()
