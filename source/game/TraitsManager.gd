extends Node

## Manages the traits of a society
var traits = {};
var parentSociety : String

func _init(parent):
	parentSociety = parent

func serialize():
	var ret = {}
	for ID in traits:
		if traits[ID].should_serialize():
			ret[ID] = traits[ID].serialize()
	return ret

func deserialize(data):
	for ID in data:
		var t = load('res://source/game/traits/' + data[ID]['type'] + '.gd').new()
		t.deserialize(data[ID])
		add(ID, t)

func has(ID):
	return ID in traits

func add(ID, trait):
	traits[ID] = trait
	trait.parentSociety = parentSociety

## TODO: unique adds, timestamped to galaxy or whatever
# Regularly culling useless traits
# simulating trait 'knowledge'
