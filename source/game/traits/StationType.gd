extends "../Trait.gd"

# Represents core traits of a given space station,
# optionally modified by a bunch of other traits.

func _init():
	type = "StationType"

var techLevel = 0
var missionCap = 0

func load_from_data(data):
	techLevel = data['technology_level']
	if 'mission_cap' in data:
		missionCap = data['mission_cap']
	traitName = data['name']
	Core.societyMgr.get(parentSociety).get_parent().techLevel += techLevel

func get_stats_effects():
	return [ { "mission_cap": missionCap } ]

func describe():
	return traitName
