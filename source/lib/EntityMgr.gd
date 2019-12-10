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

func _load(path):
	var source = IO.read_json(path);
	if !validation(source, path):
		return
	var obj = create(source)
	register(obj, source, path);

func populate():
	for s in data:
		unregister(data[s])

	var files = IO.list_dir(resource_path, '.json')
	for f in files:
		_load(resource_path + f);

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

func register(item, source, path):
	data[item.ID] = item;
	raw_data[item.ID] = source;
	paths[item.ID] = path;

func unregister(item):
	data.erase(item.ID);
	raw_data.erase(item.ID);
	paths.erase(item.ID);

# Functions below are virtual

func serialize():
	pass

# supposed to return the object being created
func create(_data):
	pass

func validation(_data, _path):
	pass
