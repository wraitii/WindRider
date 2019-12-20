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

func extra_validation(d, path):
	if !validation(d, path):
		return false
	
	if 'jump_zones' in d:
		for j in d['jump_zones']:
			if !(j['jump_to'] in data):
				print("Error: Invalid jump to " + j['jump_to'] + " for " + path)
				return false
	return true
