extends Node

var systems = {} setget __no, systems

func _init():
	var systemPath = 'res://data/systems/'
	var systemFiles = IO.list_dir(systemPath, '.json')
	for f in systemFiles:
		_load_system(systemPath + f)

func __err(sd, e, p):
	if !(e in sd):
		print("Error: system without " + e + ": " + p)
		return true
	return false

func _load_system(path):
	var systemData = IO.read_json(path)
	
	if __err(systemData, "name", path): return
	if __err(systemData, "position", path): return
	
	systems[systemData['name']] = systemData

func __no(a):
	pass

func systems():
	return systems

func system(s):
	if !(s in systems):
		return null
	return systems[s]