extends SMState

var xdir := 1

onready var bat:FlyingCreature = base_node
onready var inputs = {
	'jump_left': {
		'action': 'ui_left',
		'method': 'tapped',
		'self': self,
		'func_name': 'flap',
		'args': [-1]
	},
	'jump_right': {
		'action': 'ui_right',
		'method': 'tapped',
		'self': self,
		'func_name': 'flap',
		'args': [1]
	},
	'charge_released_left': {
		'action': 'ui_left',
		'method': 'released',
		'self': self,
		'func_name': 'release_charge',
		'args': [-1]
	},
	'charge_released_right': {
		'action': 'ui_right',
		'method': 'released',
		'self': self,
		'func_name': 'release_charge',
		'args': [1]
	}
}

func flap(_xdir):
	pass

func can_switch():
	return false

func make_active():
	machine.state_time = 1
	bat.charge.reset()
	bat.charge.begin_charge(xdir)
	machine.apply_inputs(inputs)
	print("reset")
	
func release_charge(_xdir):
	if xdir != _xdir:
		return
	bat.charge.release_charge(xdir)
	machine.new_state()
	
func process(_delta):
	machine.state_time = 1

func exit():
	pass
