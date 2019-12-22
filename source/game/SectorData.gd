extends Node

var ID;
var _raw;
var position;

# Estimate of the # of ship in the system.
# TODO: improve on this
var activity = 20;

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
