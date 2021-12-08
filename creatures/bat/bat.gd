extends KinematicBody2D

### Operation variables ###
var move = Vector2(0, 0)
var toss_vector = move

### Constants/Parameters ###
var xlimit = 100
var ylimit = 100
var jump_width = 50
var jump_height = 50

### References ###
var holding:Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Body functions
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
	
func pickup_object_from_pile(object:PackedScene):
	return _pickup_object_instance(object.instance())
	
func pickup_object_from_world(object:Node2D):
	if _pickup_object_instance(object):
		object.get_parent().remove_child(object)
		return true
	
func _pickup_object_instance(object:Node2D):
	if holding:
		return false
	if object.pickup_time > 0:
		return false
	holding = object
	$Holding.get_child(0).texture = holding.find_node('Sprite').texture
	return true
	
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
	
# Input
func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var click_pos = event.position
		if click_pos.x < position.x:
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
	if abs(move.x)>0.5 or move.y<0:
		$AnimatedSprite.play("fly")
	else:
		$AnimatedSprite.play("idle")
		
func limit_movement():
	if move.x < -xlimit: move.x = -xlimit
	if move.x > xlimit: move.x = xlimit
	if move.y > ylimit: move.y = ylimit
	if move.y < -ylimit: move.y = -ylimit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
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
	if move.y > 0:  # not flapping
		move.y += 100*delta
	else:  # flapping
		move.y += 100*delta
	limit_movement()
	var col = self.move_and_collide(move*delta)
	if col:
		move.x = 0
		move.y = 0



func _on_Area2D_body_entered(body):
	if "pickup" in body:
		pickup_object_from_world(body)
