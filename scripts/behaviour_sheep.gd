extends KinematicBody2D

# All the possible states the sheep could be in.
enum State {
		# The idle state is the state where the sheet just moves about slowly. Like a minecraft sheep.
		STATE_IDLE, 
		# The running state is where the sheep is actively running away from the player (i.e. being herded).
		STATE_RUN
		}

# The current state the sheep is in.
var state = STATE_IDLE
# The target in space for this sheep when idle.
var idle_target = null

var walk_speed = 80
var vel = Vector2(0, 0)

# Function to select an idle target to move towards
func _select_idle_target():
	var angle = randf() * 2.0 * PI
	var dis = 10.0  + randf() * 30.0
	idle_target = get_global_pos() + Vector2(cos(angle)*dis, sin(angle)*dis)

func _fixed_process(delta):
	if state == STATE_IDLE:
		if idle_target != null:
			# Check if we're close enough to the target to stop
			if (idle_target - self.get_global_pos()).length_squared() < 5:
				idle_target = null
				vel.x = 0
				vel.y = 0
			else: # Otherwise, just move towards the target. Move half as fast, just walking idly.
				vel = (idle_target - self.get_global_pos()).normalized() * walk_speed / 2.0
		else:
			# Select a new target? 
			if randf() > 0.996:
				self._select_idle_target()

	move(vel * delta)


func _ready():
	set_fixed_process(true)
	pass
