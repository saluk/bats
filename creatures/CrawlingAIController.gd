extends StateMachine
class_name CrawlingAIController

### Constants/Parameters ###
var spot_distance = 100

### Operation variables ###
var creature:Creature = null  # Creature we are controlling
var target:Creature = null

export var direction = 1 # x direction to move along the floor, rotates with attached surface
var attached = true   # Try to attach to nearby walls or fall
var attach_direction = Vector2.ZERO  #Normal of wall we are attached to
var hit_wall = false
var hit_gap = false

func _ready():
	creature = get_parent()
	creature.connect("is_dead", self, "clear_attach")
	
func clear_attach():
	attached = false
	creature.animation.animatedSprite.modulate = Color(1, 0, 0)

func get_target():
	for n in get_tree().get_nodes_in_group("player"):
		if n.alive:
			return n
	return null
			
func check_hit_wall(space_state):
	var result
	var start_pos = creature.global_position
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
	
func check_hit_gap(space_state):
	var result
	var start_pos = creature.global_position + attach_move_direction()*1
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
	var space_state = creature.get_world_2d().direct_space_state
	if attached and attach_direction.length()==0:
		var result
		for vdirection in [Vector2(0,1), Vector2(0,-1), Vector2(1,0), Vector2(-1,0)]:
			result = space_state.intersect_ray(
				creature.global_position,
				creature.global_position + vdirection*10,
				[self],
				0b00000000000000000001
			)
			if not result.empty():
				attach_direction = -vdirection  #reverse ray to get normal
				break
	if attached and attach_direction:
		# Stick to surface force
		creature.move.x = 0
		creature.move.y = 0
		creature.move -= attach_direction * 10
		
		hit_wall = check_hit_wall(space_state)
		hit_gap = check_hit_gap(space_state)
		#print("attach_direction:", attach_direction)
		#print("attach_move_direction:", attach_move_direction())
		#print("hit_wall:", hit_wall)
		#print("hit_gap:", hit_gap)
		
		creature.animation.animatedSprite.rotation = lerp(
			creature.animation.animatedSprite.rotation,
			-attach_direction.angle_to(Vector2.UP),
			0.2)
		creature.get_node("Attack").rotation = -attach_direction.angle_to(Vector2.UP)
		if abs(attach_move_direction().x) > 0.5:
			creature.animation.set_flipx(-direction)
		if abs(attach_move_direction().y) > 0.5:
			creature.animation.set_flipx(direction)
		
func attach_move_direction():
	if not attach_direction:
		return Vector2(direction, 0)
	var move_dir = Vector2(direction, 0).rotated(attach_direction.angle_to(Vector2.UP))
	return move_dir

func _physics_process(_delta):
	if attached:
		attach_to_walls()
	else:
		creature.animation.animatedSprite.rotation_degrees = 0
		creature.get_node("Attack").rotation_degrees = 0

func update_brain():
	if creature.alive:
		.update_brain()
