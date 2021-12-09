extends AnimatedSprite

export var death_length = 0.2
var die_time = -100.0

signal death_started

func explode():
	play("death")
	die_time = death_length

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if die_time>0:
		die_time -= delta
		if die_time < 0:
			get_parent().get_parent().queue_free()
