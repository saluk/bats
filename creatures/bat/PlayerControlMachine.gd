extends StateMachine

onready var player_controller = Nodes.get_class_node(base_node, "BatPlayerController")
func _ready():
	pass

func apply_inputs(input_dict):
	player_controller.input_buffer.input_mappings = input_dict
	pass
