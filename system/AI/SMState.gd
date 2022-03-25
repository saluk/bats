extends NodeComponent
class_name SMState

export var enabled = true

var machine
var memory = {}

func can_switch():
	return true
	
func make_active():
	pass
	
func process(_delta):
	pass

func exit():
	pass
