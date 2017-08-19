extends KinematicBody2D

var vel = Vector2(0, 0)

# Set the velocity of this bullet to the given vector2.
func set_vel(shoot_vec):
	vel = shoot_vec
	set_rot(-atan2(shoot_vec.y, shoot_vec.x))

func _fixed_process(delta):
	move(vel * delta)

func _ready():
	set_fixed_process(true)
	pass
