extends Node

## DataMgr
## Generic abstraction about preloading JSON data into memory

var data = {} setget __nos, __nog
var kind;

# Fake getters
func __nos(a):
	pass
func __nog():
	pass

func _init(k, path):
	kind = k
	var files = IO.list_dir(path, '.json')
	for f in files:
		_load(path + f)

func _unload(name):
	data.erase(name);

func _load(path):
	var datum = IO.read_json(path)
	
	if !_core_validation(datum, path):
		return null;

	datum.raw_path = path

	data[datum['name']] = datum

func get(s):
	if !(s in data):
		print(kind + " data for " + s + " not found")
		return null
	return data[s]

func _core_validation(datum, path, ignore_name = null):
	if !('name' in datum):
		print('Error: ' + kind + ' has no name: ' + path)
		return false

	if 'raw_path' in datum:
		print('Error: ' + kind + ' uses reserved name raw_path: ' + path)
		return false
	
	if datum['name'] in data && (ignore_name == null || ignore_name != datum['name']):
		print('Error: ' + kind + ' name ' + datum['name'] + ' already exists.' + path);
		return false

	if !_validation(datum):
		return false
	
	return true

func _validation(data):
	return true;