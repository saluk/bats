extends Node2D
class_name FakeMap

var physics_count = -1
var runner
signal processed_physics_once
signal each_physics_step

func _ready():
	var _signal = get_tree().connect("physics_frame", self, "increment_physics_count")
	
func setup(test_suite):
	runner = test_suite.scene_runner(self)
	return self
	
func add(path):
	var n = load(path).instance()
	self.add_child(n)
	return n
	
func increment_physics_count():
	# Called BEFORE physics are processed, so the first call brings count to 0
	physics_count += 1
	if physics_count == 1:
		emit_signal("processed_physics_once")
	emit_signal("each_physics_step")

func process_one_tick():
	print("proccing one tick")
	yield(
		runner.simulate_until_object_signal(self, "each_physics_step"), 
		"completed"
	)
	print("end processing")
