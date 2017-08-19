extends KinematicBody2D

const sheep_class = preload("res://scripts/behaviour_sheep.gd")
const blood = preload("res://scenes/blood.tscn")

var vel = Vector2(0, 0)

var lifetime = 50.0

# Set the velocity of this bullet to the given vector2.
func set_vel(shoot_vec):
	vel = shoot_vec
	set_rot(-atan2(shoot_vec.y, shoot_vec.x))

func _fixed_process(delta):
	lifetime -= delta;
	if lifetime <= 0.0:
		queue_free()
		return

	move(vel * delta)
	if is_colliding():
		var collider = get_collider()
		if collider extends sheep_class:
			collider.queue_free()
			var b = blood.instance()
			b.set_global_pos(get_global_pos())
			get_node("/root/root/blood_layer").add_child(b)

func _ready():
	set_fixed_process(true)
