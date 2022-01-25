extends Node2D

export var view_offset_amount = 75

var camera:Camera2D
var bat:FlyingCreature

func _ready():
	camera = get_child(0)
	
func stable_lerp(cur_val, val, speed, dt):
	var d = val-cur_val
	if abs(d) > 5000:
		speed = abs(d)
		dt = 1
	if d == 0:
		return val
	d = d/abs(d)
	cur_val += d*speed*dt
	if cur_val == val:
		return cur_val
	if (val-cur_val)/abs(val-cur_val) != d:
		return val
	return cur_val

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not bat:
		bat = get_tree().get_nodes_in_group("player")[0]
		return
		
	var cam_target:Node2D = bat.get_node("CameraTarget")
	cam_target.position = cam_target.position.linear_interpolate(
		bat.move.normalized()*view_offset_amount*camera.zoom, 1*delta
	)

	if GlobalSettings.camera_limits:
		# Find horizontal tiles used
		var cur_tile = WorldSettings.get_player_tile(bat.global_position)
		var check_tile
		
		var left = cur_tile.x
		while 1:
			check_tile = WorldSettings.connected_rooms.get(Vector2(left-1, cur_tile.y))
			if not check_tile or check_tile != WorldSettings.room.mapname:
				break
			left = left - 1
		var right = cur_tile.x
		while 1:
			check_tile = WorldSettings.connected_rooms.get(Vector2(right+1, cur_tile.y))
			if not check_tile or check_tile != WorldSettings.room.mapname:
				break
			right = right + 1
		var top = cur_tile.y
		while 1:
			check_tile = WorldSettings.connected_rooms.get(Vector2(cur_tile.x, top-1))
			if not check_tile or check_tile != WorldSettings.room.mapname:
				break
			top = top - 1
		var bottom = cur_tile.y
		while 1:
			check_tile = WorldSettings.connected_rooms.get(Vector2(cur_tile.x, bottom+1))
			if not check_tile or check_tile != WorldSettings.room.mapname:
				break
			bottom = bottom + 1

		left = WorldSettings.local_position(Vector2(left*5*32, cur_tile.y), WorldSettings.room).x
		right = WorldSettings.local_position(Vector2((right+1)*5*32, cur_tile.y), WorldSettings.room).x
		top = WorldSettings.local_position(Vector2(cur_tile.x, top*4*32), WorldSettings.room).y
		bottom = WorldSettings.local_position(Vector2(cur_tile.x, (bottom+1)*4*32), WorldSettings.room).y

		camera.limit_left = stable_lerp(camera.limit_left, left, 250, delta)
		camera.limit_right = stable_lerp(camera.limit_right, right, 250, delta)
		camera.limit_top = stable_lerp(camera.limit_top, top, 250, delta)
		camera.limit_bottom = stable_lerp(camera.limit_bottom, bottom, 250, delta)
		
		if camera.limit_left < -10000 or camera.limit_right > 10000 or camera.limit_top < -10000 or camera.limit_bottom > 10000:
			return

	var scalex = max(min(float(abs(camera.limit_right-camera.limit_left)) / 400.0, 2), 1)
	var scaley = max(min(float(abs(camera.limit_top-camera.limit_bottom)) / 400.0, 2), 1)
	var scale = min(scalex,scaley)

	camera.zoom = lerp(camera.zoom, Vector2(
		scale,
		scale
	), delta*2)
