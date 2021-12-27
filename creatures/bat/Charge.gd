extends Node

export var charge_direction = -1
var charge_level = 0.0
var charge_time = 0.5  #Hold this long to charge
enum {NotCharging, Charging, ReleaseCharge}
var charge_state = NotCharging
var charge_speed = 100  #Speed we move after a charge
var release_charge_time = 1  #How long we charge before resetting

var bat = null
func _ready():
	bat = get_parent()

func begin_charge():
	if bat.alive and charge_state != ReleaseCharge:
		charge_state = Charging
		charge_level = 0
		
func clear_other_charges():
	for node in bat.get_children():
		if "charge_state" in node and node != self:
			node.charge_state = NotCharging

func release_charge():
	if bat.alive and charge_state == Charging:
		if charge_level > charge_time:
			charge_state = ReleaseCharge
			clear_other_charges()
			apply_radar()
		else:
			charge_state = NotCharging
			charge_level = 0
		
func apply_charge():
	charge_state = ReleaseCharge
	clear_other_charges()
	charge_level = 0
	bat.move.x = charge_direction*charge_speed
	bat.move.y = charge_speed
	
func apply_radar():
	var arc:Node2D = bat.get_node("Arc")
	var pulse = load("res://creatures/bat/RadarPulse.tscn").instance()
	#pulse.global_position = arc.global_position
	bat.add_child(pulse)
	pulse.global_scale = arc.global_scale
	pulse.global_rotation = arc.global_rotation
	pulse.angle = arc.angle
	pulse.start_angle = arc.start_angle
		
func physics(delta):
	if charge_state in [Charging, ReleaseCharge]:
		charge_level += delta
	if charge_state == ReleaseCharge:
		if charge_level > release_charge_time:
			charge_state = NotCharging
