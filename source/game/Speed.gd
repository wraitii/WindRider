extends Label

func _ready():
	pass

func _process(delta):
	var ship = Core.gameState.player.get_current_ship()

	if !ship: return
	var txt = "FPS: " + str(Engine.get_frames_per_second()) + "\n"
	txt += "Date: " + Core.gameState.galacticTime.get_iso() + "\n"
	txt += "Speed: " + str(ship.get_linear_velocity().length()) + "\n"
	txt += "Position: " + str(ship.translation) + "\n"
	txt += "Rotation: " + str(ship.get_angular_velocity().length()) + "\n"
	txt += "Velocity: " + str(ship.get_linear_velocity()) + "\n"
	txt += "Pos: " + str(ship.translation) + "\n"
	txt += "RR: " + str(ship.railroading) + '\n'
	txt += "x: " + str(Engine.get_time_scale()) + '\n'
	txt += "Target: " + str(ship.autopilot.targetSpeed)
	text = txt
