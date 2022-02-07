extends StateMachine
class_name ArcherAIController

### Operation variables ###
var creature = null  # Creature we are controlling
var target:FlyingCreature = null

var direction = -1

func _ready():
	randomize()
	creature = get_parent()
	var _a = creature.connect("stunned", self, "was_stunned")

func get_target():
	for n in get_tree().get_nodes_in_group("player"):
		if n.alive:
			return n
	return null
		
func update_brain():
	if creature.alive:
		.update_brain()

# Events
func was_stunned():
	if not creature.alive:
		return
	if current_state != STStunned:
		switch_to_state_if_possible(get_state_by_name('STStunned'))
