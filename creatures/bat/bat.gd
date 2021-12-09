extends KinematicBody2D

### Operation variables ###
var move = Vector2(0, 0)
var toss_vector = move
var alive = true

### Constants/Parameters ###
var xlimit = 100
var ylimit = 500
var jump_width = 50
var jump_height = 50
var gravity = 300
var flapping = 200

### References ###
var holding:Node2D = null
var pickups = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Body functions
func apply_player_input(func_name, array):
	if not alive: return
	callv(func_name, array)

func flap_left():
	$AnimatedSprite.flip_h = 0
	move.x = -jump_width
	if move.y>0:
		move.y = 0
	move.y -= jump_height
	
func flap_right():
	$AnimatedSprite.flip_h = 1
	move.x = jump_width
	if move.y>0:
		move.y = 0
	move.y -= jump_height
	
func drop_item():
	if not holding:
		return
	$Holding/Sprite.texture = null
	holding.position = $Dropping.global_position
	get_parent().add_child(holding)
	#holding.move = toss_vector
	holding.apply_central_impulse(toss_vector)
	holding.pickup_time = 0.2
	holding = null
	print("set holding to null")
	
func grab_item():
	if not alive: return
	var source = can_pickup()
	if not source:
		return
	var object = source.pickup_object()
	if not object:
		return false
	holding = object
	$Holding.get_child(0).texture = holding.find_node('Sprite').texture
	return true
	
# Input
func _unhandled_input(event):
	if not alive: return
	if event is InputEventMouseButton and event.is_pressed():
		var click_pos = event.position
		
		print(get_viewport().size.x, click_pos.x)
		if click_pos.x < ProjectSettings.get_setting("display/window/size/width")/2:
			flap_left()
		else:
			flap_right()
	elif event.is_action_pressed("ui_left"):
		flap_left()
	elif event.is_action_pressed("ui_right"):
		flap_right()
	elif event.is_action_pressed("ui_down"):
		drop_item()

# State enforcement
func choose_animation():
	if not alive:
		return
	if abs(move.x)>0.5 or move.y<0:
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
	
func update_ui():
	var interact_buttons = get_tree().get_nodes_in_group("drop_button")
	if not interact_buttons:
		return
	var b:Button = interact_buttons[0]
	if holding:
		b.visible = true
	else:
		b.visible = false
		
	interact_buttons = get_tree().get_nodes_in_group("grab_button")
	if not interact_buttons:
		return
	b = interact_buttons[0]
	if can_pickup():
		b.visible = true
	else:
		b.visible = false

#Physics functions

func apply_flapping(delta):
	if not alive: return
	move.y -= flapping * delta
	
func apply_gravity(delta):
	move.y += gravity * delta

func _physics_process(delta):
	update_ui()
	#slow down horizontal movement
	if move.x < 0:
		move.x += 50*delta
	if move.x > 0:
		move.x -= 50*delta
	#animate based on current move vector
	choose_animation()
	#save toss vector
	toss_vector = Vector2(move.x * 2, move.y * 3)
	#add gravity
	apply_gravity(delta)
	apply_flapping(delta)
	limit_movement()
	var col = self.move_and_collide(move*delta)
	if col:
		move.x = 0
		move.y = 0


# Signals and reactions

func do_damage(amount):
	die()
	
func die():
	alive = false
	$AnimatedSprite.play("death")
	toss_vector = Vector2()
	pickups = []
	drop_item()
	# TODO - hack
	$AnimatedSprite.position.y = -6
	
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
