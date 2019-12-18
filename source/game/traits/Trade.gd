extends "../Trait.gd"

# This life event trait represents the trade of a commodity at a space station

func _init():
	type = "Trade"

var landable;
var commodities = []
var amount = 0

func describe():
	return "Traded " + str(amount) + ' ' + str(commodities[0]) + " at " + landable.ID
