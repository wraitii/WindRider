extends "res://source/game/missions/CommonDelivery.gd"

func init(d):
	if !.init(d):
		return null

	type = "PassengerTransport"
	missionTitle = "Passenger transport to " + to_ID
	return self
