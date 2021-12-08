extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var move:Vector2
var pickup = true
var match_name = "SingleRock"

# processing variables
var pickup_time = 0
var stack_time = 0
var stack = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func just_dropped(delta):
	if pickup_time > 0:
		pickup_time -= delta
		
func enter_stack(delta):
	if stack:
		if stack_time > 0:
			stack_time -= delta
		else:
			stack.put_object_in_stack(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	just_dropped(delta)
	enter_stack(delta)
	move.y += 200*delta
	#var col = move_and_collide(move*delta)
	#if col:
	#	move = Vector2()
