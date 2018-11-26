extends "res://source/lib/EntityMgr.gd"

const System = preload('../System.gd')

func _init().('Systems', 'res://data/systems/'):
	pass

func create(data):
	var item = System.new();
	item.init(data);
	return item;

func get_systems():
	return data

func validation(data, path):
	if !('position' in data):
		print("Error: System without position" + path)
		return false
	return true