extends "res://source/game/Communication.gd"

# Jump Zone
## State-keeper for autojumping at jump zones.

# countdown to 0 = jump
var jumpCD = 10

func _init(s,r).(s,r):
	return self

func _exit(body):
	get_parent().ongoingJumps.erase(receiver.ID)
	Core.gameState.playerShip.emit_signal('add_chat_message', 'Exiting Jump Zone')
	NodeHelpers.call_deferred('queue_delete', self)

func _step(body, step):
	var last = jumpCD
	jumpCD = step
	if jumpCD == 0 and last == 1:
		receiver.call_deferred('jump', get_parent().jumpTo)
		_exit(null)
