extends "res://source/game/missions/CommonDelivery.gd"

func init(d):
	.init(d)
	type = "PassengerTransport"
	mission_title = "Passenger transport to " + to_ID
	return self
