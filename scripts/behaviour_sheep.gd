extends KinematicBody2D

const sheep_herd_grouper = preload("res://scripts/sheep_herd_grouper.gd")

# All the possible states the sheep could be in.
enum State {
		# The idle state is the state where the sheet just moves about slowly. Like a minecraft sheep.
		STATE_IDLE,
		# The state where the sheep is moving towards a marker
		STATE_MOVE,
		}

# The current state the sheep is in.
var state = STATE_IDLE
# The target in space for this sheep to move to. How it moves it affected by
# its state.
var target = null

# The distance from the player needed to start running.
var proximity_to_run = 120.0

var walk_speed = 60
var vel = Vector2(0, 0)

# Reference to the player node
var player_ref = null

# Function to select an idle target to move towards
func _select_idle_target():
	var angle = randf() * 2.0 * PI
	var dis = 10.0  + randf() * 30.0
	target = get_global_pos() + Vector2(cos(angle)*dis, sin(angle)*dis)

# Find the scene's marker node
func _find_marker():
	return get_node("/root/root/marker")

func _fixed_process(delta):
	# Act on current state
	if state == STATE_IDLE:
		if target != null:
			# Check if we're close enough to the target to stop
			if (target - self.get_global_pos()).length_squared() < 5:
				target = null
				vel = Vector2(0, 0)
			else: # Otherwise, just move towards the target. Move half as fast, just walking idly.
				vel = (target - self.get_global_pos()).normalized() * walk_speed / 2.0
		else:
			vel = Vector2(0, 0)
			# Select a new target? 
			if randf() > 0.996:
				self._select_idle_target()
	elif state == STATE_MOVE:
		# Run to the marker
		var marker = _find_marker()
		vel = (marker.get_global_pos() - get_global_pos()).normalized() * walk_speed
	move(vel * delta)

	if Input.is_action_pressed("command"):
		state = STATE_MOVE

func _ready():
	# Find player node
	player_ref = self.get_node("/root/root/player")

	set_fixed_process(true)
