extends Node
class_name BatPlayerController

### Operation variables ###
var bat:FlyingCreature = null

func _ready():
	bat = get_parent()
	var _a = bat.connect("is_dead", self, "is_dead")
	
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
		else:
			bat.flap_right()
	elif event.is_action_pressed("ui_left"):
		bat.flap_left()
		bat.begin_charge()
	elif event.is_action_pressed("ui_right"):
		bat.flap_right()
		bat.begin_charge()
	elif event.is_action_released("ui_left"):
		bat.release_charge()
	elif event.is_action_released("ui_right"):
		bat.release_charge()
	elif event.is_action_pressed("ui_down"):
		if bat.holding:
			bat.drop_item()
		else:
			bat.grab_item()
	
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
