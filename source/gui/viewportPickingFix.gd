extends Viewport

# Workaround for object picking
# See https://github.com/godotengine/godot/issues/26181
func _input(event):
	unhandled_input(event)
