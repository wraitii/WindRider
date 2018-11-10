extends Container

var landableData

func init(l):
	landableData = l;
	get_node('PlanetName').text = landableData.name

func _on_Undock_pressed():
	Core.gameState.playerShip.undock()