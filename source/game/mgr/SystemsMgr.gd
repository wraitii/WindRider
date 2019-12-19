extends "res://source/lib/EntityMgr.gd"

const SystemData = preload('../SystemData.gd')

func _init().('Systems', 'res://data/systems/'):
	pass

func _instance(d):
	var item = SystemData.new();
	item.init(d);
	return item;

func get_systems():
	return data

func validation(d, path):
	if !('position' in d):
		print("Error: System without position" + path)
		return false
	return true
