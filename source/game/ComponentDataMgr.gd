extends Node

var compData = {} setget __nos, __nog

func _init():
	var path = 'res://data/ship_components/'
	var files = IO.list_dir(path, '.json')
	for f in files:
		_load_component(path + f)

func _load_component(path):
	var data = IO.read_json(path)
	
	if !("name" in data):
		print("Error: component has no name: " + path)
		return
	
	if data['name'] in compData:
		print('Error: Component name ' + data['name'] + ' already exists.' + path);
		return
	
	compData[data['name']] = data

func __nos(a):
	pass
func __nog():
	pass

func get(s):
	if !(s in compData):
		print("Component data for " + s + " not found")
		return null
	return compData[s]
