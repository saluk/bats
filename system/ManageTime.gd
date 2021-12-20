extends Node

signal process_tick_1(delta)
signal process_tick_2(delta)
signal process_tick_3(delta)
signal process_tick_4(delta)
signal process_tick_5(delta)
signal process_tick_6(delta)
signal process_tick_7(delta)
signal process_tick_8(delta)
signal process_tick_9(delta)

export var time_scales_definition = {}
var time_scales = {}

var free_signals = [
	'process_tick_1',
	'process_tick_2',
	'process_tick_3',
	'process_tick_4',
	'process_tick_5',
	'process_tick_6',
	'process_tick_7',
	'process_tick_8',
	'process_tick_9'
]

func _ready():
	for key in time_scales_definition:
		var s = free_signals[0]
		free_signals.remove(0)
		time_scales[key] = {
			'scale': time_scales_definition[key],
			'signal': s,
			'paused': false
		}
	print(time_scales_definition)

func attach_node(node, time_scale_name):
	if not time_scale_name in time_scales:
		push_error(time_scale_name + " is not a defined time scale in scene ManageTime")
	var _c = connect(time_scales[time_scale_name]['signal'], node, '_tick')

func _physics_process(delta):
	for time_scale_name in time_scales:
		var ts = time_scales[time_scale_name]
		if not ts['paused']:
			emit_signal(ts['signal'], delta*ts['scale'])
