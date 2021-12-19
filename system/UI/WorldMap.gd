extends Control

var seen_nodes = []
var mapeditor

func _process(_delta):
	var offset = find_node("Offset")
	var layout = find_node("Layout")
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
