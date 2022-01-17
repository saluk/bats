extends CollisionShape2D

var area:Area2D
var top:Sprite

func _ready():
	area = get_parent()
	top = area.get_parent()
	shape.extents.x = (top.scale.x * top.texture.get_width()) / 2
	shape.extents.y = (top.scale.y * top.texture.get_height()) / 2
