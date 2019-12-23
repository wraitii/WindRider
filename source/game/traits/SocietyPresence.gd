extends "../Trait.gd"

# Adds some society's presence to a station.

func _init():
	type = "SocietyPresence"

var targetSociety : String
var socPres = 10

func load_from_data(data):
	socPres = data['presence']
	targetSociety = data['society']
	traitName = data['name']

func describe():
	return traitName
