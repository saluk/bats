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
	world.add_child(bat)
	bat._pickup_object_instance(rock)
	assert_object(bat.holding).is_equal(rock)
	bat.drop_item()
	assert_object(bat.holding).is_equal(null)
	world.queue_free()
