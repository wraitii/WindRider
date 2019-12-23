extends "../Trait.gd"

# Represents core traits of a given space station,
# optionally modified by a bunch of other traits.

func _init():
	type = "StationType"

var techLevel = 0

func load_from_data(data):
	techLevel = data['technology_level']
	traitName = data['name']
	Core.societyMgr.get(parentSociety).get_parent().techLevel += techLevel

func describe():
	return traitName
