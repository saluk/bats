extends NodeComponent
class_name BatPlayerController

### Operation variables ###
onready var bat = base_node as FlyingCreature
var left_charge = null
var right_charge = null

var input_buffer:InputBuffer

func _ready():
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
			'self': bat,
			'func_name': 'rush_attack',
			'args': [-1]
		},
		'attack_right': {
			'action': 'ui_right',
			'method': 'double',
			'self': bat,
			'func_name': 'rush_attack',
			'args': [1]
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

func _physics_process(_delta):
	update_ui()

func _unhandled_input(evt:InputEvent):
	if evt.is_action_pressed("load_state"):
		ManageGame.load_state()
