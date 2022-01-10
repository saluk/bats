extends CollisionShape2D

var area:Area2D
var color_rect:ColorRect

func _ready():
	area = get_parent()
	color_rect = area.get_parent()
	var _shape:RectangleShape2D = self.shape
	_shape.extents.x = color_rect.rect_size.x/2
	_shape.extents.y = color_rect.rect_size.y/2
	area.position = color_rect.rect_position + color_rect.rect_size / 2
