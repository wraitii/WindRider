extends "res://source/lib/EntityMgr.gd"

const Society = preload('../Society.gd')
const Character = preload('../Character.gd')

func _init().('Society', 'res://data/societies/'):
	pass

func populate():
	.populate()
	## TODO: if I get an outfitMgr or something this should be replaced
	assign_outfits()

func _instance(d):
	var item
	if d['type'] == "character":
		item = Character.new();
	else:
		item = Society.new();
	item.init(d);
	return item;

func validation(d, path):
	if !('short_name' in d):
		print("Missing short name in Society: " + path)
		return false
	if !('type' in d) or (d['type'] != 'character' and d['type'] != 'society'):
		print("Missing type ('character' or 'society') in Society: " + path)
		return false
	return true

func assign_outfits():
	var outfits = Core.dataMgr.get_all('ship_components/')
	for k in outfits:
		var outfit = Core.dataMgr.get(k)
		get(outfit['creator']).outfits.push_back(k)

func serialize():
	var serialized_societies = {}
	for ID in data:
		serialized_societies[ID] = [data[ID].type, data[ID].serialize(), paths[ID]]
	return serialized_societies

func deserialize(ser_data):
	for ID in ser_data:
		var obj
		if ser_data[ID][0] == "character":
			obj = Character.new()
		else:
			obj = Society.new()
		obj.ID = ID
		_register(obj, obj._raw, ser_data[ID][2])
	
	for ID in data:
		data[ID].deserialize(ser_data[ID][1])

	## TODO: if I get an outfitMgr or something this should be replaced
	assign_outfits()
