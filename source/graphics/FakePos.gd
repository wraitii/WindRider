extends Spatial

## FakePos objects have a position that's relative to the camera
## So they appear to be some infinite distance away.

var pos setget set_pos, get_pos

func set_pos(t):
	pos = t
	translation = pos

func get_pos():
	return pos

func _process(delta):
	var cam = get_viewport().get_camera()
	translation = pos + cam.translation
