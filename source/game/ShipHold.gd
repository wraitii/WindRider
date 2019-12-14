extends Node

## Ship holds are made of bee-like cells, layed out in a particular manner.

# Maps to what is set in the ship file.
# 0 is 'no hold space there'
# 1 can get anything.
enum HOLD_TYPE { NONE, ANY }

## Describes the state of the hold cell in 3D
var holdSpace;

## Describe content of the hold cell, indexed by Vector3
var holdContent = {}

signal hold_content_changed(indices)

class HoldItem:
	enum TYPE { COMMODITY, COMPONENT }
	var ID;
	var type;
	var amount = 0;
	
	func _init(id, t, a = 0):
		ID = id
		type = t
		amount = a

func init(shipData):
	holdSpace = shipData['hold'];
	
	# Take up hull space for hull-space-taking-components.
	for comp in shipData['components']:
		var cd = Core.dataMgr.get('ship_components/' + comp['ID'])
		if !('hold_space' in cd):
			continue
		var item = HoldItem.new('ship_components/' + comp['ID'], HoldItem.TYPE.COMPONENT, cd['hold_space'])
		var cs = can_store(item)
		assert(cs[0])
		store(item, cs[1])

func serialize():
	var ret = {}
	ret.holdSpace = holdSpace;
	ret.content = []
	for c in holdContent:
		ret.content.append([[c.x, c.y, c.z], holdContent[c].ID, holdContent[c].type, holdContent[c].amount])
	return ret

func deserialize(data):
	for prop in data:
		if prop in self:
			set(prop, data[prop])
	for i in data.content:
		var idx = A2V._3(i[0])
		holdContent[idx] = HoldItem.new(i[1], i[2], i[3])

# TODO: implement a 3D packing algorithm.
func find_space(ress):
	for z in range(0, len(holdSpace)):
		for y in range(0, len(holdSpace[z])):
			for x in range(0, len(holdSpace[z][y])):
				if holdSpace[z][y][x] == HOLD_TYPE.NONE:
					continue
				
				var idx = Vector3(x,y,z)
				if !(idx in holdContent):
					return [idx]
				if same_ress(ress, holdContent[idx]):
					return [idx]

func same_ress(a, b):
	return a.type == b.type and a.ID == b.ID

# TODO: extend to indices
func can_store(ress, idx = null):
	if !idx:
		idx = find_space(ress)
		if !idx:
			return [false, []]
		idx = idx[0]

	if !idx in holdContent:
		# TODO: maybe not depending on object size.
		return [true, [idx]]

	return [same_ress(holdContent[idx], ress), [idx]]

func store(ress, indices):
	assert(len(indices) > 0)

	for i in indices:
		if !(i in holdContent):
			holdContent[i] = HoldItem.new(ress.ID, ress.type)
	
	var am = ceil(ress.amount / len(indices))
	for i in range(0, len(indices)):
		holdContent[indices[i]].amount += am
	
	emit_signal("hold_content_changed", indices)

func can_unload(ress, idx = null):
	if !idx:
		return [false, []]

	if !idx in holdContent:
		return [false, []]

	if !same_ress(holdContent[idx], ress):
		return [false, []]

	return [holdContent[idx].amount >= ress.amount, [idx]]

func unload(ress, indices):
	assert(len(indices) > 0)

	var am = ceil(ress.amount / len(indices))
	for i in range(0, len(indices)):
		holdContent[indices[i]].amount -= am
	
	for i in indices:
		if holdContent[i].amount == 0:
			holdContent.erase(i)
	
	emit_signal("hold_content_changed", indices)
