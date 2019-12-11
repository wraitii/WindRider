extends Node

## EntityMgr
## Generic abstraction around and ID->Script

var data = {} setget __nos, __nog
var raw_data = {} setget __nos, __nog
var paths = {} setget __nos, __nog
var kind;
var resource_path;

# Fake getters
func __nos(_a): pass
func __nog(): pass

func _init(k, p):
	kind = k
	resource_path = p

func populate():
	for s in data:
		_unregister(data[s])

	var files = IO.list_dir(resource_path, '.json')
	for f in files:
		create_resource(IO.read_json(resource_path + f), resource_path + f);

func has(s):
	return s in data

# Create a new resource at the given path, and instance it.
# if path is null, this will auto-assign a path.
func create_resource(data, path = null):
	if path == null:
		path = 'custom_' + data.ID + '_' + str(OS.get_unix_time());
	# Hack in case the above is _still_ not sufficient.
	while path in paths:
		path += '_'

	if !validation(data, path):
		return null

	var obj = _instance(data)
	_register(obj, data, path);
	return obj

func get(s):
	if !(s in data):
		print('Warning: ' + s + ' not found in ' + kind);
		return null
	return data[s]

func get_source(s):
	if !(s in raw_data):
		print('Warning: ' + s + ' not found in ' + kind);
		return null
	return raw_data[s]

func get_data_path(s):
	if !(s in paths):
		print('Warning: ' + s + ' not found in ' + kind);
		return null
	return paths[s]

func _register(item, source, path):
	data[item.ID] = item;
	raw_data[item.ID] = source;
	paths[item.ID] = path;

func _unregister(item):
	data.erase(item.ID);
	raw_data.erase(item.ID);
	paths.erase(item.ID);

# Functions below are virtual

func serialize():
	pass

func deserialize(_data):
	populate()
	pass

# Internal function to create an instance from data.
func _instance(_data):
	pass

func validation(_data, _path):
	pass
