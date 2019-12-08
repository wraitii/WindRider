extends Node

class_name Intercept

# Compute the vector (and position) at which chaser will intercept target
# This assumes chaser is able to move straight where it needs to go
# and that both chaser and target are constant velocity and orientation.

# If you're like me and maths is far away, this is the generalized
# Pythagorean theorem, write the cosinus as the dot product, and things
# helpfully cancel out neatly to make a quadratic equation.

# Thus assumes chaser is a Spatial and target a RigidBody.
static func simple_intercept(chaser, target, chase_speed):
	var target_to_chaser = chaser.translation - target.translation
	var target_vel = target.linear_velocity
	
	# Chaser speed is insignificant, assume failure.
	if chase_speed < 0.1:
		return [null, null]
	
	# Target is not moving relative to the distance, assume it's not moving.
	if target_vel.length_squared() < target_to_chaser.length_squared()/1000.0:
		return [-target_to_chaser.normalized(), target.translation]

	var a = chase_speed * chase_speed - target_vel.length_squared();
	var b = 2 * target_to_chaser.dot(target_vel);
	var c = -target_to_chaser.length_squared();

	var time_to_intercept = null

	if abs(a) < 0.001 and b <= 0.001:
		return [null, null]
	elif abs(a) < 0.001:
		time_to_intercept = -c / b
	else:
		# preliminary check that there are real solutions:
		var bb_4ac = b * b - 4 * a * c
		if bb_4ac < 0:
			return [null, null]

		# Compute roots, pick the smallest positive value.
		var roots = [(-b - sqrt(bb_4ac)) / (2*a), (-b + sqrt(bb_4ac)) / (2*a)]

		if roots[0] >= 0 and roots[0] <= roots[1]:
			time_to_intercept = roots[0]
		elif roots[1] >= 0:
			time_to_intercept = roots[1]
		else:
			return [null, null]
	
	var intercept_pos = target.translation + target_vel * time_to_intercept
	return [(intercept_pos - chaser.translation).normalized(), intercept_pos]

# TODO: fancier intercepts, possibly assuming a constant-velocity bezier?
