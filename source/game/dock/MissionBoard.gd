extends Panel

var character
var landable

func init(l):
	landable = l
	
	character = Core.gameState.player

func _ready():
	
