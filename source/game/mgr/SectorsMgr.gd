extends "res://source/lib/EntityMgr.gd"

const SectorData = preload('../SectorData.gd')

func _init().('Sectors', 'res://data/sectors/'):
	pass

func _instance(d):
	var item = SectorData.new();
	item.init(d);
	return item;

func get_sectors():
	return data

func validation(d, path):
	if !('position' in d):
		print("Error: Sector without position" + path)
		return false
	return true
