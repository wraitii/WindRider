extends Node

## EntityMgr
## Generic abstraction around and ID->Script
## This holds no data

var data = {} setget __nos, __nog
var paths = {} setget __nos, __nog
var kind;
var path;

# Fake getters
func __nos(a): pass
func __nog(): pass

func _init(k, p):
	kind = k
	path = p

func _load(path):
	var source = IO.read_json(path);
	if !validation(source, path):
		return
	var obj = create(source)
	register(obj, path);

func populate():
	for s in data:
		unregister(data[s])

	var files = IO.list_dir(path, '.json')
	for f in files:
		_load(path + f);

func has(s):
	return s in data

func get(s):
	if !(s in data):
		print('Warning: ' + s + ' not found in ' + kind);
		return null
	return data[s]

func get_data_path(s):
	if !(s in paths):
		print('Warning: ' + s + ' not found in ' + kind);
		return null
	return paths[s]

func register(item, path):
	data[item.ID] = item;
	paths[item.ID] = path;

func unregister(item):
	data.erase(item.ID);
	paths.erase(item.ID);

# Functions below are virtual

func serialize():
	pass

# supposed to return the object being created
func create(data):
	pass

func validation(data, path):
	pass
