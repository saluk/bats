extends Node
class_name BatPlayerController

### Operation variables ###
var bat:FlyingCreature = null
var left_charge = null
var right_charge = null

var input_buffer = []
var input_buffer_seconds = 0.1
var input_buffer_time = 0.0

func _ready():
	bat = get_parent()
	var _a = bat.connect("is_dead", self, "is_dead")
	left_charge = bat.get_node("LeftCharge")
	right_charge = bat.get_node("RightCharge")
	
func is_dead():
	ManageGame.reload()
	
# Body functions

func apply_input_buffer(action):
	input_buffer.append(action)
	if input_buffer == ['left', 'left']:
		double_left()
		return true
	elif input_buffer == ['right', 'right']:
		double_right()
		return true
	return false
	
func double_left():
	pass
	
func double_right():
	pass

func press_left():
	if apply_input_buffer('left'):
		return
	bat.flap_left()
	left_charge.begin_charge()
	
func press_right():
	if apply_input_buffer('right'):
		return
	bat.flap_right()
	right_charge.begin_charge()
	
# Input
func _unhandled_input(event):
	if not bat.alive: return
	if event is InputEventMouseButton:
		var click_pos = event.position
		if click_pos.x < ProjectSettings.get_setting("display/window/size/width")/2:
			if event.is_pressed():
				press_left()
			else:
				left_charge.release_charge()
		else:
			if event.is_pressed():
				press_right()
			else:
				right_charge.release_charge()
	elif event.is_action_pressed("ui_left"):
		press_left()
	elif event.is_action_pressed("ui_right"):
		press_right()
	elif event.is_action_pressed("ui_down"):
		if bat.holding:
			bat.drop_item()
		else:
			bat.grab_item()
	if event.is_action_released("ui_right"):
		right_charge.release_charge()
	if event.is_action_released("ui_left"):
		left_charge.release_charge()
	
func update_ui():
	var interact_buttons = get_tree().get_nodes_in_group("drop_button")
	var b:Button
	if interact_buttons:
		b = interact_buttons[0]
		if bat.holding:
			b.visible = true
		else:
			b.visible = false
		
	interact_buttons = get_tree().get_nodes_in_group("grab_button")
	if interact_buttons:
		b = interact_buttons[0]
		if bat.can_pickup():
			b.visible = true
		else:
			b.visible = false

	if GlobalSettings.auto_grab:
		bat.grab_item()
		if interact_buttons:
			interact_buttons[0].visible = false

func update_input_buffer(delta):
	input_buffer_time += delta
	if input_buffer_time >= input_buffer_seconds:
		input_buffer_time -= input_buffer_seconds
		input_buffer.remove(0)

func _physics_process(delta):
	update_ui()
	update_input_buffer(delta)
