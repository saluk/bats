extends Node
class_name ArcherAIController

### Constants/Parameters ###
var spot_distance = 500
var arrow_node

### Operation variables ###
var creature = null  # Creature we are controlling
var target:FlyingCreature = null

var delta = 0.0
var direction = -1
var state = ""
var state_time = 0

var fire_time = 0

func _ready():
	randomize()
	arrow_node = load("res://objects/projectiles/Arrow.tscn")
	creature = get_parent()
	var _a = creature.connect("stunned", self, "was_stunned")

func get_target():
	for n in get_tree().get_nodes_in_group("player"):
		if n.alive:
			return n
	return null

func can_walk_left():
	return true
func can_walk_right():
	return true
func state_walk_left():
	direction = -1
	creature.walk_left()
	creature.move = creature.move.move_toward(Vector2(-40, 0), self.delta*150)
	if creature.last_collision.left and creature.last_collision.left.type == "terrain":
		apply_state("walk_right")
func state_walk_right():
	direction = 1
	creature.walk_right()
	creature.move = creature.move.move_toward(Vector2(40, 0), self.delta*150)
	if creature.last_collision.right and creature.last_collision.right.type == "terrain":
		apply_state("walk_left")
func apply_walk_left():
	state_time = 2
func apply_walk_right():
	state_time = 2
	
func can_chase_target():
	target = get_target()
	if not target or not target.alive:
		return false
	if target.position.distance_to(creature.position) > spot_distance:
		print("too far away")
		return false
	return true
func apply_chase_target():
	state_time = 2
func state_chase_target():
	var d = creature.global_position.direction_to(target.global_position) * 50
	if d.x<0:
		creature.walk_left()
	elif d.x>0:
		creature.walk_right()
	creature.move = creature.move.move_toward(Vector2(d.x, 0), self.delta*150)
	switch_to_state_if_possible("fire_at_target")
	
func can_fire_at_target():
	if not target or not target.alive:
		return false
	if target.global_position.y - 15 > creature.global_position.y:
		return false
	if fire_time > 0:
		return false
	return true
func state_fire_at_target():
	var d = creature.global_position.direction_to(target.global_position)
	if fire_time <= 0:
		creature.get_node("AnimatedSprite").play("shoot_med")
	if creature.get_node("AnimatedSprite").frame >= 4 and fire_time <= 0:
		var arrow = arrow_node.instance()
		creature.get_parent().add_child(arrow)
		arrow.position = creature.position
		arrow.mover_node.direction = d
		arrow.mover_node.rotate_sprite = true
		state_time = 0
		fire_time = rand_range(1, 2)
		
func can_stunned():
	return false
func apply_stunned():
	state_time = 3
	creature.get_node("Star").visible = true
func state_stunned():
	creature.get_node("AnimatedSprite").play("idle")
func exit_stunned():
	creature.get_node("Star").visible = false
	
func apply_state(s):
	if state and has_method("exit_"+state):
		call("exit_"+state)
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
		"stunned",
		"chase_target",
		"fire_at_target"
	]
	var flying_states:Array = ["walk_left", "walk_right"]
	flying_states.shuffle()
	states.append_array(flying_states)
	for possible_state in states:
		if switch_to_state_if_possible(possible_state):
			return

# Input
func update_brain():
	if not creature.alive: return
	if fire_time > 0:
		fire_time -= self.delta
	if state:
		state_time -= self.delta
		if state_time <= 0:
			new_state()
		call("state_"+state)
	else:
		new_state()


func _physics_process(d):
	self.delta = d
	update_brain()

# Events
func was_stunned():
	if not creature.alive:
		return
	if state != "stunned":
		apply_state("stunned")
