extends Node

var _raw;
var position;

func init(data):
	_raw = data;

	Core.systemsMgr.get(_raw["system"]).sectors.append(_raw["ID"])
	var sys = Core.systemsMgr.get(_raw["system"])
	var sys2 = Core.systemsMgr.get(_raw["system"])
	position = A2V._3(_raw["position"])

func _get(prop):
	if prop == 'position':
		return position

	return _raw.get(prop)
