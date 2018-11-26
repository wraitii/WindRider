extends Node

## EntityMgr
## Generic abstraction around and ID->Script
## This holds no data

var data = {} setget __nos, __nog
var kind;
var path;

# Fake getters
func __nos(a): pass
func __nog(): pass

func _init(k, p):
	kind = k
	path = p

func populate():
	var files = IO.list_dir(path, '.json')
	for f in files:
		var source = IO.read_json(path + f);
		if !validation(source, path + f):
			continue
		var obj = create(source)
		register(obj);

func get(s):
	if !(s in data):
		print('Warning: ' + s + ' not found in ' + kind);
		return null
	return data[s]

# virtual
# supposed to return the object being created
func create(data):
	pass

func validation(data, path):
	pass

func register(item):
	data[item.ID] = item;

func unregister(item):
	data.erase(item.ID);