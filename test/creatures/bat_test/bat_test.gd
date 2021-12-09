# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name BatTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://creatures/bat/bat.gd'

func test_drop_item() -> void:
	var world = Node2D.new()
	var bat = load('res://creatures/bat/bat.tscn').instance()
	var rock = load('res://objects/SingleRock.tscn').instance()
	var rock_pile = load('res://objects/RockPile.tscn').instance()
	world.add_child(bat)
	world.add_child(rock)
	world.add_child(rock_pile)
	# Pretend bat has intersected with the rock
	
	bat._on_Area2D_body_entered(rock)
	bat.grab_item()
	assert_int(len(bat.pickups)).is_equal(0)
	assert_object(bat.holding).is_equal(rock)
	assert_bool(rock in world.get_children()).is_false()
	bat.drop_item()
	assert_bool(rock in world.get_children()).is_true()
	assert_object(bat.holding).is_equal(null)
	
	bat._on_Area2D_area_entered(rock_pile)
	assert_int(len(bat.pickups)).is_equal(1)
	assert_bool(bat.pickups[0]==rock_pile).is_true()
	bat.grab_item()
	var rock_generated = bat.holding
	assert_object(bat.holding).is_instanceof(RigidBody2D)
	bat.drop_item()
	assert_bool(rock_generated in world.get_children()).is_true()
	assert_object(bat.holding).is_equal(null)
	
	
	world.queue_free()
