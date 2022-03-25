extends SMState

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
	'attack_left': {
		'action': 'ui_left',
		'method': 'double',
		'self': self,
		'func_name': 'rush_attack',
		'args': [-1]
	},
	'attack_right': {
		'action': 'ui_right',
		'method': 'double',
		'self': self,
		'func_name': 'rush_attack',
		'args': [1]
	},
	'charge_left': {
		'action': 'ui_left',
		'method': 'holding',
		'self': self,
		'func_name': 'begin_charge',
		'args': [-1]
	},
	'charge_right': {
		'action': 'ui_right',
		'method': 'holding',
		'self': self,
		'func_name': 'begin_charge',
		'args': [1]
	}
}
	
func make_active():
	machine.apply_inputs(inputs)
	
func apply_idle_flapping(delta):
	if not bat.alive: return
	if bat.is_flapping:
		bat.move.y -= bat.flapping * delta
		bat.last_flap += delta
		if bat.last_flap > bat.stop_hover_time:
			bat.is_flapping = false
			
func flap(x_dir):
	if not bat.alive:
		return
	bat.last_flap = 0
	bat.is_flapping = true
	bat.set_flip(x_dir)
	# TODO rafter stuff should be its own state
	if bat.rafter_gravity > 0:
		bat.rafter_gravity = -1
		return
	var adjust_move_x = 0
	var adjust_move_y = 0
	if x_dir > 0 and bat.move.x > 0 or x_dir < 0 and bat.move.x < 0:
		adjust_move_x = bat.width_multiplier * abs(bat.move.x)
	if bat.move.y < 0:
		adjust_move_y = bat.height_multiplier * abs(bat.move.y)
	bat.move.x += (bat.jump_width+adjust_move_x) * x_dir
	if bat.move.y > 0:
		bat.move.y = bat.move.y * 0.2
	bat.move.y -= bat.jump_height + adjust_move_y
	
func rush_attack(xdir):
	var state = machine.get_state_by_name("Rushing")
	state.xdir = xdir
	machine.apply_state(state)
	
func begin_charge(xdir):
	var state = machine.get_state_by_name("Charging")
	state.xdir = xdir
	machine.apply_state(state)
	
func process(delta):
	# Adjust forces based on what player wants
	# If player is not flapping, we should apply some upwards force
	# The root flying creature should already be:
	#    applying gravity
	#    adding dampening
	#    bouncing off of walls
	#    bouncing away from damage
	# If we are near an object - do object stuff
	# If we are near a rafter - switch to hanging
	apply_idle_flapping(delta)
	pass

func exit():
	pass
