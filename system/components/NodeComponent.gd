extends Node
class_name NodeComponent, "res://system/components/icon.svg"

var base_node:Node

func _ready():
	load("res://system/components/ComponentBase.gd").component_ready(self)
