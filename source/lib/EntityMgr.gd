extends Node

## EntityMgr
## Generic abstraction around ID->Script KV database of sorts.
## Also deals with raw_data for 'from data-file' objects,
## though the class also supports data-less objects.

var data = {}
var raw_data = {}
var paths = {}
var kind;
var resource_path;

func _init(k, p):
	kind = k
	resource_path = p

func populate():
	for s in data:
		_unregister(data[s])

	var files = IO.list_dir(resource_path, '.json')
	for f in files:
		create_resource(IO.read_json(resource_path + f), resource_path + f);

# Create a new resource at the given path, and instance it.
func create_resource(d, path = null):
	if !validation(d, path):
		return null

	var obj = _instance(d)
	
	# As a fallback for no-data resources, use the ID.
	if path == null:
		assert(obj.ID)
		path = obj.ID
	_register(obj, d, path);
	return obj

func has(s):
	return s in data

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
	return true
