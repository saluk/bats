# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name TestTrap
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://objects/traps/Trap.gd'

func test_bat_with_spikes() -> void:
	var scene:FakeMap = FakeMap.new().setup(self)
	var bat = scene.add("res://creatures/bat/bat.tscn")
	bat.get_node("HealthBar").shields = [{"start_arc":0, "arc":360, "max_health":1, "health": 1}]
	var _spikes = scene.add("res://objects/traps/Spikes.tscn")
	assert_bool(bat.alive == true).is_true()
	yield(scene.process_one_tick(), "completed")
	print(bat.get_node("HealthBar").shields)
	print(bat.global_position)
	print(_spikes.global_position)
	assert_bool(bat.alive == false).is_true()
	scene.queue_free()

func test_archer_with_spikes() -> void:
	var scene:FakeMap = FakeMap.new().setup(self)
	var archer = scene.add("res://creatures/archer/archer.tscn")
	var _spikes = scene.add("res://objects/traps/Spikes.tscn")
	assert_bool(archer.alive == true).is_true()
	yield(scene.process_one_tick(), "completed")
	assert_bool(archer.alive == true).is_true()
	scene.queue_free()
