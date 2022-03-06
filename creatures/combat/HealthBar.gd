extends Node2D
class_name HealthBar

var creature

export var offset_x = 16

export var health_max = 3
var health 

export var dot_size = 5

func _ready():
	creature = get_parent()
	health = health_max
	update()
	
func do_damage(source):
	var amount = source.amount
	print(health, '-=', amount)
	if health > 0:
		health -= amount
	if health <= 0:
		health = 0
		creature.die()
	update()
	
func heal(amount):
	health += amount
	if health >= health_max:
		health = health_max

func _draw():
	print("drawing")
	if health <= 0:
		visible = false
	var _level = 0
	var _arc = 0
	var remaining_good_health = health
	var y = 0
	var x = offset_x
	for _i in range(health_max):
		var color = Color.antiquewhite if remaining_good_health > 0 else Color.brown
		var outline_color = Color.brown
		draw_circle(Vector2(x,y), dot_size/2, outline_color)
		draw_circle(Vector2(x,y), dot_size/2-0.5, color)
		y -= dot_size+1
		remaining_good_health -= 1
