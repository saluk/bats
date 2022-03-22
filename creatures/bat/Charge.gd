extends NodeComponent

var charge_direction = -1
var charge_level = 0.0
var charge_time = 0.5  #Hold this long to charge
enum {NotCharging, Charging, ReleaseCharge}
var charge_state = NotCharging
var charge_speed = 100  #Speed we move after a charge
var release_charge_time = 1  #How long we charge before resetting
var hover_after_time = 0.25
var after_time = 0

var bat = null
func _ready():
	bat = get_parent()
	var _a = Dialog.connect("pause_for_dialog", self, "reset")

func begin_charge(xdir):
	if charge_held():
		return
	if bat.alive:
		charge_state = Charging
		charge_level = 0
		charge_direction = xdir
		
func charge_held():
	for node in bat.get_children():
		if "charge_state" in node:
			if node.charge_state in [Charging, ReleaseCharge]:
				return true
		
func clear_charges():
	reset()
			
func reset():
	charge_state = NotCharging
	charge_level = 0
	
func is_active_charge():
	return bat.alive and charge_state == Charging and charge_level > charge_time

func release_charge(xdir):
	if bat.alive and charge_state == Charging:
		if is_active_charge():
			charge_state = ReleaseCharge
			clear_charges()
			apply_radar()
		else:
			charge_state = NotCharging
			charge_level = 0
			
func what_action():
	if bat.holding:
		charge_time = 0.2
		return "toss"
	charge_time = 0.5
	return "radar"
	
func apply_radar():
	clear_charges()
	if what_action() == "radar":
		var arc:Node2D = bat.get_node("Arc")
		var pulse = load("res://creatures/bat/RadarPulse.tscn").instance()
		bat.get_parent().add_child(pulse)
		pulse.global_position = arc.global_position
		pulse.global_scale = arc.global_scale
		pulse.global_rotation = arc.global_rotation
		pulse.angle = arc.angle
		pulse.start_angle = arc.start_angle
		after_time = hover_after_time
	elif what_action() == "toss":
		print(bat.get_node("AimingArc").get_vector())
		print(bat.get_node("AimingArc").dir)
		bat.toss_vector = bat.get_node("AimingArc").get_vector() * 150
		print(bat.toss_vector)
		bat.drop_item()
		
func physics(delta):
	DebugLogger.log_variable(name+".charge",str(charge_level)+","+str(charge_state))
	if charge_state in [Charging, ReleaseCharge]:
		charge_level += delta
	if charge_state == ReleaseCharge:
		if charge_level > release_charge_time:
			charge_state = NotCharging
	if after_time > 0:
		after_time -= delta
		bat.move.y *= 0.2
		bat.move.x *= 0.5
