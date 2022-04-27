extends StateMachine
class_name CrawlingAIController

### Constants/Parameters ###
var spot_distance = 100

### Operation variables ###
var target:Creature = null

export var direction = 1 # x direction to move along the floor, rotates with attached surface
var attach_direction = Vector2.ZERO  #Normal of wall we are attached to
var space_state

var ray_grip_back_result
var ray_grip_front_result
var ray_grip_corner_result
var ray_wall_result

func _ready():
	._ready()
	space_state = base_node.get_world_2d().direct_space_state
	var _a = base_node.connect("is_dead", self, "make_dead")
	
func make_dead():
	base_node.animation.animatedSprite.modulate = Color(1, 0, 0)

func get_target():
	for n in get_tree().get_nodes_in_group("player"):
		if n.alive:
			return n
	return null
	
func get_ray_result(name, start_pos:Vector2, end_vec:Vector2):
	DebugLogger.show_line(name, [start_pos, start_pos+end_vec])
	var result
	result = space_state.intersect_ray(
		start_pos,
		start_pos+end_vec,
		[self],
		0b00000000000000000001
	)
	return not result.empty()
	
func raycasts():
	var gp = base_node.global_position
	var slug = base_node as KinematicBody2D
	var down = slug.transform.basis_xform(Vector2(0,1))
	var forward = slug.transform.basis_xform(Vector2(1,0))
	var back = -forward
	ray_grip_back_result = get_ray_result(
		'gb', gp + back*4, down*6
	)
	ray_grip_front_result = get_ray_result(
		'gf', gp + forward*4, down*6
	)
	ray_grip_corner_result = get_ray_result(
		'gc', gp+down*6+forward*6, back*6
	)
	ray_wall_result = get_ray_result(
		'w', gp, forward*10
	)

func attach_to_walls():
	if ray_grip_corner_result and not ray_grip_front_result:
		(base_node as KinematicBody2D).rotation_degrees += 10
	base_node.move += base_node.transform.basis_xform(Vector2(0,1)) * 5
	# We should check attach direction every frame, but things get weird going around corners
	#if abs(attach_move_direction().x) > 0.5:
	#	base_node.animation.set_flipx(-direction)
	#if abs(attach_move_direction().y) > 0.5:
	#	base_node.animation.set_flipx(direction)
				
func apply_attach_force(delta):
	base_node.move += base_node.transform.basis_xform(Vector2(1,0))*direction*50*delta
	if attach_direction.length()>0:
		# Stick to surface force
		DebugLogger.log_variable("attach force", attach_direction)
		base_node.move.y += (-1 * base_node.gravity*delta)
		base_node.move -= attach_direction * 10

func _physics_process(_delta):
	raycasts()
	attach_to_walls()

func update_brain():
	if base_node.alive:
		.update_brain()
