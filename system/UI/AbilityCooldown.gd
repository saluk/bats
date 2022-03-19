extends ColorRect

export var cooldown_group = ""
export var ready_color = Color(1,1,1,0.5)
export var not_ready_color = Color(1,0,0,0.5)

func _process(_delta):
	var cdg = get_tree().get_nodes_in_group(cooldown_group)
	var cd:Cooldown
	if cdg:
		cd = cdg[0]
	else:
		assert(0)
	if cd:
		if cd.is_ready():
			color = ready_color
		else:
			color = not_ready_color
