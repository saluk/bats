extends NodeComponent
class_name BatPlayerController

### Operation variables ###
onready var bat = base_node as FlyingCreature
var charge = null

var input_buffer:InputBuffer

func _ready():
	charge = bat.get_node("Charge")
	
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
			'self': charge,
			'func_name': 'begin_charge',
			'args': [-1]
		},
		'release_charge_left': {
			'action': 'ui_left',
			'method': 'released',
			'self': charge,
			'func_name': 'release_charge',
			'args': [1]
		},
		'charge_right': {
			'action': 'ui_right',
			'method': 'holding',
			'self': charge,
			'func_name': 'begin_charge',
			'args': [1]
		},
		'release_charge_right': {
			'action': 'ui_right',
			'method': 'released',
			'self': charge,
			'func_name': 'release_charge',
			'args': [1]
		}
	})
	add_child(input_buffer)
	var _a = bat.connect("is_dead", ManageGame, "reload")
	var _b = bat.connect("is_dead", self, "bat_dead")
	
func bat_dead():
	input_buffer.input_mappings = {}
	
func update_ui():
	if GlobalSettings.auto_grab:
		bat.grab_item()

func _physics_process(_delta):
	update_ui()

func _unhandled_input(evt:InputEvent):
	if evt.is_action_pressed("load_state"):
		ManageGame.load_state()
