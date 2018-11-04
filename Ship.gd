extends Spatial

export(Vector3) var velocity = Vector3(0,0,0)

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	print(velocity)
	translate(velocity * delta)
	pass
