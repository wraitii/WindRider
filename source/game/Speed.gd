extends Label

func _ready():
	pass

func _process(delta):
	var ship = get_node('/root/InGameRoot/Player').get_current_ship()
	if !ship: return
	var txt = "Speed: " + str(ship.get_linear_velocity().length()) + "\n"
	txt += "Velocity: " + str(ship.get_linear_velocity()) + "\n"
	txt += "Pos: " + str(ship.translation)
	text = txt