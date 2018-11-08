extends Node

var shipsData = {} setget __nos, __nog

func _init():
	var path = 'res://data/ships/'
	var files = IO.list_dir(path, '.json')
	for f in files:
		_load_ship(path + f)

func _load_ship(path):
	var data = IO.read_json(path)
	
	if !("name" in data):
		print("Error: ship has no name: " + path)
		return
	
	if data['name'] in shipsData:
		print('Error: Ship name ' + data['name'] + ' already exists.' + path);
		return
	
	if !("scene" in data):
		print("Error: ship has no scenes: " + path)
		return

	shipsData[data['name']] = data

func __nos(a):
	pass
func __nog():
	pass

func get(s):
	if !(s in shipsData):
		print("ship data for " + s + " not found")
		return null
	return shipsData[s]
