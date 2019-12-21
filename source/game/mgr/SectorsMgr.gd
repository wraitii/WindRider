extends "res://source/lib/EntityMgr.gd"

const SectorData = preload('../SectorData.gd')

var astar;

func _init().('Sectors', 'res://data/sectors/'):
	astar = StarPathComputer.new()

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

func populate():
	.populate()
	update_pathing()

func update_pathing():
	astar.clear()

	var i = 0
	for sector in data:
		astar.add_point(i, data[sector]['position'])
		astar.map[data[sector].ID] = i
		astar.antimap[i] = data[sector].ID
		i += 1

	for sector in data:
		if 'jump_zones' in data[sector]:
			for jz in data[sector]['jump_zones']:
				## Don't assume bidirectionality because this will make things easier later.
				astar.connect_points(astar.map[data[sector].ID], astar.map[jz.jump_to], false)

class StarPathComputer extends AStar:
	# ID -> internal ID
	var map = {}
	var antimap = {}

	func _compute_cost(from_id, to_id):
		return 1
	func _estimate_cost(from_id, to_id):
		return 1
	
	func get_path(from_id, to_id):
		var path = .get_id_path(map[from_id], map[to_id])
		var ret = []
		for i in path:
			ret.append(antimap[i])
		return ret
