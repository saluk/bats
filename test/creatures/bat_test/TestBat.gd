# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name BatTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://creatures/bat/bat.gd'

var world:FakeMap
var bat:Bat

func before_test():
	world = FakeMap.new().setup(self)
	bat = world.add('res://creatures/bat/bat.tscn')

func after_test():
	world.free()

func test_drop_item_no_auto_grab() -> void:
	# Pretend bat has intersected with the rock
	GlobalSettings.auto_grab = false
	var rock = world.add('res://objects/SingleRock.tscn')
	assert_int(len(bat.pickups)).is_equal(0)
	bat._on_Area2D_body_entered(rock)
	yield(world.process_one_tick(), "completed")
	print(bat.pickups)
	assert_int(len(bat.pickups)).is_equal(1)
	bat.grab_item()
	assert_int(len(bat.pickups)).is_equal(0)
	assert_object(bat.holding).is_equal(rock)
	assert_bool(rock in world.get_children()).is_false()
	bat.drop_item()
	assert_bool(rock in world.get_children()).is_true()
	assert_object(bat.holding).is_equal(null)

func test_grab_drop_from_pile():
	var rock_pile = world.add('res://objects/RockPile.tscn')
	bat._on_Area2D_area_entered(rock_pile)
	assert_int(len(bat.pickups)).is_equal(1)
	assert_bool(bat.pickups[0]==rock_pile).is_true()
	bat.grab_item()
	var rock_generated = bat.holding
	assert_object(bat.holding).is_instanceof(RigidBody2D)
	bat.drop_item()
	assert_bool(rock_generated in world.get_children()).is_true()
	assert_object(bat.holding).is_equal(null)
	
func test_grab_drop_auto():
	var rock = world.add('res://objects/SingleRock.tscn')
	GlobalSettings.auto_grab = true
	bat._on_Area2D_body_entered(rock)
	bat.find_node("BatPlayerController").update_ui()
	assert_int(len(bat.pickups)).is_equal(0)
	assert_object(bat.holding).is_equal(rock)
	assert_bool(rock in world.get_children()).is_false()
	bat.drop_item()
	assert_bool(rock in world.get_children()).is_true()
	assert_object(bat.holding).is_equal(null)
