extends Control

var seen_nodes = []
var offset
var layout

func _ready():
	# Pull the layout out of the map editor scene so we don't have the other elements
	offset = find_node("Offset")
	layout = Util.replace_node(
		offset.get_node("MapEditor"),
		offset.find_node("Layout")
	)

func _process(_delta):
	
	if WorldSettings.room and not WorldSettings.room.room_offset in seen_nodes:
		seen_nodes.append(WorldSettings.room.room_offset)
	for node in layout.get_children():
		if not node.room_offset in seen_nodes:
			node.visible = false
		else:
			node.visible = true
			if node.room_offset == WorldSettings.room.room_offset:
				node.modulate.a = 1.0
			else:
				node.modulate.a = 0.5
	var player_global_pos = WorldSettings.get_player_global_position()
	if not player_global_pos:
		return
	offset.position = -Vector2(
		player_global_pos.x/(32)*(15/5),
		player_global_pos.y/(32)*(12/4)
	) + Vector2(50, 50)
