extends "res://source/game/Mission.gd"

## This mission starts a game.

const EventPopup = preload('res://source/gui/EventPopup.tscn')

func init(_d):
	type = "NewGame"
	return self

func start():
	Core.unload_scene()
	
	var sc = EventPopup.instance()
	sc.get_node('Title').text = "New Game"
	sc.get_node('Text').text = "Welcome to WindRider. I need to write this text."
	
	sc.connect("event_ok_pressed", self, "_continue")
	Core.load_scene(sc)

func _continue(_scene):
	Core.unload_scene()

	Core.gameState.player = Core.societyMgr.create_resource({
		"ID": "player_character",
		"short_name": "Player",
		"type": "character"
	})
	Core.gameState.player.credits = 10000;
	
	var playerShip = Core.outsideWorldSim.create_resource({'model': 'Starbridge'})
	Core.gameState.player.ship = playerShip
	
	# Loads the scene and the sector
	Core.gameState.playerShip.teleport('Abysseus', Vector3(0, 0, 0))
	
	# Clear out the sector
	var ships = Core.outsideWorldSim.get_ships_in('Abysseus')
	for shipID in ships:
		if shipID == Core.gameState.playerShip.ID:
			continue
		else:
			var ship = Core.outsideWorldSim.ship(shipID)
			Core.outsideWorldSim.destroy_ship(ship)
	
	var sc = EventPopup.instance()
	sc.anchor_bottom = 0.8
	sc.anchor_right = 0.8
	sc.anchor_left = 0.2
	sc.anchor_top = 0.2

	next(sc, 0)
	
	Core.gameState.currentScene.get_node('TopLayer').add_child(sc)

func next(sc, i):
	if i == 0:
		sc.get_node('Title').text = "A strange Noise"
		sc.get_node('Text').text = """
Your sight is hazy. Your mind as well, now that you think of it.
\"Where am I?\", you hear yourself think. Of course, you know where you are.
You're in your ship... Let me leave you a few instants to collect your thoughts.
What day is it, you wonder. That's easy. It's only very far from the last day you were wake.
Eight hundred years in cryosleep, give or take a millenia, I guess.
You don't remember shutting yourself down.

Was there maybe some kind of accident? You suppose it doesn't matter, and I'd be inclined to agree. Your Ship, your old solid' ______, held up. So long.

For a fleeting moment, your mind drifts to your location. You know exactly who you are, true, but does that really matter, when no-one else knows who you were?
"""
	elif i == 1:
		sc.get_node('Title').text = "Old made new again?"
		sc.get_node('Text').text = """
So. How did this thing work anyways? You look around, at the commands. It's coming back.
Thrusters, Z and S. Key arrows for direction. Shift+Left/Right to yaw.
There's the old autopilot too, just by pressing E. And the more limited functions, such as aim, A.
The weapon systems is just there in the middle. Space to fire, it says, ha!
Some weirder controls, too, you remember. RailRoading, F, and switching to pointer mode, D.
And there on the left-side, the navigation panels, MLK.

Ay, seems there's nobody out there in Abysseus. I suppose it'll be as good a place as any to take her for a spin.
"""
	else:
		NodeHelpers.queue_delete(sc)
		finish()
		return
	sc.disconnect("event_ok_pressed", self, "_next")
	sc.connect("event_ok_pressed", self, "_next", [i + 1])

func _next(scene, i):
	call_deferred('next', scene, i)
