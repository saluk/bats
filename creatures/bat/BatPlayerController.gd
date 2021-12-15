extends Node
class_name BatPlayerController

### Operation variables ###
var bat:FlyingCreature = null
var left_charge = null
var right_charge = null

func _ready():
	bat = get_parent()
	var _a = bat.connect("is_dead", self, "is_dead")
	left_charge = bat.get_node("LeftCharge")
	right_charge = bat.get_node("RightCharge")
	
func is_dead():
	ManageGame.reload()
	
# Body functions
	
# Input
func _unhandled_input(event):
	if not bat.alive: return
	if event is InputEventMouseButton and event.is_pressed():
		var click_pos = event.position
		if click_pos.x < ProjectSettings.get_setting("display/window/size/width")/2:
			bat.flap_left()
			left_charge.begin_charge()
		else:
			bat.flap_right()
			right_charge.begin_charge()
	elif event is InputEventMouseButton and not event.is_pressed():
		bat.release_charge()
	elif event.is_action_pressed("ui_left"):
		bat.flap_left()
		left_charge.begin_charge()
	elif event.is_action_pressed("ui_right"):
		bat.flap_right()
		right_charge.begin_charge()
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

func _physics_process(_delta):
	update_ui()
