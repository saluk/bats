extends NodeComponent
class_name StateMachine

var current_state  # Should be an SMState
var state_time = 0
var delta

func _physics_process(_delta):
	delta = _delta
	update_brain()

func apply_state(s):
	if current_state:
		current_state.exit()
	s.make_active()
	#DebugLogger.log_variable(name+str(get_instance_id())+'.state = ',s.name)
	current_state = s
		
func switch_to_state_if_possible(new_state):
	new_state.machine = self
	if new_state.can_switch():
		if new_state != current_state:
			apply_state(new_state)
		return current_state
	return null
	
func get_state_by_name(state_name):
	for state in get_children():
		if state.name == state_name:
			return state
	return null

func new_state():
	for state in get_children():
		if switch_to_state_if_possible(state):
			return
			
func update_brain():
	if current_state:
		state_time -= self.delta
		if state_time <= 0:
			new_state()
		current_state.process(self.delta)
	else:
		new_state()
	DebugLogger.show_at(base_node.name + "." + name + ".state", current_state.name, base_node.global_position)
