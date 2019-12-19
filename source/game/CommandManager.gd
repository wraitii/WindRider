extends Node

var commands = []

func _process(delta):
	pass

func _enter_tree():
	add_to_group('command_manager')

func _physics_process(delta):
	if Core.gameState.currentScene.has_node('PlayerCommands'):
		commands += Core.gameState.currentScene.get_node('PlayerCommands').moveCommandProcess()

	for node in get_tree().get_nodes_in_group('autopilot_running'):
		commands += node.get_commands(delta)

	for command in commands:
		var ship = command[0]
		ship.commands.append(command[1])

	commands = []

func push_command():
	pass
