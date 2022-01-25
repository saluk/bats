extends Reference
class_name CreatureAnimation

var animatedSprite:AnimatedSprite

var offsets = {}
var sprite_default_facing = -1

func _init(_animatedSprite):
	animatedSprite = _animatedSprite
	
func set_fliph(v:bool):
	if animatedSprite:
		animatedSprite.flip_h = v
		
func set_flipx(x):
	if x > 0:
		set_fliph(sprite_default_facing < 0)
	if x < 0:
		set_fliph(sprite_default_facing > 0)

func play(animationName):
	if not animatedSprite:
		return
	if animationName in offsets:
		animatedSprite.position = offsets[animationName]
	else:
		animatedSprite.position = Vector2(0,0)
	if animatedSprite.frames.has_animation(animationName):
		animatedSprite.play(animationName)
		return
	
	# Default to stop animation if we are dead and have no death animation
	if animationName == "death":
		animatedSprite.stop()
		return
	
	# Try to play idle animation
	animatedSprite.play("idle")
