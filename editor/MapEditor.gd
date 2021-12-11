tool
extends Node2D

var destructive = false

export var bake_map = false setget do_bake_map_safe
export var bake_map_destructive = false setget do_bake_map_destructive

func do_bake_map_safe(val):
	if val == true:
		destructive = false
		do_bake_map()

func do_bake_map_destructive(val):
	if val == true:
		destructive = true
		do_bake_map()

func do_bake_map():
	print("Baking map...")
	for n in get_node("Layout").get_children():
		bake_map_for(n)

func _ready():
	pass
	
func scene_file(name):
	return "res://scenes/generated/"+name+".tscn"
	
func get_scene_for(name):
	if not ResourceLoader.exists(scene_file(name)):
		return null
	return load(scene_file(name)).instance()
	
func make_scene_for(source_map):
	print("-- Making new scene for "+source_map.name)
	var scene = Node2D.new()
	scene.name = "MapRoot"
	var tilemap = TileMap.new()
	tilemap.cell_size = source_map.room_cell_size
	tilemap.tile_set = source_map.room_tileset
	tilemap.name = "GeneratedTileMap"
	scene.add_child(tilemap)
	tilemap.set_owner(scene)
	return scene
	
func save_scene(scene, filename):
	var pack = PackedScene.new()
	pack.pack(scene)
	ResourceSaver.save(filename, pack)
	
# match the tiles from the generatedtilemap to the tilemap
func edit_scene(scene, tilemap):
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
	for x in range(min_x, max_x+1):
		for y in range(min_y, max_y+1):
			var has_tile = tilemap.get_cell(x, y)
			tile_id = tilemap.get_cell_autotile_coord(x, y)
			map_ref = get_node("Config/"+str(tile_id.x)+","+str(tile_id.y))
			print("assign",x,",",y)
			for ref_x in range(0,6):
				for ref_y in range(0,5):
					var ref_id = map_ref.get_cell(ref_x, ref_y)
					var autotile_coord = map_ref.get_cell_autotile_coord(ref_x, ref_y)
					print(ref_id, ref_x, ", ", ref_y, ",", autotile_coord)
					var coord = Vector2(
						(x-min_x)*5+ref_x,
						(y-min_y)*4+ref_y
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
	
func bake_map_for(tilemap:TileMap):
	print("- Baking map for ",tilemap.name)
	var scene = get_scene_for(tilemap.name)
	if not scene or destructive:
		scene = make_scene_for(tilemap)
	print("scene", scene)
	edit_scene(scene, tilemap)
