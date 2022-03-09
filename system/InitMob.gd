extends NodeComponent
tool
class_name InitMob

func _ready():
	._ready()
	assert("mob_id" in base_node)
	var _a = connect("tree_entered", self, "set_id")
	var _b = connect("renamed", self, "set_id")
	set_id()
	
func set_id():
	if base_node == get_tree().root:
		print("parent is root - don't set the id")
		return
	if not get_parent().mob_id or get_parent().mob_id == "":
		get_parent().mob_id = str(hash(get_tree().root.name+","+get_parent().name+","+str(self.get_instance_id())))
