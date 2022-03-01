extends Node2D

var tracked_variables = {
	
}
var texts = []
var dirty = true

class Line extends Reference:
	var l_type = ""
	var l_name = ""
	var l_value = ""
	var l_time = 0
	var l_pos = Vector2.ZERO
	var timeout = null
	func _init(type, name, value, time):
		l_type = type
		l_name = name
		l_value = value
		l_time = time
		
func timeout_lines():
	for key in tracked_variables.keys():
		if tracked_variables[key].timeout and Engine.get_frames_drawn() > tracked_variables[key].timeout:
			tracked_variables.erase(key)

func _process(_delta):
	if dirty:
		write_text()
		dirty = false
	timeout_lines()
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
		ar.append([name, tracked_variables[name]])
	ar.sort_custom(self, "sort_by_time")
	for val in ar:
		var name = val[0]
		v = val[1]
		s += name + ":" + str(v.l_value) + "\n"
	get_tree().get_nodes_in_group("debug_logger")[0].get_node("Control/Label").text = s
	
func _draw():
	var v
	for name in tracked_variables:
		v = tracked_variables[name]
		if v.l_type == "vector":
			draw_line(
				v.l_value[0],
				v.l_value[1],
				Color.red,
				1.0,
				true
			)

func log_variable(name, value, timeout = 0.1):
	tracked_variables[name] = Line.new("string", name, value, Engine.get_frames_drawn())
	if timeout:
		tracked_variables[name].timeout = Engine.get_frames_drawn()+timeout/0.02
	dirty = true
	
func log_increment(name):
	if not name in tracked_variables:
		tracked_variables[name] = Line.new("string", name, "0", Engine.get_frames_drawn())
	tracked_variables[name].l_value = str(int(tracked_variables[name].value)+1)
	dirty = true

func show_line(name, start_end_array):
	tracked_variables[name] = Line.new("vector", name, start_end_array, Engine.get_frames_drawn())

func show_at(name, value, pos):
	# Not yet implemented
	tracked_variables[name] = Line.new("pos", name, value, Engine.get_frames_drawn())
	tracked_variables[name].l_pos = pos
