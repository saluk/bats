extends Node2D

export var dialog_tag = ""

var enabled = true

var area_node = null

func _ready():
	area_node = find_node("Area2D")
	if area_node:
		area_node.connect("body_entered", self, "trigger_dialog")

func trigger_dialog(body):
	Dialog.play_dialog(dialog_tag, "many")
