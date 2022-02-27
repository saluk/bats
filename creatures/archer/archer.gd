extends Creature
class_name Archer

### Operation variables ###
#var move = Vector2(0, 0)
var toss_vector = move
#var alive = true

### Constants/Parameters ###
var xlimit = 100
var ylimit = 250
var jump_width = 50
var jump_height = 50
#var gravity = 300
var flapping = 200
#var drag = 20

### References ###
var holding:Node2D = null
var pickups = []

var attack_collision:Area2D = null

### Signals ###
signal stunned

func _ready():
	if has_node("AttackCollision"):
		attack_collision = get_node("AttackCollision")
	if attack_collision:
		var _a = attack_collision.connect("body_entered", self, "attack_collide")
	._ready()

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
func get_charge_anim():
	var anim = ""
	for node in get_children():
		if "charge_state" in node:
			if node.charge_state == node.ReleaseCharge and not anim:
				anim = "attack"
			elif node.charge_state == node.Charging and not anim:
				anim = "prepare_charge"
	return anim

func choose_animation():
	if not alive:
		return
	if $AnimatedSprite.animation in ["shoot_high", "shoot_low", "shoot_med"]:
		if $AnimatedSprite.frame < 5:
			return
	var charge_anim = get_charge_anim()
	if charge_anim:
		$AnimatedSprite.play(charge_anim)
	elif abs(move.x)>0.5 or move.y<0:
		$AnimatedSprite.play("walk")
	else:
		$AnimatedSprite.play("idle")
		
func walk_left():
	$AnimatedSprite.flip_h = true
	
func walk_right():
	$AnimatedSprite.flip_h = false
		
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
	
func apply_gravity(delta):
	move.y += gravity * delta

func _physics_process(delta):
	#slow down horizontal movement
	if move.x < 0:
		move.x += drag["x"]*delta
	if move.x > 0:
		move.x -= drag["x"]*delta
	choose_animation()
	toss_vector = Vector2(move.x * 2, move.y * 3)
	for n in get_children():
		if n.has_method("physics"):
			n.physics(delta)
	apply_gravity(delta)
	limit_movement()
	var xcol = self.move_and_collide(Vector2(move.x*delta,0))
	var ycol = self.move_and_collide(Vector2(0,move.y*delta))
	record_last_collision(xcol, ycol)


# Signals and reactions

func do_damage(amount, direction):
	if alive:
		$HealthBar.do_damage(amount, direction)
		
func do_stun():
	emit_signal("stunned")
	
func die():
	ManageGame.set_deleted(self)
	alive = false
	$AnimatedSprite.play("death")
	toss_vector = Vector2()
	pickups = []
	drop_item()
	emit_signal("is_dead")
	# Turn off collision with projectiles
	set_collision_layer_bit(4, false)
	get_node("Star").visible = false
	
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

func attack_collide(body:FlyingCreature):
	if not alive:
		return
	if not body:
		return
	if body.alive:
		move = body.position.direction_to(position) * 100
		if body.global_position.y > global_position.y:
			body.do_damage(5, global_position-body.position)
