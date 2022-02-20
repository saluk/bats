extends Area2D

export var start_scale = 1
export var end_scale = 2

var ttl = 3.0
var life = 0.0
var move = 0
var moved = 0  #How far we have fallen

onready var shape2d = get_node("CollisionShape2D")

func do_damage(node:Node2D):
	if node.is_in_group("can_burn"):
		print("damaging", node)
