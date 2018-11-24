extends "res://source/lib/DataMgr.gd"

func _init().('Projectile', 'res://data/projectiles/'):
	pass

func _validation(data):
	if !('type' in data):
		print("Error: no type in projectile" + data.name)
		return false
	return true

