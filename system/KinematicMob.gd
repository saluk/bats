extends KinematicBody2D
class_name KinematicMob

export var mob_id:String = ""

func _ready():
	ManageGame.ensure_node(self, "res://system/InitMob.gd")
	ManageGame.check_deleted(self)
