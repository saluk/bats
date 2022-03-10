extends Node2DComponent
class_name RushAttackBonus

var enabled = false
export var effects_variable = ""

var emitters = {}

func set_attacking(_enabled):
	if enabled and not _enabled:
		cleanup()
	elif not enabled and _enabled:
		begin()
	enabled = _enabled
	
func cleanup():
	for attack in emitters:
		if attack.mode == FlyingCreature.AttackPower.CONSTANT:
			emitters[attack].set_emitting(false)
	
func begin():
	for attack in base_node.get(effects_variable):
		if attack in emitters:
			emitters[attack].set_emitting(true)
		else:
			var node = load(attack.scene).instance()
			for prop in attack.props:
				node.set(prop, attack.props[prop])
			# Constant attacks are turned off when the attack stops
			# Impulse attacks are projectiles and we leave the lifetime up to them
			# TODO - configure the time the effect starts and stops
			if attack.mode == FlyingCreature.AttackPower.CONSTANT:
				emitters[attack] = node
				add_child(node)
			if attack.mode == FlyingCreature.AttackPower.PROJECTILE:
				(node.get_node("Mover") as Area2D).collision_mask = 0b100001
				node.position = base_node.position
				node.get_node("Mover").direction = attack.props["direction"]
				node.get_node("Mover").direction.x *= base_node.animation.get_fliph()
				base_node.get_parent().add_child(node)
