extends Node

var commands = []

func _process(delta):
	pass

func _physics_process(delta):
	commands += get_node('../PlayerCommands').moveCommandProcess()

	for node in get_tree().get_nodes_in_group('autopilot_running'):
		commands += node.get_commands(delta)

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
