extends Control

func _ready():
	$"Tabs/ShipHoldView".init(Core.gameState.playerShip.hold)
	
	var st = "Credits: " + str(Core.gameState.player.credits)
	for t in Core.gameState.player.traits.traits:
		st += '\n' + t + ' - ' + Core.gameState.player.traits.traits[t].describe()
	$Tabs/Player/Desc.text = st

func _process(delta):
	if Input.is_action_just_released("default_escape_action"):
		hide()

	# TODO: check if we can be opened
	if Input.is_action_just_released('player_open_player_info'):
		show()
