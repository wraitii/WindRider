extends Node

## DataMgr
## Generic handler for raw JSON raw data.
## This is intended to hold data that won't change.

var data = {} setget __nos, __nog

# Fake getters
func __nos(a): pass
func __nog(): pass

func _init():
	_load_folder('res://data/');

func _load_folder(path):
	var files = IO.list_dir(path, '.json')
	for f in files:
		_load(path + f)

func _load(path):
	var datum = IO.read_json(path)
	data[path] = datum

func get(s):
	var path = s
	if path.find('res://data') == -1:
		path = 'res://data/' + s + '.json';
	if !(path in data):
		print("Data for " + path + " not found")
		return null
	return data[path]

func get_all(path):
	var ret = []
	for k in data.keys():
		if k.find(path) != -1:
			ret.push_back(k.replace('res://data/','').replace('.json',''))
	return ret