extends KinematicBody2D

const bullet_scene = preload("res://scenes/bullet.tscn")
const BULLET_SPEED = 2000.0

const charged_particle_scene = preload("res://scenes/charged_particle.tscn")

var walk_speed = 120
var vel = Vector2(0, 0)

# True if shoot button down. We walk slower, and when released, shot is fired.
var charging_shot = false
# If we're charging, this indicated the power of the shot we're charging
var charge_level = 0.0
# Charge level per second when charging
var charge_rate = 50.0
var max_charge = 100.0

# Counts up when charging_shot = true. When it hits CHARGED_PARTICLE_SPAWN_RATE, a
# charged_particle is spawned.
var charged_particle_spawn_timer = 0.0
const CHARGED_PARTICLE_SPAWN_RATE = 0.1

# Fire a bullet at the cursor.
func _shoot_bullet():
	var target = self.get_global_mouse_pos()
	var pos = self.get_global_pos()
	var shoot_vec = target - pos
	shoot_vec = shoot_vec.normalized() * BULLET_SPEED
	var bullet = bullet_scene.instance()
	var world = self.get_node("/root")
	world.add_child(bullet)
	bullet.set_global_pos(pos)
	bullet.set_vel(shoot_vec)

    # Scale bullet based on charge level
	var scale = 2.0 * charge_level / max_charge + 1.0
	bullet.set_scale(Vector2(scale, scale))

# Function to check whether the shoot button is down, change charging shot
# state etc.
func _check_shoot(delta):
	if (Input.is_action_pressed("shoot")):
		charging_shot = true
	elif charging_shot:
		self._shoot_bullet()

		# Reset for next shot
		charge_level = 0.0
		charged_particle_spawn_timer = 0.0
		charging_shot = false

	if charging_shot:
		charge_level += charge_rate * delta
		if (charge_level > max_charge):
			charge_level = max_charge
		charged_particle_spawn_timer += delta
		while charged_particle_spawn_timer > CHARGED_PARTICLE_SPAWN_RATE:
			# Spawn charged particle at a random angle around the player
			var angle = randf()*PI*2.0
			# Distance particle spawns is proportional to charge level
			var dis = 20.0 + charge_level / max_charge * 100.0
			var spawn_pos = Vector2(dis*cos(angle), dis*sin(angle))
			charged_particle_spawn_timer = charged_particle_spawn_timer - CHARGED_PARTICLE_SPAWN_RATE
			var particle = charged_particle_scene.instance()
			particle.set_global_pos(spawn_pos)
			self.add_child(particle)

func _fixed_process(delta):
	if (Input.is_action_pressed("move_left")):
		vel.x = -walk_speed
	elif (Input.is_action_pressed("move_right")):
		vel.x = walk_speed
	else:
		vel.x = 0

	if (Input.is_action_pressed("move_up")):
		vel.y = -walk_speed
	elif (Input.is_action_pressed("move_down")):
		vel.y = walk_speed
	else:
		vel.y = 0

	_check_shoot(delta)

    # Apply additional scaling (whatever this may be)
	var scaled_vel = vel
	if (charging_shot):
		scaled_vel = scaled_vel*0.5
	move(scaled_vel*delta)

func _ready():
	set_process_input(true)
	set_fixed_process(true)
