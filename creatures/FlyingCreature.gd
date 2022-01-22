extends KinematicBody2D
class_name FlyingCreature

### Operation variables ###
var move = Vector2(0, 0)
var toss_vector = move
var alive = true


### Constants/Parameters ###
var xlimit = 200
var ylimit = 250
var jump_width = 50
var jump_height = 50
var gravity = 300
var flapping = 170
var charge_flap_force = 100
var xdrag = 10
var bounce_height = 75  # Force to apply when bouncing from an attack

### References ###
var holding:Node2D = null
var pickups = []
var last_collision_type = ""
var last_collision_side = ""
var last_collision_ground = ""
var last_collision:KinematicCollision2D = null

var near_rafter = null
var rafter_gravity = 0.0
var rafter_heal_rate = 0.5 # seconds per shield health point
var next_rafter_heal = 0.5

var attack_collision:Area2D = null

### Signals ###
signal is_dead
signal stunned

func _ready():
	attack_collision = get_node("AttackCollision")
	var _a = attack_collision.connect("body_entered", self, "attack_collide")
	
# Body functions

func set_flip(x):
	if get_node("LeftCharge").charge_state == get_node("LeftCharge").Charging:
		x = -1
	elif get_node("RightCharge").charge_state == get_node("RightCharge").Charging:
		x = 1
	if x > 0:
		$AnimatedSprite.flip_h = true
	elif x < 0:
		$AnimatedSprite.flip_h = false

func flap(x_dir):
	if not alive:
		return
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
	if not alive:
		return
	var charge_anim = get_charge_anim()
	if charge_anim:
		$AnimatedSprite.play(charge_anim)
	elif near_rafter:
		$AnimatedSprite.play("land")
		$AnimatedSprite.rotation_degrees = min(rafter_gravity*8 * 180, 180)
		$AnimatedSprite.position.y = min(abs(rafter_gravity) * 20, 6)
	elif last_collision_ground == "floor":
		$AnimatedSprite.play("land")
	elif abs(move.x)>0.5 or move.y<0:
		$AnimatedSprite.play("fly")
	else:
		$AnimatedSprite.play("idle")
	if not near_rafter:
		$AnimatedSprite.rotation_degrees = 0
		$AnimatedSprite.position.y = 0
		
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
	if move.y < 0:
		move.y += gravity * 0.8 * delta
	else:
		move.y += gravity * delta

func _physics_process(delta):
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
	check_for_rafters(delta)
	DebugLogger.show_line("bat_move", [global_position, global_position+move])
	var col = self.move_and_collide(move*delta)
	last_collision_type = ""
	last_collision = col
	last_collision_side = ""
	last_collision_ground = ""
	if col:
		if move.x < 0 and col.normal.x > 0:
			last_collision_side = "left"
			move.x = 0
		if move.x > 0 and col.normal.x < 0:
			last_collision_side = "right"
			move.x = 0
		if move.y < 0 and col.normal.y > 0:
			move.y = 0
			last_collision_ground = "ceiling"
		if move.y > 0 and col.normal.y < 0:
			move.y = 0
			last_collision_ground = "floor"
		last_collision_type = "unknown"
		if col.collider is TileMap:
			last_collision_type = "terrain"
		if col.collider.get_class() == self.get_class():
			last_collision_type = "creature"


# Signals and reactions

func do_damage(amount, direction):
	if not alive:
		return
	$HealthBar.do_damage(amount, direction)
		
func do_stun():
	emit_signal("stunned")
	
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
	
func check_for_rafters(delta):
	if not near_rafter:
		rafter_gravity = 0
		next_rafter_heal = rafter_heal_rate
	near_rafter = null
	if charge_state() or not alive:
		return
	for node in get_node("Perch").get_overlapping_bodies():
		if node.is_in_group("rafter"):
			near_rafter = node
	DebugLogger.log_variable("rafter_gravity", rafter_gravity)
	if near_rafter:
		if rafter_gravity < 1:
			rafter_gravity += delta
			if rafter_gravity >= 1:
				ManageGame.save_state()
		var diff = (near_rafter.global_position - global_position) * 20
		diff.y = -abs(diff.y)
		move += Vector2(0, -abs(diff.y) * max(rafter_gravity, 0))
		move.x = move.x * 0.8
		if rafter_gravity >= 1:
			heal_from_rafters(delta)
	elif rafter_gravity > 1:
		rafter_gravity -= delta

func heal_from_rafters(delta):
	next_rafter_heal -= delta
	if next_rafter_heal <= 0:
		next_rafter_heal = rafter_heal_rate
		$HealthBar.heal(1)

func attack_collide(body:KinematicBody2D):
	if not alive:
		return
	if not body:
		return
	if "alive" in body and body.alive:
		move = body.position.direction_to(position) * bounce_height
		if body.global_position.y > global_position.y:
			body.do_damage(5)
