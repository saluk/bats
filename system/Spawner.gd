extends Node

var spawned_elements = []
var scene_cache = {}
var spawn_parent:Node  # What spawned objects default to be parented to

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
		var node = scene.instance()
		return node
		
#props dictionary:
#{
#	'singular': boolean - if true, only one node with this path can be spawned at a time
#	'time_limit': int - object will be destroyed after this amount of time
#	'parent': Node - object will spawn parented to this node
#	'position': Vector2 - object will be set to this global position
#}

func create_spawn_parent():
	var possible_nodes = get_tree().get_nodes_in_group("spawner")
	if not possible_nodes:
		spawn_parent = Node.new()
		spawn_parent.name = "level_spawn_parent"
		spawn_parent.add_to_group("spawner")
		WorldSettings.room.add_child(spawn_parent)
	else:
		spawn_parent = possible_nodes[0]
		
func instance_scene(path_or_scene):
	var cached:CacheInfo
	var scene:Node
	if path_or_scene is String:
		if not path_or_scene in scene_cache:
			scene_cache[path_or_scene] = CacheInfo.new(path_or_scene)
		cached = scene_cache[path_or_scene]
	elif path_or_scene is PackedScene:
		cached = CacheInfo.new("")
		cached.scene = path_or_scene
	elif path_or_scene is Node:
		scene = path_or_scene
	else:
		assert(false, "path_or_scene is not a path, packedscene, or node")
	assert(cached or scene)
	if cached:
		scene = cached.spawn()
		scene.connect("tree_exited", self, "exit_node", [scene])
	return scene

func spawn(path_or_scene, props:Dictionary):
	if "singular" in props and props["singular"]:
		for s_info in spawned_elements:
			if s_info.path_or_scene == path_or_scene:
				return
				
	var info = SpawnInfo.new()
	info.path_or_scene = path_or_scene

	info.node = instance_scene(path_or_scene)
	assert(info.node!=null)

	info.time_spawned = Engine.get_physics_frames()
	if "time_limit" in props:
		info.time_limit = props["time_limit"]
	var parent
	if "parent" in props:
		parent = props["parent"]
	else:
		create_spawn_parent()
		assert(spawn_parent)
		parent = spawn_parent
	if parent:
		parent.add_child(info.node)
	if "position" in props:
		info.node.global_position = props["position"]
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
