extends KinematicBody2D

const sheep_herd_grouper = preload("res://scripts/sheep_herd_grouper.gd")

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
	idle_target = get_global_pos() + Vector2(cos(angle)*dis, sin(angle)*dis)

# Checks the player proximity. Will change to STATE_RUN if current state is
# STATE_IDLE, or STATE_IDLE if state is STATE_RUN.
func _check_player_proximity():
	var dis = (player_ref.get_global_pos() - self.get_global_pos()).length_squared()
	if dis < proximity_to_run*proximity_to_run:
		if state == STATE_IDLE:
			state = STATE_RUN
	elif state == STATE_RUN:
		state = STATE_IDLE

func _fixed_process(delta):
	# Check if we should be running from the player
	_check_player_proximity()

	# Act on current state
	if state == STATE_IDLE:
		if idle_target != null:
			# Check if we're close enough to the target to stop
			if (idle_target - self.get_global_pos()).length_squared() < 5:
				idle_target = null
				vel = Vector2(0, 0)
			else: # Otherwise, just move towards the target. Move half as fast, just walking idly.
				vel = (idle_target - self.get_global_pos()).normalized() * walk_speed / 2.0
		else:
			vel = Vector2(0, 0)
			# Select a new target? 
			if randf() > 0.996:
				self._select_idle_target()
	elif state == STATE_RUN:
		idle_target = null
		# Run in the opposite direction of the player. Find the angle we should be
		# running at:
		var angle = sheep_herd_grouper.get_angle(self)
		vel = Vector2(cos(angle) * walk_speed, sin(angle) * walk_speed)
	move(vel * delta)

func _ready():
	# Find player node
	player_ref = self.get_node("/root/root/player")

	set_fixed_process(true)
