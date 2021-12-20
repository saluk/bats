tool
extends Node2D
class_name MapEditor

export var bake_map = false setget do_bake_map

export var export_path = "res://scenes/generated/"
export var save_world_settings = true

func do_bake_map(val):
	if val != true:
		return
	print("Baking map...")
	for n in get_node("Layout").get_children():
		print(n.name)
		bake_map_for(n)
	var world_settings = load("res://scenes/WorldSettings.tscn").instance()
	world_settings.connected_rooms = find_connected_rooms()
	print(world_settings.connected_rooms)
	if save_world_settings:
		save_scene(world_settings, "res://scenes/WorldSettings.tscn")
		save_scene(world_settings, "res://scenes/WorldSettings.tscn")
	world_settings.free()
	
func bake_map_for(tilemap:TileMap):
	print("- Baking map for ",tilemap.name)
	var scene = get_scene_for(tilemap.name)
	if not scene:
		scene = Node2D.new()
	update_scene_for(scene, tilemap)
	print("scene", scene)
	edit_scene(scene, tilemap)
	scene.free()
	
func scene_file(name):
	return export_path+name+".tscn"
	
func get_scene_for(name):
	if not ResourceLoader.exists(scene_file(name)):
		return null
	return load(scene_file(name)).instance()
	
func update_scene_for(scene:Node, source_map):
	print("-- (Re)Making new scene for "+source_map.name)
	scene.name = source_map.name
	# Clear all children that aren't saved
	for child in scene.get_children():
		if child.name.begins_with("Save"):
			continue
		scene.remove_child(child)
		child.queue_free()
	scene.add_to_group("room_root", true)
	var tilemap:RoomMap = RoomMap.new()
	tilemap.add_to_group("room_tilemap", true)
	print("GROUPS:", tilemap.get_groups())
	tilemap.cell_size = source_map.room_cell_size
	tilemap.tile_set = source_map.room_tileset
	tilemap.name = "GeneratedTileMap"
	tilemap.room_offset = source_map.room_offset
	tilemap.mapname = source_map.name
	tilemap.generate_room_offset = false
	scene.add_child(tilemap)
	tilemap.set_owner(scene)
	#var label = Label.new()
	#label.text = source_map.name
	#scene.add_child(label)
	#label.set_owner(scene)
	return scene
	
func save_scene(scene, filename):
	print("SAVING:", scene, filename)
	var pack = PackedScene.new()
	pack.pack(scene)
	var _ERR = ResourceSaver.save(filename, pack)

# match the tiles from the generatedtilemap to the tilemap
func edit_scene(scene, tilemap:RoomMap):
	var save_map:TileMap = scene.get_node("GeneratedTileMap")
	var tile_id
	var map_ref:TileMap
	var min_x = null
	var min_y = null
	var max_x = null
	var max_y = null
	for cell_index in tilemap.get_used_cells():
		if min_x == null or cell_index.x < min_x:
			min_x = cell_index.x
		if min_y == null or cell_index.y < min_y:
			min_y = cell_index.y
		if max_x == null or cell_index.x > max_x:
			max_x = cell_index.x
		if max_y == null or cell_index.y > max_y:
			max_y = cell_index.y
	if tilemap.generate_room_offset:
		tilemap.generate_room_offset = false
		tilemap.room_offset = Vector2(min_x, min_y)
	var offset = tilemap.room_offset
	save_map.clear()
	for x in range(min_x, max_x+1):
		for y in range(min_y, max_y+1):
			var has_tile = tilemap.get_cell(x, y)
			tile_id = tilemap.get_cell_autotile_coord(x, y)
			#print(x,',',y,',',tile_id)
			map_ref = get_node("Config/"+str(tile_id.x)+","+str(tile_id.y))
			#print("assign",x,",",y)
			for ref_x in range(0,6):
				for ref_y in range(0,5):
					var ref_id = map_ref.get_cell(ref_x, ref_y)
					var autotile_coord = map_ref.get_cell_autotile_coord(ref_x, ref_y)
					#print(ref_id, ref_x, ", ", ref_y, ",", autotile_coord)
					var coord = Vector2(
						(x-offset.x)*5+ref_x,
						(y-offset.y)*4+ref_y
					)
					if ref_id>=0 and has_tile>=0:
						save_map.set_cell(
							coord.x, 
							coord.y,
							ref_id,
							false,
							false,
							false,
							autotile_coord)
					else:
						save_map.set_cell(coord.x, coord.y, ref_id)
	save_scene(scene, scene_file(tilemap.name))


# Connected rooms is a list of transition tiles
# It's a dictionary. 
# The key is a map-scale coordinate 'coord'
# The value is a map name
# When the player's position lies within 'coord', 
# they should transition to map 'offset' if they are
# not there already
func find_connected_rooms():
	var connectable_spots = {}
	var names = {}
	for n in get_node("Layout").get_children():
		for cell_index in n.get_used_cells():
			var ref = n.get_cell(cell_index.x, cell_index.y)
			var coord = n.get_cell_autotile_coord(cell_index.x, cell_index.y)
			if ref == 1 and coord.x == 1 and coord.y == 1:
				connectable_spots[cell_index] = n.room_offset
				names[n.room_offset] = n.name
	var connected_rooms = {}
	for spot in connectable_spots.keys():
		var cur_room = connectable_spots[spot]
		for x in [-1,0,1]:
			for y in [-1,0,1]:
				if x==0 and y==0:
					continue
				if x!=0 and y!=0:
					continue
				var connected_index = Vector2(
					spot.x+x, spot.y+y
				)
				if not connected_index in connectable_spots:
					continue
				var connected_room = connectable_spots[connected_index]
				if connected_room == cur_room:
					continue
				connected_rooms[connected_index] = names[connected_room]
	print(connected_rooms)
	return connected_rooms
