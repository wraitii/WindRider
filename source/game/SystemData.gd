extends Spatial

var _raw;

var sectors = [];

func init(data):
	_raw = data;

func _get(prop):
	if prop == 'sectors':
		return sectors
	
	return _raw.get(prop)
