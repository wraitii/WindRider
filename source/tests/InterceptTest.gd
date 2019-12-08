extends Node

func _init():
	var chaser = {
		'translation': Vector3(0,0,0),
		
	}
	var target = {
		'translation': Vector3(10,0,0),
		'linear_velocity': Vector3(0,1,0)
	}
	
	print(Intercept.simple_intercept(chaser, target, 1))
	print(Intercept.simple_intercept(chaser, target, 2))
	print(Intercept.simple_intercept(chaser, target, 10))
