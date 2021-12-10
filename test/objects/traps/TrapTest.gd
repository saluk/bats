# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name TrapTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://objects/traps/Trap.gd'

func test_bat_with_spikes() -> void:
	var scene = load("res://test/TestTraps.tscn").instance()
	var runner = scene_runner(scene)
	var bat = scene.find_node("Bat")
	assert_bool(bat.alive == true).is_true()
	print("simulation")
	for i in range(100):
		runner.simulate_frames(1)
	assert_bool(bat.alive == false).is_true()
	print("simulation returned")
	
	scene.queue_free()
	runner.queue_free()
	bat.queue_free()
