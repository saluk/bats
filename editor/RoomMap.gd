extends TileMap
class_name RoomMap

export var mapname:String
export var room_tileset:TileSet
export var room_cell_size:Vector2
export var room_offset:Vector2
export var generate_room_offset = true


func get_bounds():
	var min_x = null
	var max_x = null
	var min_y = null
	var max_y = null
	for coord in get_used_cells():
		#print(coord)
		if min_x==null or coord.x<min_x:
			min_x = coord.x
		if max_x==null or coord.x>max_x:
			max_x = coord.x
		if min_y==null or coord.y<min_y:
			min_y = coord.y
		if max_y==null or coord.y>max_y:
			max_y = coord.y
	
	return [min_x*cell_size.x, max_x*cell_size.x+cell_size.x, 
			min_y*cell_size.y, max_y*cell_size.y+cell_size.y]
