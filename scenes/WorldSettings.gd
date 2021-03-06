extends Node

export var debug = true
export var connected_rooms = {}

var player_tile = null
var player = null
var room:RoomMap = null

var block_width = 5
var block_height = 4

func room_width():
	return block_width * 32
	
func room_height():
	return block_height * 32

func get_player_global_position():
	if not room or not player:
		return null
	return global_position(player.position, room)

func get_player_tile(v:Vector2):
	if room:
		v = global_position(v, room)
	return Vector2(
		floor(v.x/(5 * 32)), 
		floor(v.y/(4 * 32))
	)
	
func global_position(local:Vector2, m:RoomMap):
	return Vector2(
		(local.x+m.room_offset.x*(5*32)),
		(local.y+m.room_offset.y*(4*32))
	)
	
func local_position(global:Vector2, m:RoomMap):
	return Vector2(
		global.x-m.room_offset.x*(5*32),
		global.y-m.room_offset.y*(4*32)
	)
	
func get_first_in_group(group:String, ensure_single=true):
	var nodes = get_tree().get_nodes_in_group(group)
	var valid = []
	for n in nodes:
		if is_instance_valid(n) and not n.is_queued_for_deletion():
			valid.append(n)
	if ensure_single:
		assert(valid.size()<=1, "Found multiple objects in a singleton group")
	if valid:
		return valid[0]
	return null

func _process(_delta):
	player = get_first_in_group("player")
	if not player:
		return
	var mapnode = get_tree().root.get_node_or_null("prototype/MapNode")
	if not mapnode:
		return
	var map:TileMap = get_first_in_group("room_tilemap")
	if not map:
		# Load player to the position defined on the MapEditor
		var map_editor = load("res://editor/MapEditor.tscn").instance()
		var map_editor_player = map_editor.get_node("Player/Bat")
		print(map_editor_player.position)
		var start_pos = Vector2(
			int(map_editor_player.position.x/15*5*32),
			int(map_editor_player.position.y/12*4*32)
		)
		print(start_pos)
		room = map
		var load_tile = get_player_tile(start_pos)
		print("load load tile ", load_tile)
		if load_tile in connected_rooms:
			print("loading a map from none")
			switch_connected_map(load_tile, null, mapnode, start_pos)
		else:
			print("no map tile found ", load_tile, " ", connected_rooms.keys())
			pass
		map_editor.queue_free()
		return
	room = map
	
	var tile = get_player_tile(player.position)
	player_tile = tile
	if debug:
		player.get_node("Label").text = "x:"+str(int(player.position.x))+"("+str(tile.x)+")"+" y:"+str(int(player.position.y))+"("+str(tile.y)+")"
	if tile in connected_rooms:
		switch_connected_map(tile, map, mapnode, null)
		
func switch_connected_map(tile, map, mapnode, new_pos):
	var connect_map_name = connected_rooms[tile]
	if map and connect_map_name == map.mapname:
		return
	if map:
		print("warp to "+connect_map_name+" from "+map.mapname)
	really_bad_change_scene(connect_map_name, mapnode, map, new_pos)

func really_bad_change_scene(scene_name, mapnode, map, new_pos):
	var old_map = map
	var new_map_root:Node2D = load("res://scenes/generated/"+scene_name+".tscn").instance()
	
	if old_map:
		old_map.get_parent().queue_free()
		old_map.queue_free()
	mapnode.add_child(new_map_root)
	var new_map = get_first_in_group("room_tilemap")
	room = new_map
	print(new_map.get_parent().name)
	
	var camera:Camera2D = player.get_tree().root.get_node("prototype/CameraLocalTarget/Camera2D")
	if new_pos:
		player.global_position = local_position(new_pos, new_map)
	else:
		player.global_position = local_position(global_position(player.position, old_map), new_map)
	# TODO we still get one frame of the wrong position drawn, but its better
	player.get_tree().root.get_node("prototype/CameraLocalTarget").global_position = player.get_node("CameraTarget").global_position
	camera.limit_left = -10000
	camera.limit_right = 10000
	camera.limit_top = -10000
	camera.limit_bottom = 10000
	camera.align()
	camera.reset_smoothing()
