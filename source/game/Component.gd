extends Spatial

## Component
## Meta-class for ship components

var ID;
var _raw;

var holdIndices = [];
var weaponSystem;

func _init(data):
	ID = data.ID
	_raw = data;

func _get(prop):
	if prop == 'holdIndices':
		return holdIndices
	if prop == 'weaponSystem':
		return weaponSystem
	return _raw.get(prop)
