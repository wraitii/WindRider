extends "res://source/lib/EntityMgr.gd"

const Society = preload('../Society.gd')
const Character = preload('../Character.gd')

func _init().('Society', 'res://data/societies/'):
	pass

func _instance(data):
	var item
	if data['type'] == "character":
		item = Character.new();
	else:
		item = Society.new();
	item.init(data);
	return item;

func validation(data, path):
	if !('short_name' in data):
		print("Missing short name in Society: " + path)
		return false
	if !('type' in data) or (data['type'] != 'character' and data['type'] != 'society'):
		print("Missing type ('character' or 'society') in Society: " + path)
		return false
	return true

func assign_outfits():
	var outfits = Core.dataMgr.get_all('ship_components/')
	for k in outfits:
		var outfit = Core.dataMgr.get(k)
		get(outfit['creator']).outfits.push_back(k)
