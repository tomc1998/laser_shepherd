extends KinematicBody2D

# Seconds until decay
const LIFETIME = 0.5
# Counts up to LIFETIME
var life = 0.0
# How much faster this particle decays and moves. When finish_quick() is
# called, this is set to a higher value.
var decay_modifier = 1.0
var vel = Vector2(0, 0)

func _fixed_process(delta):
	set_scale(Vector2(0.5 + 3.0*life/LIFETIME, 0.5 + 3.0 * life/LIFETIME))
	life += delta * decay_modifier
	if life >= LIFETIME:
		self.queue_free()

	# Apply additional acceleration based on proximity
	

	move(vel * delta * decay_modifier * (life*64.0))
# Make this particle finish it's travel quickly. This happens when the player fires the bullet.
func finish_quick():
	decay_modifier = 4.0

func _ready():
	set_fixed_process(true)

	# Find the parent
	var target = self.get_node("..").get_global_pos()
	var vec = target - self.get_global_pos()
	vel = vec / LIFETIME / 20.0
