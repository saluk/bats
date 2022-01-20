extends Node
class_name BatPlayerController

export var view_offset_amount = 75

### Operation variables ###
var bat:FlyingCreature = null
var left_charge = null
var right_charge = null

var input_buffer:InputBuffer

func _ready():
	bat = get_parent()
	left_charge = bat.get_node("LeftCharge")
	right_charge = bat.get_node("RightCharge")
	
	input_buffer = InputBuffer.new({
		'jump_left': {
			'action': 'ui_left',
			'method': 'tapped',
			'self': bat,
			'func_name': 'flap_left'
		},
		'jump_right': {
			'action': 'ui_right',
			'method': 'tapped',
			'self': bat,
			'func_name': 'flap_right'
		},
		'attack_left': {
			'action': 'ui_left',
			'method': 'double',
			'self': left_charge,
			'func_name': 'apply_charge'
		},
		'attack_right': {
			'action': 'ui_right',
			'method': 'double',
			'self': right_charge,
			'func_name': 'apply_charge'
		},
		'charge_left': {
			'action': 'ui_left',
			'method': 'holding',
			'self': left_charge,
			'func_name': 'begin_charge'
		},
		'release_charge_left': {
			'action': 'ui_left',
			'method': 'released',
			'self': left_charge,
			'func_name': 'release_charge'
		},
		'charge_right': {
			'action': 'ui_right',
			'method': 'holding',
			'self': right_charge,
			'func_name': 'begin_charge'
		},
		'release_charge_right': {
			'action': 'ui_right',
			'method': 'released',
			'self': right_charge,
			'func_name': 'release_charge'
		}
	})
	add_child(input_buffer)
	var _a = bat.connect("is_dead", ManageGame, "reload")
	var _b = bat.connect("is_dead", self, "bat_dead")
	
func bat_dead():
	input_buffer.input_mappings = {}
	
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
		
func double_tap(action):
	if action == 'left':
		pass#double_left()
	if action == 'right':
		pass#double_right()
	
func update_camera(delta):
	var cam_target:Node2D = get_parent().get_node("CameraTarget")
	cam_target.position = cam_target.position.linear_interpolate(
		bat.move.normalized()*view_offset_amount, 1*delta
	)

func _physics_process(delta):
	update_ui()
	update_camera(delta)
