extends Node

## Manages the traits of a society
var traits = {};

func has(ID):
	return ID in traits

func add(ID, trait):
	traits[ID] = trait

## TODO: unique adds, timestamped to galaxy or whatever
# Regularly culling useless traits
# simulating trait 'knowledge'
