extends KinematicBody2D
class_name FlyingCreature

export var time_scene = 'creatures'

### Operation variables ###
var move = Vector2(0, 0)
var toss_vector = move
var alive = true

### Constants/Parameters ###
var xlimit = 100
var ylimit = 250
var jump_width = 50
var jump_height = 75
var gravity = 300
var flapping = 200
var charge_flap_force = 50
var drag = 20
var bounce_height = 75  # Force to apply when bouncing from an attack

### References ###
var holding:Node2D = null
var pickups = []
var last_collision_type = ""
var last_collision_side = ""
var last_collision:KinematicCollision2D = null

var attack_collision:Area2D = null

### Signals ###
signal is_dead

func _ready():
	ManageTime.attach_node(self, time_scene)
	attack_collision = get_node("AttackCollision")
	var _a = attack_collision.connect("body_entered", self, "attack_collide")
	
# Body functions

func flap_left():
	$AnimatedSprite.flip_h = false
	move.x -= jump_width
	move.y -= jump_height
	
func flap_right():
	$AnimatedSprite.flip_h = true
	move.x += jump_width
	move.y -= jump_height
	
func drop_item():
	if not holding:
		return
	$Holding/Sprite.texture = null
	holding.position = $Dropping.global_position
	get_parent().add_child(holding)
	#holding.move = toss_vector
	holding.apply_central_impulse(toss_vector)
	holding.pickup_time = 1
	holding = null
	
func grab_item():
	if not alive: return
	var source = can_pickup()
	if not source:
		return
	var object = source.pickup_object()
	if not object:
		return false
	holding = object
	pickups.erase(source)
	$Holding.get_child(0).texture = holding.find_node('Sprite').texture
	return true

# State enforcement
func is_charging():
	for node in get_children():
		if "charge_state" in node:
			if node.charge_state == node.Charging:
				return true
				
func is_attacking():
	for node in get_children():
		if "charge_state" in node:
			if node.charge_state == node.ReleaseCharge:
				return true

func get_charge_anim():
	var anim = ""
	if is_charging():
		anim = "prepare_charge"
	elif is_attacking():
		anim = "attack"
	return anim

func choose_animation():
	if not alive:
		return
	var charge_anim = get_charge_anim()
	if charge_anim:
		$AnimatedSprite.play(charge_anim)
	elif abs(move.x)>0.5 or move.y<0:
		$AnimatedSprite.play("fly")
	else:
		$AnimatedSprite.play("idle")
		
func limit_movement():
	if move.x < -xlimit: move.x = -xlimit
	if move.x > xlimit: move.x = xlimit
	if move.y > ylimit: move.y = ylimit
	if move.y < -ylimit: move.y = -ylimit
	
func can_pickup():
	if not holding and pickups:
		for p in pickups:
			if p.has_method("pickup_object"):
				return p
	return null

#Physics functions

func apply_flapping(delta):
	if not alive: return
	move.y -= flapping * delta
	
func apply_charge_flapping(delta):
	if is_charging():
		move.y -= charge_flap_force * delta
	
func apply_gravity(delta):
	move.y += gravity * delta

func _tick(delta):
	#slow down horizontal movement
	if move.x < 0:
		move.x += drag*delta
	if move.x > 0:
		move.x -= drag*delta
	choose_animation()
	toss_vector = Vector2(move.x * 2, move.y * 3)
	for n in get_children():
		if n.has_method("physics"):
			n.physics(delta)
	apply_gravity(delta)
	apply_flapping(delta)
	apply_charge_flapping(delta)
	limit_movement()
	var col = self.move_and_collide(move*delta)
	last_collision_type = ""
	last_collision = col
	last_collision_side = ""
	if col:
		if move.x < 0 and col.normal.x > 0:
			last_collision_side = "left"
			move.x = 0
		if move.x > 0 and col.normal.x < 0:
			last_collision_side = "right"
			move.x = 0
		if move.y < 0 and col.normal.y > 0:
			move.y = 0
		if move.y > 0 and col.normal.y < 0:
			move.y = 0
		last_collision_type = "unknown"
		if col.collider is TileMap:
			last_collision_type = "terrain"
		if col.collider.get_class() == self.get_class():
			last_collision_type = "creature"


# Signals and reactions

func do_damage(_amount):
	if alive:
		die()
	
func die():
	alive = false
	$AnimatedSprite.play("death")
	toss_vector = Vector2()
	pickups = []
	drop_item()
	# TODO - hack
	$AnimatedSprite.position.y = -6
	emit_signal("is_dead")
	# Turn off collision with projectiles
	set_collision_layer_bit(4, false)
	
func add_pickup(object):
	if not alive: return
	if object.has_method("pickup_object"):
		if not object in pickups:
			pickups.append(object)
			
func remove_pickup(object):
	if not alive: return
	if object.has_method("pickup_object"):
		if object in pickups:
			pickups.erase(object)

func _on_Area2D_body_entered(body):
	add_pickup(body)

func _on_Area2D_body_exited(body):
	remove_pickup(body)

func _on_Drop_pressed():
	drop_item()

func _on_Grab_pressed():
	grab_item()

func _on_Area2D_area_entered(area):
	add_pickup(area)

func _on_Area2D_area_exited(area):
	remove_pickup(area)

func attack_collide(body:KinematicBody2D):
	if not alive:
		return
	if not body:
		return
	if "alive" in body and body.alive:
		move = body.position.direction_to(position) * bounce_height
		if body.global_position.y > global_position.y:
			body.do_damage(5)
