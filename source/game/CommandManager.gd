extends Node

var commands = []

func _process(delta):
	pass

func _physics_process(delta):
	commands += get_node('../PlayerCommands').moveCommandProcess()
	
	for command in commands:
		var ship = command[0]
		var fun = command[1]
		ship.call(fun, delta)
	
	commands = []

func push_command():
	pass