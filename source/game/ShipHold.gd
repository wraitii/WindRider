extends Node

## Ship holds are made of bee-like cells, layed out in a particular manner.

## Describes the state of the hold cell in 3D
var holdSpace;

## Describe content of the hold cell, indexed by Vector3
var holdContent = {}

signal hold_content_changed(indices)

class HoldItem:
	enum TYPE { COMMODITY }
	var ID;
	var type;
	var amount = 0;
	
	func _init(id, t, a = 0):
		ID = id
		type = t
		amount = a

func init(shipData):
	holdSpace = shipData['hold'];

func can_store(ress, idx = null):
	if !idx:
		return [false, []]

	if !idx in holdContent:
		# TODO: maybe not depending on object size.
		return [true, [idx]]

	return [holdContent[idx].type == ress.type and holdContent[idx].ID == ress.ID, [idx]]

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

	if holdContent[idx].type != ress.type:
		return [false, []]

	if holdContent[idx].ID != ress.ID:
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
