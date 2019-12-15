extends Node

## Ship holds are made of bee-like cells, layed out in a particular manner.

# Maps to what is set in the ship file.
# 0/NONE is 'no hold space there'
# 1/OBJECT can get COMMODITY and COMPONENT
# 2/ENGINE can hold objects and ENGINE
# 3/WEAPON can hold objects and are hardpoint for WEAPON.
# 4/ALL can hold anything
enum HOLD_TYPE { NONE, OBJECT, ENGINE, WEAPON, ALL }

## Describes the state of the hold cell in 3D
var holdSpace;

## TODO (planned feature): small ships have S hold cells,
## and a 3x3 cell will then be medium, and 9x9 large.
## For perf/UI reasons, larger ships might start at larger hold sizes.
enum HOLD_SIZE { SMALL, MEDIUM, LARGE }
var holdCellSize = HOLD_SIZE.SMALL;

## Describe content of the hold cell, indexed by Vector3
var holdContent = {}

signal hold_content_changed(indices)

# Hold cells hold integer amount, this is the max.
const MAX_HOLD_VOL = 100000

class HoldItem:
	enum TYPE { COMMODITY, COMPONENT, ENGINE, WEAPON }
	var ID;
	var type;
	var amount : int = 0;
	var volume_per_item : int = MAX_HOLD_VOL;
	
	func _init(id, t, v = MAX_HOLD_VOL, a = 0):
		ID = id
		type = t
		amount = a
		volume_per_item = v

func init(shipData):
	holdSpace = shipData['hold'];
	
	# Take up hull space for hull-space-taking-components.
	if 'components' in shipData:
		for comp in shipData['components']:
			var cd = Core.dataMgr.get('ship_components/' + comp['ID'])
			if !('max_per_hold' in cd):
				continue
			var typ = HoldItem.TYPE.COMPONENT;
			if 'hold_type' in cd:
				typ = HoldItem.TYPE[cd['hold_type']]
			var vol = int(MAX_HOLD_VOL / cd['max_per_hold'])
			print(vol)
			var item = HoldItem.new('ship_components/' + comp['ID'], typ, vol, 1)
			var cs = can_store(item)
			assert(cs[0])
			store(item, cs[1])

func serialize():
	var ret = {}
	ret.holdSpace = holdSpace;
	ret.content = []
	for c in holdContent:
		ret.content.append([[c.x, c.y, c.z], holdContent[c].ID, holdContent[c].type, holdContent[c].amount, holdContent[c].volume_per_item])
	return ret

func deserialize(data):
	for prop in data:
		if prop in self:
			set(prop, data[prop])
	for i in data.content:
		var idx = A2V._3(i[0])
		holdContent[idx] = HoldItem.new(i[1], i[2], i[3], i[4])

func same_ress(a, b):
	return a.type == b.type and a.ID == b.ID

func get_free_amount(ress, idx):
	if !(idx in holdContent):
		return int(MAX_HOLD_VOL / ress.volume_per_item);
	else:
		return int(MAX_HOLD_VOL / holdContent[idx].volume_per_item) - holdContent[idx].amount

func fit(ress, z, y, x):
	# Hold type check
	var spaceType = holdSpace[z][y][x]
	if ress.type == HoldItem.TYPE.COMMODITY or ress.type == HoldItem.TYPE.COMPONENT:
		if spaceType == HOLD_TYPE.NONE:
			return false
	elif ress.type == HoldItem.TYPE.ENGINE:
		if spaceType != HOLD_TYPE.ALL and spaceType != HOLD_TYPE.ENGINE:
			return false
	elif ress.type == HoldItem.TYPE.WEAPON:
		if spaceType != HOLD_TYPE.ALL and spaceType != HOLD_TYPE.WEAPON:
			return false

	var idx = Vector3(x,y,z)
	return !(idx in holdContent) or same_ress(ress, holdContent[idx])

# TODO: implement a 3D packing algorithm.
func find_space(ress):
	var ret = [];
	var lo = ress.amount
	for z in range(0, len(holdSpace)):
		for y in range(0, len(holdSpace[z])):
			for x in range(0, len(holdSpace[z][y])):
				if !fit(ress, z, y, x):
					continue
				var idx = Vector3(x,y,z)
				var fa = get_free_amount(ress, idx)
				if fa <= 0:
					continue
				ret.append(idx)
				lo -= fa
				if lo <= 0:
					return ret
	# We failed, return nothing
	return []

# TODO: possibly switch to something cleverer
func find_holders(ress):
	var ret = []
	var lo = ress.amount
	for z in range(0, len(holdSpace)):
		for y in range(0, len(holdSpace[z])):
			for x in range(0, len(holdSpace[z][y])):
				var idx = Vector3(x,y,z)
				if !idx in holdContent:
					continue
				if !same_ress(ress, holdContent[idx]):
					continue
				ret.append(idx)
				lo -= holdContent[idx].amount
				if lo <= 0:
					return ret
	# We failed, return nothing
	return []

# TODO: extend to indices
func can_store(ress, idx = null):
	if ress.amount <= 0:
		return [false, []]

	if !idx:
		idx = find_space(ress)
		print(idx)
		if !idx:
			return [false, []]
	elif idx in holdContent and !same_ress(holdContent[idx], ress):
		return [false, []]
	else:
		idx = [idx]

	return [true, idx]

func store(ress, indices):
	assert(len(indices) > 0)

	var lo = ress.amount
	for i in indices:
		if !(i in holdContent):
			holdContent[i] = HoldItem.new(ress.ID, ress.type, ress.volume_per_item)
		var free = get_free_amount(ress, i)
		var amt = min(free, lo)
		holdContent[i].amount += amt
		lo -= amt

	emit_signal("hold_content_changed", indices)

func can_unload(ress, idx = null):
	if !idx:
		idx = find_holders(ress)
		if !len(idx):
			return [false, []]
	elif !same_ress(holdContent[idx], ress):
		return [false, []]
	elif ress.amount > holdContent[idx].amount:
		return [false, []]
	else:
		idx = [idx]
	return [true, idx]

func unload(ress, indices):
	assert(len(indices) > 0)

	var lo = ress.amount
	for i in indices:
		var qt = min(holdContent[i].amount, lo)
		holdContent[i].amount -= qt
		lo -= qt
		if holdContent[i].amount == 0:
			holdContent.erase(i)
	
	emit_signal("hold_content_changed", indices)
