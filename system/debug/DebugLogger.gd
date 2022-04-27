extends Node2D

var tracked_variables = {
	
}
var texts = []
var dirty = true

class LogVariable extends Reference:
	var l_type = ""
	var l_name = ""
	var l_value = ""
	var l_time = 0
	var l_pos = Vector2.ZERO
	var l_node = null
	var timeout:float = -1  # in seconds, less than zero is infinite
	func _init(type, name, value, time):
		l_type = type
		l_name = name
		l_value = value
		l_time = time
		
func timeout_lines():
	for key in tracked_variables.keys():
		if tracked_variables[key].timeout >= 0 and (Engine.get_frames_drawn() - tracked_variables[key].l_time) * 0.02 > tracked_variables[key].timeout:
			if tracked_variables[key].l_node:
				tracked_variables[key].l_node.queue_free()
			tracked_variables.erase(key)

func _physics_process(_delta):
	timeout_lines()
	if dirty:
		write_text()
		dirty = false
	update()

func sort_custom(a, b):
	if a[2] < b[2]:
		return true
	return false
	
func write_text():
	if not get_tree().get_nodes_in_group("debug_logger"):
		return
	if GlobalSettings.show_debug:
		get_tree().get_nodes_in_group("debug_logger")[0].get_node("Control/Label").visible = true
	var s = ""
	var v
	var ar = []
	for name in tracked_variables:
		v = tracked_variables[name]
		if v.l_type == 'string':
			ar.append([name, v])
		elif v.l_type == "pos":
			if not v.l_node or not Util.valid_object(v.l_node):
				v.l_node = Label.new()
				get_tree().get_nodes_in_group("debug_position_control")[0].add_child(v.l_node)
				print("create shown at label node ", Engine.get_frames_drawn())
			v.l_node.set_global_position(v.l_pos)
			v.l_node.text = str(v.l_value)
	ar.sort_custom(self, "sort_by_time")
	for val in ar:
		var name = val[0]
		v = val[1]
		s += name + ":" + str(v.l_value) + "\n"
	get_tree().get_nodes_in_group("debug_logger")[0].get_node("Control/Label").text = s
	
func _draw():
	var v
	for name in tracked_variables:
		v = tracked_variables[name] as LogVariable
		if v.l_type == "vector":
			draw_line(
				v.l_value[0],
				v.l_value[1],
				Color(rand_range(0.0,1.0),rand_range(0.0,1.0),rand_range(0.0,1.0)),
				1.0,
				true
			)

func log_variable(name, value, timeout = 0.1):
	tracked_variables[name] = LogVariable.new("string", name, value, Engine.get_frames_drawn())
	if timeout:
		tracked_variables[name].timeout = timeout
	dirty = true
	
func log_increment(name):
	if not name in tracked_variables:
		tracked_variables[name] = LogVariable.new("string", name, "0", Engine.get_frames_drawn())
	tracked_variables[name].l_value = str(int(tracked_variables[name].l_value)+1)
	dirty = true

func show_line(name, start_end_array, timeout=0.1):
	tracked_variables[name] = LogVariable.new("vector", name, start_end_array, Engine.get_frames_drawn())
	tracked_variables[name].timeout = timeout
	dirty = true

func show_at(name, value, pos, timeout=0.1):
	if not name in tracked_variables:
		tracked_variables[name] = LogVariable.new("pos", name, value, Engine.get_frames_drawn())
	tracked_variables[name].timeout = timeout
	tracked_variables[name].l_pos = pos
	tracked_variables[name].l_value = value
	tracked_variables[name].l_time = Engine.get_frames_drawn()
	dirty = true
