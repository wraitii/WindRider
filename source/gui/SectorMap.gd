extends Control

func _process(delta):
	if Input.is_action_just_released("default_escape_action"):
		hide()

	# TODO: check if we can be opened
	if Input.is_action_just_released('player_open_sector_map'):
		show()

	if !visible:
		return
	
	var centerpos = Vector3(0,0,0)
	
	# TODO: check for docked
	if Core.gameState.playerShip:
		centerpos = Core.gameState.playerShip.translation
	
	get_node("ViewportContainer/Viewport/MapCamera").look_at_from_position(centerpos + Vector3(-1,1,1) * 5000, centerpos, Vector3(0,1,0))
