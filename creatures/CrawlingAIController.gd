extends Node
class_name CrawlingAIController

### Constants/Parameters ###
var spot_distance = 100

### Operation variables ###
var creature:Creature = null  # Creature we are controlling
var target:Creature = null

var delta = 0.0
export var direction = 1 # x direction to move along the floor, rotates with attached surface
var state = ""
var state_time = 0
var attached = true   # Try to attach to nearby walls or fall
var attach_direction = Vector2.ZERO  #Normal of wall we are attached to
var hit_wall = false
var hit_gap = false

func _ready():
	creature = get_parent()
	creature.connect("is_dead", self, "clear_attach")
	creature.get_node("Attack").connect("body_entered", self, "damage_bat")
	
func clear_attach():
	attached = false
	creature.animation.animatedSprite.modulate = Color(1, 0, 0)

func get_target():
	for n in get_tree().get_nodes_in_group("player"):
		if n.alive:
			return n
	return null

func apply_crawl():
	state_time = 0.25
func can_crawl():
	return true
func state_crawl():
	attached = true
	creature.move += attach_move_direction() * 25
	if hit_wall:
		attach_direction = -attach_move_direction()
		direction = -direction
	elif hit_gap:
		# TODO we are bad at gaps
		#attach_direction = attach_move_direction()
		direction = -direction
			
func can_drop():
	if not attached:
		print("not attached cant drop")
		return false
	target = get_target()
	if target:
		print("target range:", abs(target.global_position.x-creature.global_position.x))
		print("target below:", target.global_position.y > creature.global_position.y)
		return abs(target.global_position.x-creature.global_position.x) < 10 and target.global_position.y > creature.global_position.y
func state_drop():
	attached = false
	attach_direction = Vector2.ZERO
	creature.move.x = 0
func apply_drop():
	state_time = 1.0
	creature.move.y = 100
	
func apply_state(s):
	state = s
	if has_method("apply_"+s):
		DebugLogger.log_variable("ApplyState."+get_parent().name, state)
		call("apply_"+s)
	return state
		
func switch_to_state_if_possible(new_state):
	if call("can_"+new_state):
		return apply_state(new_state)
	return null

func new_state():
	var states:Array = [
		"drop", "crawl"
	]
	for possible_state in states:
		if switch_to_state_if_possible(possible_state):
			return
			
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
	var start_pos = creature.global_position + attach_move_direction()*10
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
		
		creature.animation.animatedSprite.rotation = -attach_direction.angle_to(Vector2.UP)
		if abs(attach_move_direction().x) > 0.5:
			creature.animation.set_flipx(-direction)
		if abs(attach_move_direction().y) > 0.5:
			creature.animation.set_flipx(direction)
	else:
		creature.animation.animatedSprite.rotation_degrees = 0
		
func attach_move_direction():
	if not attach_direction:
		return Vector2(direction, 0)
	var move_dir = Vector2(direction, 0).rotated(attach_direction.angle_to(Vector2.UP))
	return move_dir

# Input
func update_brain():
	if not creature.alive: return
	if state:
		state_time -= self.delta
		if state_time <= 0:
			new_state()
		call("state_"+state)
	else:
		new_state()


func _physics_process(_delta):
	delta = _delta
	if attached:
		attach_to_walls()
	update_brain()
	#print("move:",creature.move)
	pass

func damage_bat(body:Node2D):
	if not creature.alive:
		return
	if "player" in body.get_groups():
		body.do_damage(1, creature.global_position - body.global_position)
