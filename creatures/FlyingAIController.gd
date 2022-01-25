extends Node
class_name FlyingAIController

### Constants/Parameters ###
var spot_distance = 100

### Operation variables ###
var creature:Creature = null  # Creature we are controlling
var target:Creature = null

var delta = 0.0
var direction = -1
var state = ""
var state_time = 0

func _ready():
	creature = get_parent()

func get_target():
	for n in get_tree().get_nodes_in_group("creature"):
		if n.alive:
			return n
	return null

func can_fly_left():
	return true
func can_fly_right():
	return true
func state_fly_left():
	direction = -1
	creature.move = creature.move.move_toward(Vector2(-40, 0), self.delta*150)
	if creature.last_collision_type == "terrain" and creature.last_collision_side == "left":
		apply_state("fly_right")
func state_fly_right():
	direction = 1
	creature.move = creature.move.move_toward(Vector2(40, 0), self.delta*150)
	if creature.last_collision_type == "terrain" and creature.last_collision_side == "right":
		apply_state("fly_left")
func apply_fly_left():
	state_time = 2
func apply_fly_right():
	state_time = 2
	
func can_chase_target():
	target = get_target()
	if not target:
		return false
	if target.position.distance_to(creature.position) > spot_distance:
		print("too far away")
		return false
	if target.position.y < creature.position.y:
		print("wrong direction")
		return false
	return true
func apply_chase_target():
	state_time = 2
func state_chase_target():
	var d = creature.position.direction_to(target.position) * 50
	creature.move = creature.move.move_toward(d, self.delta*150)
	
func can_get_above_target():
	target = get_target()
	if not target:
		return false
	if target.position.distance_to(creature.position) > spot_distance:
		return false
	if target.position.y >= creature.position.y:
		return false
	return true
func apply_get_above_target():
	state_time = 1
func state_get_above_target():
	var vec = creature.position.direction_to(target.position)
	creature.move = Vector2(-vec.x * 50, -50)
	
func apply_state(s):
	state = s
	if has_method("apply_"+s):
		call("apply_"+s)
	return state
		
func switch_to_state_if_possible(new_state):
	if call("can_"+new_state):
		print("applying new state: ", new_state)
		return apply_state(new_state)
	return null

func new_state():
	var states:Array = [
		"chase_target", "get_above_target"
	]
	var flying_states:Array = ["fly_left", "fly_right"]
	randomize()
	flying_states.shuffle()
	states.append_array(flying_states)
	for possible_state in states:
		if switch_to_state_if_possible(possible_state):
			return

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


func _physics_process(delta):
	self.delta = delta
	update_brain()
