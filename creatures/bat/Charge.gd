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
	if charge_held():
		return
	if bat.alive:
		charge_state = Charging
		charge_level = 0
		
func charge_held():
	for node in bat.get_children():
		if "charge_state" in node:
			if node.charge_state in [Charging, ReleaseCharge]:
				return true
		
func clear_charges():
	for node in bat.get_children():
		if "charge_state" in node:
			node.charge_state = NotCharging
			node.charge_level = 0

func release_charge():
	if bat.alive and charge_state == Charging:
		if charge_level > charge_time:
			charge_state = ReleaseCharge
			clear_charges()
			apply_radar()
		else:
			charge_state = NotCharging
			charge_level = 0
		
func apply_charge():
	if not bat.alive:
		return
	charge_state = ReleaseCharge
	charge_level = 0
	bat.set_flip(charge_direction)
	bat.move.x = charge_direction*charge_speed
	bat.move.y = charge_speed
	
func apply_radar():
	clear_charges()
	var arc:Node2D = bat.get_node("Arc")
	var pulse = load("res://creatures/bat/RadarPulse.tscn").instance()
	bat.get_parent().add_child(pulse)
	pulse.move = bat.move
	pulse.global_position = arc.global_position
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
