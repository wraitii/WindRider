extends Node

var ID;
var _raw;
var position;

func init(data):
	_raw = data;
	ID = _raw.ID

	Core.systemsMgr.get(_raw["system"]).sectors.append(_raw["ID"])
	var sys = Core.systemsMgr.get(_raw["system"])
	var sys2 = Core.systemsMgr.get(_raw["system"])
	position = A2V._3(_raw["position"])

func _get(prop):
	if prop == 'position':
		return position

	return _raw.get(prop)

# Called by the world manager when the player jumps in a system.
# The role of this function is to load the sector with ships
# To make it look like we are simulating stuff properly.

const Character = preload('Character.tscn')
const Ship = preload('Ship.tscn')

func generate_activity():
	for i in range(ceil(rand_range(5,25))):
		var ship = Ship.instance()
		var type = 'Cycles'
		if randi() % 2 == 1:
			type = 'Manta'
		ship.init(type)
		ship.teleport(ID, Vector2((randf()-0.5)*5000, (randf()-0.5)*500))
