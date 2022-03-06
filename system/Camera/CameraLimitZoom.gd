extends Node2D

export var view_offset_amount = 75
export var zoom_scale = 1.5

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
	
func find_world_camera_limits_complex():
	if not WorldSettings.room:
		return
	var cur_tile = WorldSettings.get_player_tile(bat.global_position)
	var check_tile
	
	var left = cur_tile.x-1
	while 1:
		check_tile = WorldSettings.connected_rooms.get(Vector2(left, cur_tile.y))
		DebugLogger.log_variable("left_tile:", check_tile)
		if not check_tile or check_tile != WorldSettings.room.mapname:
			break
		left = left - 1
	var right = cur_tile.x+1
	while 1:
		check_tile = WorldSettings.connected_rooms.get(Vector2(right, cur_tile.y))
		DebugLogger.log_variable("right_tile:", check_tile)
		if not check_tile or check_tile != WorldSettings.room.mapname:
			break
		right = right + 1
	var top = cur_tile.y-1
	while 1:
		check_tile = WorldSettings.connected_rooms.get(Vector2(cur_tile.x, top))
		DebugLogger.log_variable("top_tile:", check_tile)
		if not check_tile or check_tile != WorldSettings.room.mapname:
			break
		top = top - 1
	var bottom = cur_tile.y+1
	while 1:
		check_tile = WorldSettings.connected_rooms.get(Vector2(cur_tile.x, bottom))
		DebugLogger.log_variable("bottom_tile:", check_tile)
		if not check_tile or check_tile != WorldSettings.room.mapname:
			break
		bottom = bottom + 1

	left = WorldSettings.local_position(Vector2((left+1)*5*32, cur_tile.y), WorldSettings.room).x
	right = WorldSettings.local_position(Vector2((right)*5*32, cur_tile.y), WorldSettings.room).x
	top = WorldSettings.local_position(Vector2(cur_tile.x, (top+1)*4*32), WorldSettings.room).y
	bottom = WorldSettings.local_position(Vector2(cur_tile.x, (bottom)*4*32), WorldSettings.room).y
	DebugLogger.log_variable("bounds:",str(left)+","+str(right)+","+str(top)+","+str(bottom))
	return {'left':left,'right':right,'top':top,'bottom':bottom}
	
func find_world_camera_limits_simple():
	if not WorldSettings.room:
		return
	var left = null
	var right = null
	var top = null
	var bottom = null
	for tile in WorldSettings.room.get_used_cells():
		if left == null or tile.x<left:
			left = tile.x
		if right == null or tile.x>right:
			right = tile.x
		if top == null or tile.y<top:
			top = tile.y
		if bottom == null or tile.y>bottom:
			bottom = tile.y
	DebugLogger.log_variable("right:", right)
	return {
		'left': left*32,
		'right': right*32+32,
		'top': top*32,
		'bottom': bottom*32+32
	}
	
func find_area_camera_limits():
	for camera_region in get_tree().get_nodes_in_group("camera_region"):
		camera_region = camera_region as Area2D
		if camera_region.overlaps_body(bat):
			var rshape = camera_region.get_node("CollisionShape2D").shape
			return {
				'left': camera_region.global_position.x - rshape.extents[0],
				'right': camera_region.global_position.x + rshape.extents[0],
				'top': camera_region.global_position.y - rshape.extents[1],
				'bottom': camera_region.global_position.y + rshape.extents[1]
			}
	return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not bat:
		bat = get_tree().get_nodes_in_group("player")[0]
		return
		
	var _cam_target:Node2D = bat.get_node("CameraTarget")
	#cam_target.position = cam_target.position.linear_interpolate(
	#	bat.move.normalized()*view_offset_amount*camera.zoom, 1*delta
	#)

	if GlobalSettings.camera_limits:
		# Find horizontal tiles used
		#var limits = find_area_camera_limits()
		var limits
		if not limits:
			limits = find_world_camera_limits_simple()

		if limits:
			camera.limit_left = stable_lerp(camera.limit_left, limits.left, 250, delta)
			camera.limit_right = stable_lerp(camera.limit_right, limits.right, 250, delta)
			camera.limit_top = stable_lerp(camera.limit_top, limits.top, 250, delta)
			camera.limit_bottom = stable_lerp(camera.limit_bottom, limits.bottom, 250, delta)
		
		if camera.limit_left < -10000 or camera.limit_right > 10000 or camera.limit_top < -10000 or camera.limit_bottom > 10000:
			return

	var scalex = max(min(float(abs(camera.limit_right-camera.limit_left)) / 400.0, 2), 1)
	var scaley = max(min(float(abs(camera.limit_top-camera.limit_bottom)) / 400.0, 2), 1)
	var _scale = min(scalex,scaley)

	#camera.zoom = lerp(camera.zoom, Vector2(
	#	scale * zoom_scale,
	#	scale * zoom_scale
	#), delta*2)
	
