extends Node2D

export var damage = 1

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
	if mover_node:
		mover_node.connect("body_entered", self, "trap")

func trap(body):
	if body.has_method("do_damage"):
		body.do_damage(self.damage)
	if animated_node:
		animated_node.explode()
	if mover_node:
		mover_node.speed = 0
		
func collide_with(col):
	trap(col.collider)