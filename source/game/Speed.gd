extends Label

func _ready():
	pass

func _process(delta):
	var ship = Core.gameState.player.get_current_ship()

	if !ship: return
	var txt = "Speed: " + str(ship.get_linear_velocity().length()) + "\n"
	txt += "Rotation: " + str(ship.get_angular_velocity().length()) + "\n"
	txt += "Velocity: " + str(ship.get_linear_velocity()) + "\n"
	txt += "Pos: " + str(ship.translation)
	text = txt