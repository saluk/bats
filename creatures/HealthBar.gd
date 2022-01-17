extends Node2D

var creature

export var shields = [
	{"start_arc":0, "arc":360, "max_health":2, "health": 0},
	{"start_arc":320, "arc":80, "max_health":2, "health": 0},
	{"start_arc":140, "arc":80, "max_health":2, "health": 0},
	]

export var start_radius = 15
export var next_radius = 5
var point_count = 16
export var width = 2

func _ready():
	creature = get_parent()
	
func get_color(shield):
	var percent = float(shield['health']) / shield['max_health']
	var ramp:Gradient = load("res://creatures/healthbar_colors.tres")
	print(shield, " percent ", percent, " ramp ", ramp.interpolate(percent))
	return ramp.interpolate(percent)
	
func shield_take_damage(shield, amount, angle):
	print("take damage ", shield, " amount ", amount, " angle ", angle)
	if angle >= shield["start_arc"] and angle <= shield["start_arc"] + shield["arc"]:
		if shield["health"] > 0:
			shield["health"] -= amount
			print(shield["health"])
			if shield["health"] < 0:
				shield["health"] = 0
			return true
	
func do_damage(amount, direction:Vector2):
	var angle = rad2deg(direction.angle())
	if angle < 0:
		angle += 360
	for i in range(shields.size()):
		var shield = shields[shields.size()-i-1]
		var effect = shield_take_damage(shield, amount, angle)
		if effect:
			update()
			return
	creature.die()
	
func heal(amount):
	for i in range(shields.size()):
		var shield = shields[shields.size()-i-1]
		if shield["health"] >= shield["max_health"]:
			continue
		shield["health"] += amount
		if shield["health"] > shield["max_health"]:
			amount = shield["max_health"] - shield["health"]
			shield["health"] = shield["max_health"]
			continue
		update()
		return

func _draw():
	var level = 0
	var arc = 0
	
	for shield in shields:
		print("level:",level," arc:",arc)
		if shield["health"] > 0:
			draw_arc(
				position, 
				start_radius + level * next_radius, 
				deg2rad(shield["start_arc"]), 
				deg2rad(shield["start_arc"]+shield["arc"]), 
				point_count, 
				get_color(shield), 
				width, 
				true
			)
		arc += shield["arc"]
		if arc >= 360:
			arc = 0
			level += 1
