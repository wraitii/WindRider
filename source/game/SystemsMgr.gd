extends "res://source/lib/DataMgr.gd"

func _init().('System', 'res://data/systems/'):
	pass

func _validation(data):
	if !('position' in data):
		print("Error: System without position" + data.name)
		return false
	return true

func get_systems():
	return data