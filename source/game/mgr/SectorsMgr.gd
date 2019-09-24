extends "res://source/lib/EntityMgr.gd"

const Sector = preload('../Sector.gd')

func _init().('Sectors', 'res://data/sectors/'):
	pass

func create(data):
	var item = Sector.new();
	item.init(data);
	return item;

func get_sectors():
	return data

func validation(data, path):
	if !('position' in data):
		print("Error: Sector without position" + path)
		return false
	return true