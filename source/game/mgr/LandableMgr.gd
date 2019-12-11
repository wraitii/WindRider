extends "res://source/lib/EntityMgr.gd"

const Landable = preload('../Landable.gd')

func _init().('Landable', 'res://data/landables/'):
	pass

func _instance(data):
	var item = Landable.new();
	item.init(data);
	return item;

func validation(data, path):
	return true
