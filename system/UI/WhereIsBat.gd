extends Sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#var player_tile = WorldSettings.player_tile
	#var room = WorldSettings.room
	var player_global_pos = WorldSettings.get_player_global_position()
	if not player_global_pos:
		return
	position = Vector2(
		player_global_pos.x/(32)*(15/5),
		player_global_pos.y/(32)*(12/4)
	)
