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

func write_text():
	if GlobalSettings.show_debug:
		get_tree().get_nodes_in_group("debug_logger")[0].get_node("Control/Label").visible = true
	var s = ""
	var v
	for name in tracked_variables:
		v = tracked_variables[name]
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
	tracked_variables[name] = [value, "string"]
	dirty = true

func show_line(name, start_end_array):
	tracked_variables[name] = [start_end_array, "vector"]

func show_at(name, value, pos):
	# Not yet implemented
	tracked_variables[name] = [value, "pos", pos]
