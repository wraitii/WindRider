extends "res://source/lib/EntityMgr.gd"

const Landable = preload('../Landable.gd')

func _init().('Landable', 'res://data/landables/'):
	pass

func _instance(d):
	var item = Landable.new();
	item.init(d);
	return item;
