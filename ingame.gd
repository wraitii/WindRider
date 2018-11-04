extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	if Input.is_action_pressed("thrust"):
		var ship = get_node("Ship")
		ship.velocity.x = min(ship.velocity.x + 0.01, 1)
		print('ship vel')
		print(ship.velocity)
	pass
