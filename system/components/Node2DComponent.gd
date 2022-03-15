extends Node2D
class_name Node2DComponent, "res://system/components/icon.svg"

var base_node:Node
var component:ComponentBase.Component = ComponentBase.Component.new()

func _ready():
	load("res://system/components/ComponentBase.gd").component_ready(self)
