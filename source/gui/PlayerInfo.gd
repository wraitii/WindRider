extends Control

func _ready():
	$"Tabs/ShipHoldView".init(Core.gameState.playerShip.hold)
	
	$Tabs/Player/Desc.text = "Credits: " + str(Core.gameState.player.credits)

func _process(delta):
	if Input.is_action_just_released("default_escape_action"):
		hide()

	# TODO: check if we can be opened
	if Input.is_action_just_released('player_open_player_info'):
		show()
