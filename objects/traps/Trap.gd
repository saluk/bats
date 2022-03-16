extends Node2D

export var damage = 1
export var damage_type = 'trap'

var enabled = true

var mover_node = null
var area_node = null
var animated_node = null

func _ready():
	mover_node = find_node("Mover")
	area_node = find_node("Area2D")
	animated_node = find_node("AnimatedSprite")
	if area_node:
		area_node.connect("body_entered", self, "trap")
	elif mover_node:
		mover_node.connect("body_entered", self, "trap")

func trap(_body):
	if animated_node and animated_node.has_method("explode"):
		animated_node.explode()
	if mover_node:
		mover_node.speed = 0
