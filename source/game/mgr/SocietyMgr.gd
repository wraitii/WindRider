extends "res://source/lib/EntityMgr.gd"

const Society = preload('../Society.gd')

func _init().('Society', 'res://data/societies/'):
	pass

func create(data):
	var item = Society.new();
	item.init(data);
	return item;

func validation(data, path):
	if !('short_name' in data):
		print("Missing short name in Society: " + path)
	return true
