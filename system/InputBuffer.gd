extends Node
class_name InputBuffer

var buffer = []
var input_mappings = {}
var input_buffer_seconds = 0.2
var input_buffer_time = 0.0
var single_tap_seconds = 0.15

var ACTION = 0
var STATE = 1
var AGE = 2
var HELD = 3
var TAPPED = 4
var HELD_START = 5

func _init(_input_mappings):
	self.input_mappings = _input_mappings
	var _a = Dialog.connect("resume_from_dialog", self, "clear_buffer")
	
func action_on(action):
	buffer.append([action, 'on', 0, 0, false, false])
	
func action_off(action):
	for i in range(buffer.size()):
		if buffer[i][ACTION] == action and buffer[i][STATE] in ['on', 'held']:
			buffer[i][STATE] = 'off'
			if buffer[i][HELD] > single_tap_seconds:
				apply_event("released", buffer[i][ACTION])
				
func apply_event(method, action):
	if not method in ["holding"]:
		print("event:", method, " ", action, " buffer:", buffer)
	for mapping in input_mappings.values():
		if mapping['method'] == method and mapping['action'] == action:
			mapping['self'].callv(mapping['func_name'], mapping.get('args', []))

# Input
func _unhandled_input(event):
	if event is InputEventMouseButton:
		var click_pos = event.position
		if click_pos.x < ProjectSettings.get_setting("display/window/size/width")/2:
			if event.is_pressed():
				action_on("ui_left")
			else:
				action_off("ui_left")
		else:
			if event.is_pressed():
				action_on("ui_right")
			else:
				action_off("ui_right")
	var actions = {}
	for mapped_action in input_mappings:
		var mapping = input_mappings[mapped_action]
		actions[mapping['action']] = true
	for action in actions:
		if event.is_action(action):
			if event.is_action_pressed(action):
				action_on(action)
			elif event.is_action_released(action):
				action_off(action)
				
func handle_held_event():
	for event in buffer:
		if event[STATE] == 'held':
			if not event[HELD_START]:
				event[HELD_START] = true
				apply_event("held_start", event[ACTION])
			apply_event("holding", event[ACTION])
			
func fire_single_tap():
	for event in buffer:
		if event[STATE] in ['on', 'off'] and event[AGE] > single_tap_seconds and not event[TAPPED]:
			if event[STATE] == 'on':
				event[STATE] = 'held'
			event[TAPPED] = true
			apply_event("tapped", event[ACTION])
			
func pop_double_tap():
	var s = buffer.size()
	if s >= 2 and buffer[s-1][ACTION] == buffer[s-2][ACTION]:
		var action = buffer[s-1][ACTION]
		apply_event("double", action)
		buffer.pop_back()
		buffer.pop_back()
	
				
func process_events():
	pop_double_tap()
	fire_single_tap()
	handle_held_event()
	
func clear_buffer():
	buffer = []

func update_input_buffer(delta):
	var new_arr = []
	process_events()
	for event in buffer:
		event[AGE] += delta
		if event[STATE] in ['on', 'held']:
			event[HELD] += delta
			new_arr.append(event)
		elif event[AGE] < input_buffer_seconds:
			new_arr.append(event)
	buffer = new_arr

func _physics_process(delta):
	update_input_buffer(delta)
