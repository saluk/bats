extends KinematicBody2D
class_name KinematicMob

export var mob_id:String = ""
export var save_props:Array = []

func _ready():
	ManageGame.ensure_node(self, "res://system/InitMob.gd")
	if ManageGame.check_deleted(self):
		return
	ManageGame.load_props(self)
	connect("tree_exited", self, "exit_tree")
	
func exit_tree():
	print(name," exiting")
	ManageGame.set_props(self)
