# This is a utility script to help sheeps with their movement. When running
# away from the player, sheep should group with other sheep near them. This
# script keeps track of the positions of the sheep, and groups them according
# to the angle they're at with the player so that they can move as one.

const sheep_class = preload("res://scripts/behaviour_sheep.gd")

# The size of the angle in radians allowed for a group of sheep.
const ANGLE_SIZE = PI/2.0

# Used in the get_angle function.
class Angle:
	var angle_start
	var angle_size
	var sheep_list 
	func _init(_angle_start):
		self.angle_start = _angle_start
		self.angle_size = ANGLE_SIZE
		self.sheep_list = []

# A function to get the angle that a given sheep should be travelling.
# NOTE: Sheep must be under /root/root, otherwise this function will return null.
static func get_angle(sheep):
	# Get the player's position and this sheep's position
	var player_pos = sheep.get_node("/root/root/player").get_global_pos()

	# Loop over sheep, and split them into angles to the player
	var angles = []
	for n in sheep.get_node("/root/root").get_children():
		if !(n extends sheep_class): continue
		# Check this sheep is in range
		var n_pos = n.get_global_pos()
		if (n_pos - player_pos).length_squared() > n.proximity_to_run*n.proximity_to_run:
			continue
		# Find the angle that this sheep is in in the list. If the list is empty,
		# then this is the first sheep and will define the rotation of all the
		# angles.
		var angle = -player_pos.angle_to_point(n_pos) - PI/2
		if angle < 0: angle += 2*PI
		if angles.empty():
			# Initialise all the angles in a circle
			var curr_angle = angle
			while curr_angle < angle + 2*PI:
				angles.append(Angle.new(curr_angle))
				curr_angle += ANGLE_SIZE

		# Find which angle this sheep should be in
		for a in angles:
			# Make the angles 'normal' (i.e. between 0 and 2*pi)
			var p = a.angle_start
			var q = a.angle_start + a.angle_size
			while p > 2*PI: p -= 2*PI
			while q > 2*PI: q -= 2*PI
			if q < p: p -= 2*PI
			# Handle the special case that p < 0
			if p < 0:
				print(angle-2*PI)
				print(p)
				print(q)
				if (angle > q && angle-2*PI >= p && angle-2*PI <= q) || (angle >= p && angle <= q):
						a.sheep_list.append(n)
						break
			else:
				if angle >= p && angle <= q:
					a.sheep_list.append(n)
					break

	# Now the sheep should be split into angles. Find the given sheep and return
	# the average angle of the group the sheep was put into
	for a in angles:
		var in_list = false
		var angle_sum = 0
		for s in a.sheep_list:
			if s == sheep:
				in_list = true
			# Calculate the angle and add it on
			angle_sum += (-player_pos.angle_to_point(s.get_global_pos()) - PI/2)
		if in_list:
			return angle_sum / a.sheep_list.size()

	return null


