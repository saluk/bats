# GdUnit generated TestSuite
#warning-ignore-all:unused_argument
#warning-ignore-all:return_value_discarded
class_name MapEditorTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://editor/MapEditor.gd'

func test_do_bake_map() -> void:
	var d = Directory.new()
	d.remove("res://test/generated_scenes/UpperRight.tscn")
	# LowerLeft, LowerRight, and TopLeft will be reused to
	# verify the map editor doesn't destroy saved elements
	var test_map_editor:Node = load("res://test/TestMapEditor.tscn").instance()
	test_map_editor.do_bake_map(true)
	
	# Ensure missing map waas recreated
	var UpperRight = load("res://test/generated_scenes/UpperRight.tscn")
	assert_bool(not UpperRight).is_false()
	
	# Ensure spikes are in the right position of each corner
	var TopLeft = load("res://test/generated_scenes/TopLeft.tscn").instance()
	assert_bool(TopLeft.find_node("Spikes").position == Vector2(0,0)).is_true()
	TopLeft.free()
	var LowerLeft = load("res://test/generated_scenes/LowerLeft.tscn").instance()
	assert_bool(LowerLeft.find_node("Spikes").position == Vector2(0,100)).is_true()
	LowerLeft.free()
	var LowerRight = load("res://test/generated_scenes/LowerRight.tscn").instance()
	assert_bool(LowerRight.find_node("Spikes").position == Vector2(100,100)).is_true()
	LowerRight.free()
	
	
	test_map_editor.free()
