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

func _load(path):
	var datum = IO.read_json(path)
	print(path)
	if !('name' in datum):
		print('Error: ' + kind + ' has no name: ' + path)
		return
	
	if datum['name'] in data:
		print('Error: ' + kind + ' name ' + datum['name'] + ' already exists.' + path);
		return

	if !_validation(datum):
		return
		
	data[datum['name']] = datum

func get(s):
	if !(s in data):
		print(kind + " data for " + s + " not found")
		return null
	return data[s]
	
func _validation(data):
	return true;