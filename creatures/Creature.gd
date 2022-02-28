extends KinematicMob
class_name Creature

# States
var alive = true
var collision_type = "creature"

# Parameters
export var animated_sprite_name = "AnimatedSprite"
export var gravity = 300
export var drag = {"x": 10, "y": null}
export var zero_horizontal = true
export var zero_vertical = true

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

# Signals
signal is_dead

class CollisionInfo extends Reference:
	var type = ""
	var collision:KinematicCollision2D = null

class CollisionRecord extends Reference:
	var ownername
	var left:CollisionInfo = null
	var right:CollisionInfo = null
	var top:CollisionInfo = null
	var bottom:CollisionInfo = null
	func clear():
		left = null
		right = null
		top = null
		bottom = null

var collision_buffer = []
var last_collision:CollisionRecord = CollisionRecord.new()

func _ready():
	animation = CreatureAnimation.new(get_node(animated_sprite_name))
	
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
	
func assign_collision(collision:KinematicCollision2D):
	var collision_info = CollisionInfo.new()
	collision_info.collision = collision
	collision_info.type = (collision.collider.collision_type 
		if "collision_type" in collision.collider 
		else "terrain")
	return collision_info
	
func record_last_collision(
		xcol:KinematicCollision2D, 
		ycol:KinematicCollision2D):
	# Must be called before modifying move to have accurate results
	if xcol and xcol.normal.x != 0:
		if move.x < 0:
			last_collision.left = assign_collision(xcol)
		elif move.x > 0:
			last_collision.right = assign_collision(xcol)
		if zero_horizontal:
			move.x = 0
	# TODO We used to use ycol.remainder here, but sometimes it was zero
	if ycol and ycol.normal.y != 0:
		if move.y < 0:
			last_collision.top = assign_collision(ycol)
		elif move.y > 0:
			last_collision.bottom = assign_collision(ycol)
		if zero_vertical:
			move.y = 0
			
func integrate_physics(delta):
	last_collision.clear()
	for impulse in impulses.values():
		call("_"+impulse["type"]+"_impulse", impulse, delta)
	for n in get_children():
		if n.has_method("physics"):
			n.physics(delta)
	var _old_pos = Vector2(position.x, position.y)
	var xcol = move_and_collide(Vector2(move.x*delta,0))
	record_last_collision(xcol, null)
	var ycol = move_and_collide(Vector2(0,move.y*delta))
	record_last_collision(null, ycol)
	initialize_physics()

func _physics_process(delta):
	integrate_physics(delta)

func do_damage(amount, direction):
	if not alive:
		return
	if has_node("HealthBar"):
		$HealthBar.do_damage(amount, direction)
	else:
		die()
		
func die():
	ManageGame.set_deleted(self)
	alive = false
	animation.play("death")
	emit_signal("is_dead")
	# Turn off collision with projectiles
	set_collision_layer_bit(4, false)
