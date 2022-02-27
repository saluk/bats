extends Creature
class_name FlyingCreature

### Operation variables ###
#var move = Vector2(0, 0)
var toss_vector = move


### Constants/Parameters ###
var xlimit = 200
var ylimit = 350
var jump_width = 75
var jump_height = 50
var stop_hover_time = 1   #How long with no input do we disable hover force
var fly_time = 1		  #If we are receiving input how long do we enable hover force
#var gravity = 300
var flapping = 170 		  #flapping force
var is_flapping = true
var last_flap = 0
var charge_flap_force = 100
var xdrag = 10
var bounce_height = 75  # Force to apply when bouncing from an attack

### References ###
var holding:Node2D = null
var pickups = []

var near_rafter = null
var rafter_gravity = 0.0
var rafter_heal_rate = 0.5 # seconds per shield health point
var next_rafter_heal = 0.5

var attack_collision:Area2D = null
var attack_damage = 1

### Signals ###
signal stunned

func _ready():
	attack_collision = get_node("AttackCollision")
	var _a = attack_collision.connect("body_entered", self, "attack_collide")
	
	animation.offsets["death"] = Vector2(0, -6)
	
# Body functions

func set_flip(x):
	if get_node("LeftCharge").charge_state == get_node("LeftCharge").Charging:
		x = -1
	elif get_node("RightCharge").charge_state == get_node("RightCharge").Charging:
		x = 1
	animation.set_flipx(x)

func flap(x_dir):
	if not alive:
		return
	last_flap = 0
	is_flapping = true
	set_flip(x_dir)
	if rafter_gravity > 0:
		rafter_gravity = -1
		return
	move.x += jump_width * x_dir
	if move.y > 0:
		move.y = move.y * 0.2
	move.y -= jump_height

func flap_left():
	flap(-1)
	
func flap_right():
	flap(1)
	
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
				if node.name == "LeftCharge":
					return -1
				else:
					return 1
	return 0
	
func charge_state():
	for node in get_children():
		if "charge_state" in node:
			if node.charge_level >= node.charge_time:
				return true
	return false
				
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
	DebugLogger.log_variable("animation", animation.get_playing())
	if not alive:
		animation.animatedSprite.rotation_degrees = 0
		return
	var charge_anim = get_charge_anim()
	var emitting = false
	if charge_anim:
		animation.play(charge_anim)
		if charge_anim == "attack":
			emitting = true
	elif near_rafter:
		animation.play("land")
		animation.animatedSprite.rotation_degrees = min(rafter_gravity*8 * 180, 180)
		animation.animatedSprite.position.y = min(abs(rafter_gravity) * 20, 6)
	elif last_collision.bottom:
		animation.play("land")
	elif abs(move.x)>0.5 or move.y<0 and is_flapping:
		animation.play("fly")
	else:
		animation.play("land")
	if not near_rafter:
		animation.animatedSprite.rotation_degrees = 0
		animation.animatedSprite.position.y = 0
	$firetrail/Particles2D.emitting = emitting
		
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
	if is_flapping:
		move.y -= flapping * delta
		last_flap += delta
		if last_flap > stop_hover_time:
			is_flapping = false
	
func apply_charge_flapping(delta):
	if is_charging():
		move.y -= charge_flap_force * delta
	
func apply_gravity(delta):
	if move.y < 0:
		move.y += gravity * 0.8 * delta
	else:
		move.y += gravity * delta

func integrate_physics(delta):
	last_collision.ownername = name
	#slow down horizontal movement
	if move.x < 0:
		move.x += xdrag*delta
	if move.x > 0:
		move.x -= xdrag*delta
	#slow down direction intent
	choose_animation()
	toss_vector = Vector2(move.x * 2, move.y * 3)
	for n in get_children():
		if n.has_method("physics"):
			n.physics(delta)
	apply_gravity(delta)
	apply_flapping(delta)
	apply_charge_flapping(delta)
	limit_movement()
	#DebugLogger.show_line("bat_move", [global_position, global_position+move])
	last_collision.clear()
	var xcol = self.move_and_collide(Vector2(move.x*delta,0))
	record_last_collision(xcol, null)
	var ycol = self.move_and_collide(Vector2(0,move.y*delta))
	record_last_collision(null, ycol)


# Signals and reactions

func do_damage(amount, direction):
	if not alive:
		return
	if $HealthBar:
		$HealthBar.do_damage(amount, direction)
	else:
		die()
		
func do_stun():
	emit_signal("stunned")
	
func die():
	alive = false
	animation.play("death")
	toss_vector = Vector2()
	pickups = []
	drop_item()
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
		if body.global_position.y > global_position.y + 5:
			body.do_damage(attack_damage, Vector2(1,0))
