extends Node
tool
class_name InitMob

func _ready():
	assert("mob_id" in get_parent())
	if get_parent().mob_id == "":
		get_parent().mob_id = str(self.get_instance_id())
	ManageGame.check_deleted(get_parent())
