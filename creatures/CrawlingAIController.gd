extends Node
class_name CrawlingAIController

### Constants/Parameters ###
var spot_distance = 100

### Operation variables ###
var creature:Creature = null  # Creature we are controlling
var target:Creature = null

var delta = 0.0
var direction = -1
var state = ""
var state_time = 0
var attached = true   # Try to attach to nearby walls or fall

func _ready():
	creature = get_parent()

func get_target():
	for n in get_tree().get_nodes_in_group("creature"):
		if n.alive:
			return n
	return null

func can_crawl():
	return true
func state_crawl():
	attached = true
	creature.animation.set_flipx(-direction)
	creature.move.x = direction * 25
	if creature.last_collision["collision"]:
		if creature.last_collision["type"] != "creature" and creature.last_collision["side"] == "left":
			direction = 1
		if creature.last_collision["type"] != "creature" and creature.last_collision["side"] == "right":
			direction = -1
			
func can_drop():
	if not attached:
		return false
	target = get_target()
	if target:
		return abs(target.global_position.x-creature.global_position.x) < 15 and target.global_position.y > creature.global_position.y
func state_drop():
	attached = false
	creature.move.x = 0
func apply_drop():
	state_time = 1.0
	
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
		"drop", "crawl"
	]
	for possible_state in states:
		if switch_to_state_if_possible(possible_state):
			return
			
func attach_to_walls():
	var ceiling = creature.get_node("UpCast").get_overlapping_bodies()
	if ceiling:
		creature.move.y = -10
	else:
		print("noceiling")

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
