extends Node

export (String) var _system = null;

const System = preload('System.tscn')

func _init():
	_system = 'sol'
	var systemFile = File.new()
	systemFile.open('res://data/systems/' + _system + '.json', File.READ);
	var system = System.instance()
	system.init(JSON.parse(systemFile.get_as_text()).result)
	self.add_child(system)

	return

func _ready():
	get_node('VelocityRadar').set_follower(get_node('Ship'))
	pass

func _process(delta):
	pass

func _physics_process(state):
	pass
