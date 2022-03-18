extends Control
class_name AbilityScreen

export(NodePath) onready var rush_label = get_node(rush_label) as Label
export(NodePath) onready var rush_abilities = get_node(rush_abilities) as ItemList
onready var player = get_tree().get_nodes_in_group('player')[0]

func _ready():
	rush_label.text = "Rush:"
	rush_abilities.add_item("None")
	rush_abilities.select(0)
	var i = 1
	for attack in player.attacks_available:
		rush_abilities.add_item(attack.name)
		if attack in player.attack_rush:
			rush_abilities.select(i)
		i += 1

func _on_RushAbilties_item_selected(index):
	if index==0:
		player.attack_rush = []
	else:
		player.attack_rush = [player.attacks_available[index-1]]
