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
	enum TYPE { COMMODITY, COMPONENT }
	var ID;
	var type;
	var amount : int = 0;
	var volume_per_item : int = MAX_HOLD_VOL;

	# Direct reference to components (including engine/weapons)
	# Not serialized (components set it back again)
	var components = [];

	func _init(id, t, v = MAX_HOLD_VOL, a = 0):
		ID = id
		type = t
		amount = a
		volume_per_item = v
	
	func max_amount():
		return int(MAX_HOLD_VOL / volume_per_item)

func _idx(x,y,z):
	return PoolIntArray([x,y,z])

func init(shipData):
	holdSpace = shipData['hold'];

func serialize():
	var ret = {}
	ret.holdSpace = holdSpace;
	ret.content = []
	for c in holdContent:
		ret.content.append([c, holdContent[c].ID, holdContent[c].type, holdContent[c].volume_per_item, holdContent[c].amount])
	return ret

func deserialize(data):
	for prop in data:
		if prop in self:
			set(prop, data[prop])
	for i in data.content:
		var idx = i[0]
		holdContent[idx] = HoldItem.new(i[1], i[2], i[3], i[4])

# Importantly, this doesn't check for volume - that is so we don't have to always fetch volume.
func same_ress(a, b):
	return a.type == b.type and a.ID == b.ID

# Returns # of items in the hold, as cargo.
# This does not count installed components.
func get_stocked_amount(ress):
	var holders = find_holders(ress, true)
	var am = 0
	for idx in holders:
		am += holdContent[idx].amount
		am -= len(holdContent[idx].components)
	return am

func get_free_amount(ress, idx):
	if !(idx in holdContent):
		return ress.max_amount();
	else:
		return holdContent[idx].max_amount() - holdContent[idx].amount

func fit(ress, z, y, x):
	# Hold type check
	var spaceType = holdSpace[z][y][x]
	if spaceType == HOLD_TYPE.NONE:
		return false
	
	var idx = _idx(x,y,z)
	return !(idx in holdContent) or same_ress(ress, holdContent[idx])

# TODO: implement a 3D packing algorithm.
func find_space(ress, only_type = null):
	var ret = [];
	var lo = ress.amount
	for z in range(0, len(holdSpace)):
		for y in range(0, len(holdSpace[z])):
			for x in range(0, len(holdSpace[z][y])):
				var idx = _idx(x,y,z)
				if only_type and holdSpace[z][y][x] != only_type:
					continue
				if !fit(ress, z, y, x):
					continue
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
func find_holders(ress, all = false):
	var ret = []
	var lo = ress.amount
	for z in range(0, len(holdSpace)):
		for y in range(0, len(holdSpace[z])):
			for x in range(0, len(holdSpace[z][y])):
				var idx = _idx(x,y,z)
				if !idx in holdContent:
					continue
				if !same_ress(ress, holdContent[idx]):
					continue
				ret.append(idx)
				lo -= holdContent[idx].amount
				if !all and lo <= 0:
					return ret
	if lo <= 0:
		return ret
	return []

# TODO: extend to indices
func can_store(ress, idx = null, holdType = null):
	if ress.amount <= 0:
		return [false, []]

	if !idx:
		idx = find_space(ress, holdType)
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
	var comps = ress.components.duplicate()
	for i in indices:
		if !(i in holdContent):
			holdContent[i] = HoldItem.new(ress.ID, ress.type, ress.volume_per_item)
		var free = get_free_amount(ress, i)
		var amt = min(free, lo)
		assert(amt > 0)
		holdContent[i].amount += amt
		for _c in range(min(len(comps), amt)):
			var comp = comps.pop_back()
			comp.holdIndices = [i]
			holdContent[i].components.append(comp)
		lo -= amt

	emit_signal("hold_content_changed", indices)

# Returns the best Hold Cell to unload from
# It goes for the one with the most available items.
class BestHoldToUnload:
	var holdContent
	func sort(a, b):
		var aa = holdContent[a].amount - len(holdContent[a].components)
		var bb = holdContent[b].amount - len(holdContent[b].components)
		return aa > bb

func can_unload(ress, idx = null):
	if !idx:
		var try_all = ress.type == HoldItem.TYPE.COMPONENT
		idx = find_holders(ress, try_all)
		if !len(idx):
			return [false, []]
		if try_all:
			var bh = BestHoldToUnload.new()
			bh.holdContent = holdContent
			idx.sort_custom(bh, "sort")
	elif !same_ress(holdContent[idx], ress):
		return [false, []]
	elif ress.amount > holdContent[idx].amount:
		return [false, []]
	else:
		idx = [idx]
	return [true, idx]

# Returns references to popped components, if any
func unload(ress, indices):
	assert(len(indices) > 0)

	var popped_components = []
	
	var lo = ress.amount
	for i in indices:
		var qt = min(holdContent[i].amount, lo)
		holdContent[i].amount -= qt
		for _c in range(min(len(holdContent[i].components), qt)):
			var comp = holdContent[i].components.pop_back()
			comp.holdIndices = []
			popped_components.append(comp)
		lo -= qt
		if holdContent[i].amount == 0:
			holdContent.erase(i)
		if lo <= 0:
			break
	
	emit_signal("hold_content_changed", indices)
	
	return popped_components
