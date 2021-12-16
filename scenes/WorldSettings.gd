extends Node

export var debug = true
export var connected_rooms = {}

var player_tile = null
var player = null
var room:RoomMap = null

func get_player_global_position():
	if not room or not player:
		return null
	return global_position(player.position, room)

func get_player_tile(v:Vector2, m:RoomMap):
	v = global_position(v, m)
	return Vector2(
		int(v.x/(5 * 32)), 
		int(v.y/(4 * 32))
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
		return
	room = map
	
	var tile = get_player_tile(player.position, map)
	player_tile = tile
	if debug:
		player.get_node("Label").text = "x:"+str(int(player.position.x))+"("+str(tile.x)+")"+" y:"+str(int(player.position.y))+"("+str(tile.y)+")"
	if tile in connected_rooms:
		var connect_map_name = connected_rooms[tile]
		if connect_map_name == map.mapname:
			return
		print("warp to "+connect_map_name+" from "+map.mapname)
		really_bad_change_scene(player, connect_map_name, mapnode, map)


func really_bad_change_scene(player, scene_name, mapnode, map):
	var old_map = map
	var new_map_root:Node2D = load("res://scenes/generated/"+scene_name+".tscn").instance()
	
	old_map.get_parent().queue_free()
	old_map.queue_free()
	mapnode.add_child(new_map_root)
	var new_map = get_first_in_group("room_tilemap")
	room = new_map
	print(new_map.get_parent().name)
	
	var camera:Camera2D = player.get_node("Camera2D")
	player.position = local_position(global_position(player.position, old_map), new_map)
	camera.align()
	camera.reset_smoothing()
