extends Node
class_name FlyingAIController

### Operation variables ###
var creature:FlyingCreature = null
var target:FlyingCreature = null

var direction = -1
var state = "fly_right"
var state_time = 0

func _ready():
	creature = get_parent()
	apply_state("fly_right")

func get_target():
	for n in get_tree().get_nodes_in_group("creature"):
		return n
	return null

func can_fly_left():
	return direction == -1
func can_fly_right():
	return direction == 1
func state_fly_left():
	direction = -1
	creature.move = Vector2(-40, 0)
	if creature.last_collision_type == "terrain" and creature.last_collision_side == "left":
		apply_state("fly_right")
func state_fly_right():
	direction = 1
	creature.move = Vector2(40, 0)
	if creature.last_collision_type == "terrain" and creature.last_collision_side == "right":
		apply_state("fly_left")
func apply_fly_left():
	state_time = 2
func apply_fly_right():
	state_time = 2
	
func can_chase_target():
	target = get_target()
	if target.position.distance_to(creature.position) > 100:
		return false
	if target.position.y < creature.position.y:
		return false
	return true
func apply_chase_target():
	state_time = 2
func state_chase_target():
	creature.move = creature.position.direction_to(target.position) * 50
	
func can_get_above_target():
	target = get_target()
	if target.position.distance_to(creature.position) > 100:
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

func new_state():
	for possible_state in [
		"chase_target", "get_above_target",
		"fly_left", "fly_right"
	]:
		if call("can_"+possible_state):
			state = possible_state
			break
	apply_state(state)

# Input
func update_brain(delta):
	if not creature.alive: return
	if state:
		state_time -= delta
		if state_time <= 0:
			new_state()
		call("state_"+state)
	else:
		new_state()


func _physics_process(delta):
	update_brain(delta)
