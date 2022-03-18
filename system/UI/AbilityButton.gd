extends Button

var ability_scene:Node

#Node that we add our subinterfaces to
export(NodePath) onready var sub_interface = get_node(sub_interface) as Node

func _ready():
	var _a = connect("button_up", self, "_click")

func _click():
	if ability_scene:
		#ability_scene.close()
		ability_scene.queue_free()
		ability_scene = null
		yield(get_tree().create_timer(0.25), "timeout")
		Dialog.unpause_gameplay()
	else:
		ability_scene = load("res://system/UI/Abilities.tscn").instance() as AbilityScreen
		var player = get_tree().get_nodes_in_group("player")[0] as FlyingCreature
		sub_interface.add_child(ability_scene)
		# TODO - we should make pausing for an interface something separate from dialog
		Dialog.pause_gameplay()
