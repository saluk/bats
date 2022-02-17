extends Node2D

var tracked_variables = {
	
}
var texts = []
var dirty = true

func _process(_delta):
	if dirty:
		write_text()
		dirty = false
	update()

func sort_custom(a, b):
	if a[2] < b[2]:
		return true
	return false
	
func write_text():
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
		s += name + ":" + str(v[0]) + "\n"
	get_tree().get_nodes_in_group("debug_logger")[0].get_node("Control/Label").text = s
	
func _draw():
	var v
	for name in tracked_variables:
		v = tracked_variables[name]
		if v[1] == "vector":
			draw_line(
				v[0][0],
				v[0][1],
				Color.red,
				1.0,
				true
			)

func log_variable(name, value):
	tracked_variables[name] = [value, "string", Engine.get_frames_drawn()]
	dirty = true
	
func log_increment(name):
	if not name in tracked_variables:
		tracked_variables[name] = ["0", "string", Engine.get_frames_drawn()]
	tracked_variables[name][0] = str(int(tracked_variables[name][0])+1)
	dirty = true

func show_line(name, start_end_array):
	tracked_variables[name] = [start_end_array, "vector", Engine.get_frames_drawn()]

func show_at(name, value, pos):
	# Not yet implemented
	tracked_variables[name] = [value, "pos", pos]
