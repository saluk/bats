extends Node2D

export var mob_id = ""
export var open = false
export var closed_state = Vector2(0,0)
export var open_state = Vector2(0,-100)
export var open_speed = 1.0
var percent_open := 0.0
var goal_percent_open = null

var save_props = ["open"]

func _ready():
	ManageGame.load_props(self)
	connect("tree_exited", self, "exit_tree")
	set_open_state()
	
func exit_tree():
	ManageGame.set_props(self)
	
func update_open_state():
	get_node("KinematicBody2D").position = lerp(closed_state, open_state, percent_open)

func set_open_state():
	percent_open = 1.0
	if not open:
		percent_open = 0.0
	update_open_state()
	
func _physics_process(delta):
	DebugLogger.log_variable("open:","door_open:"+str(percent_open)+"/"+str(goal_percent_open))
	if goal_percent_open != null and (goal_percent_open-percent_open)!=0:
		percent_open += (goal_percent_open-percent_open)/abs(goal_percent_open-percent_open) * open_speed * delta
		if percent_open <= 0:
			open = false
			goal_percent_open = null
		elif percent_open >= 1.0:
			open = true
			goal_percent_open = null
	update_open_state()

func trigger_open():
	goal_percent_open = 1.0
	# Save that its open in case player exits before animation finishes
	open = true
