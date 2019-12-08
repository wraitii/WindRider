extends Node

var commands = []

func _process(delta):
	pass

func _physics_process(delta):
	commands += get_node('../PlayerCommands').moveCommandProcess()
	
	for command in commands:
		var ship = command[0]
		if command[1] is String:
			var fun = command[1]
			ship.call(fun)
		else:
			ship.callv(command[1][0],command[1][1])
	
	commands = []

func push_command():
	pass
