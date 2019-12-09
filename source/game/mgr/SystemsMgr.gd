extends "res://source/lib/EntityMgr.gd"

const SystemData = preload('../SystemData.gd')

func _init().('Systems', 'res://data/systems/'):
	pass

func create(data):
	var item = SystemData.new();
	item.init(data);
	return item;

func get_systems():
	return data

func validation(data, path):
	if !('position' in data):
		print("Error: System without position" + path)
		return false
	return true
