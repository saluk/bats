extends StateMachine
class_name CrawlingAIController

# TODO - New algorithm for gaps. Actual crawling!
# For the given slug rotation
#  Step forward along crawl path
#  Rotate toward where the surface should be
#  Is there a surface?
#     pull toward the current forward direction, counteract gravity, and push toward that surface a little
#  If there isn't a surface?
#     Rotate one more step to see if there is a curve
#     If there isn't, we should drop
#     If there is we can attach to that surface

# Another option:
# If we are on a tile, generate a path of contiguous movement, and move toward
# the next point
# If we aren't on a tile just drop

### Constants/Parameters ###
var spot_distance = 100

### Operation variables ###
var target:Creature = null

export var direction = 1 # x direction to move along the floor, rotates with attached surface
var attach_direction = Vector2.ZERO  #Normal of wall we are attached to
var space_state

func _ready():
	._ready()
	space_state = base_node.get_world_2d().direct_space_state
	var _a = base_node.connect("is_dead", self, "make_dead")
	
func make_dead():
	base_node.animation.animatedSprite.modulate = Color(1, 0, 0)

func get_target():
	for n in get_tree().get_nodes_in_group("player"):
		if n.alive:
			return n
	return null
			
func check_hit_wall():
	var result
	var start_pos = base_node.global_position
	#print("gap_start_pos:", start_pos)
	var end_pos = start_pos + attach_move_direction()*10
	#print("gap_end_pos:", end_pos)
	result = space_state.intersect_ray(
		start_pos,
		end_pos,
		[self],
		0b00000000000000000001
	)
	return not result.empty()
	
func check_hit_gap():
	var result
	var start_pos = base_node.global_position + attach_move_direction()*1
	#print("gap_start_pos:", start_pos)
	var end_pos = start_pos - attach_direction*20
	#print("gap_end_pos:", end_pos)
	result = space_state.intersect_ray(
		start_pos,
		end_pos,
		[self],
		0b00000000000000000001
	)
	return result.empty()
			
func attach_to_walls():
	# We should check attach direction every frame, but things get weird going around corners
	if attach_direction.length()==0:
		DebugLogger.log_increment("regenerate attach direction")
		var result
		for vdirection in [Vector2(0,1), Vector2(0,-1), Vector2(1,0), Vector2(-1,0)]:
			result = space_state.intersect_ray(
				base_node.global_position,
				base_node.global_position + vdirection*10,
				[self],
				0b00000000000000000001
			)
			if not result.empty():
				attach_direction = -vdirection  #reverse ray to get normal
				break
	base_node.animation.animatedSprite.rotation = lerp(
		base_node.animation.animatedSprite.rotation,
		-attach_direction.angle_to(Vector2.UP),
		0.2)
	base_node.get_node("Attack").rotation = -attach_direction.angle_to(Vector2.UP)
	if abs(attach_move_direction().x) > 0.5:
		base_node.animation.set_flipx(-direction)
	if abs(attach_move_direction().y) > 0.5:
		base_node.animation.set_flipx(direction)
				
func apply_attach_force(delta):
	if attach_direction.length()>0:
		# Stick to surface force
		DebugLogger.log_variable("attach force", attach_direction)
		base_node.move.y += (-1 * base_node.gravity*delta)
		base_node.move -= attach_direction * 10
		
func attach_move_direction():
	if attach_direction.length()==0:
		return Vector2(direction, 0)
	var move_dir = Vector2(direction, 0).rotated(attach_direction.angle_to(Vector2.UP))
	return move_dir

func _physics_process(_delta):
	attach_to_walls()

func update_brain():
	if base_node.alive:
		.update_brain()
