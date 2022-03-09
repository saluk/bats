extends Area2D
class_name Area2DComponent, "res://system/components/icon.svg"

var base_node:Node

func _ready():
	load("res://system/components/ComponentBase.gd").component_ready(self)
