extends SMState

export var rush_time := 1.0
export var rush_speed = 100
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
	}
}

# TODO more rush specific adjustments
func flap(_xdir):
	if not bat.alive:
		return
	var state = machine.get_state_by_name("Flying")
	machine.apply_state(state)
	state.flap(_xdir)
	return

func rush_attack():
	if not bat.alive: return
	# Lame movement if you can't rush yet
	if not bat.rush_attack_cooldown.start():
		bat.move.x = xdir*rush_speed * 0.5
		bat.move.y = rush_speed * 0.5
		return
	bat.charge.clear_charges()
	bat.set_flip(xdir)
	bat.move.x = xdir*rush_speed
	bat.move.y = rush_speed
	bat.attack_collision.damage = bat.attack_damage
	bat.attack_collision.enabled = true
	bat.attack_collision.enabled_time = rush_time

func can_switch():
	return false

func make_active():
	machine.apply_inputs(inputs)
	machine.state_time = rush_time
	rush_attack()
	
func process(_delta):
	pass

func exit():
	pass
