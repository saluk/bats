extends KinematicBody2D
class_name Creature

# States
var alive = true

# Parameters
export var gravity = 300
export var drag = {"x": 10, "y": null}

var move = Vector2(0,0)
var impulses = {}  # Each type of impulse and its vector
# {
# 	impulse_name: {
#		type:
#			|"add" - adds the vector to the move vector
#			|"lerp" - lerps the move vector toward this
#		x: x value of the impulse, null to ignore the axis
#		y: y value of the impulse, null to ignore the axis
#		speedx: speed of lerp
#		speedy
#   }
# }

# References
var animation:CreatureAnimation

var last_collision = {"type":"", "collision": null, "side": "", "ground": ""}

func _ready():
	animation = CreatureAnimation.new(get_node("AnimatedSprite"))
	
func _add_impulse(impulse, delta):
	move += Vector2(impulse["x"]*delta, impulse["y"]*delta)
func _lerp_impulse(impulse, delta):
	if impulse["x"]!=null and impulse["speedx"]!=null:
		move.x = Util.int_toward(move.x, impulse["x"], impulse["speedx"] * delta)
	if impulse["y"]!=null and impulse["speedy"]!=null:
		move.y = Util.int_toward(move.y, impulse["y"], impulse["speedy"] * delta)
		
func initialize_physics():
	impulses = {
		"gravity": {
			"type": "add", "x": 0, "y": gravity
		},
		"drag": {
			"type": "lerp", "x": 0, "y": 0, 
			"speedx": drag["x"], "speedy": drag["y"]
		}
	}
	
func record_last_collision(xcol:KinematicCollision2D, ycol:KinematicCollision2D):
	last_collision = {"type":"", "collision": null, "side": "", "ground": ""}
	var col
	if xcol or ycol:
		if xcol and move.x < 0 and xcol.normal.x > 0:
			last_collision["side"] = "left"
			move.x = 0
			col = xcol
		if xcol and move.x > 0 and xcol.normal.x < 0:
			last_collision["side"] = "right"
			move.x = 0
			col = xcol
		if ycol and move.y < 0 and ycol.normal.y > 0:
			move.y = 0
			last_collision["ground"] = "ceiling"
			col = ycol
		if ycol and move.y > 0 and ycol.normal.y < 0:
			move.y = 0
			last_collision["ground"] = "floor"
			col = ycol
		last_collision["type"] = "unknown"
		if col:
			last_collision["collision"] = col
			if col.collider is TileMap:
				last_collision["type"] = "terrain"
			if col.collider.get_class() == "Creature":
				last_collision["type"] = "creature"
			
func integrate_physics(delta):
	for impulse in impulses.values():
		call("_"+impulse["type"]+"_impulse", impulse, delta)
	for n in get_children():
		if n.has_method("physics"):
			n.physics(delta)
	var xcol = self.move_and_collide(Vector2(move.x*delta,0))
	var ycol = self.move_and_collide(Vector2(0,move.y*delta))
	record_last_collision(xcol, ycol)
	initialize_physics()

func _physics_process(delta):
	integrate_physics(delta)

func do_damage(amount, direction):
	if not alive:
		return
	if $HealthBar:
		$HealthBar.do_damage(amount, direction)
	else:
		die()
		
func die():
	alive = false
	animation.play("death")
	emit_signal("is_dead")
	# Turn off collision with projectiles
	set_collision_layer_bit(4, false)
