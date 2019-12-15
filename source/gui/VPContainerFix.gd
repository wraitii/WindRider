extends ViewportContainer

# Fix object picking in viewports somewhat.
# See https://github.com/godotengine/godot/issues/26181
# The actual issue is that unhandled_input will basically never be called
# because there's always a node stopping input somewhere.
# So we must call it manually. Doing so in the viewport is OK,
# but it gets _input which is called even if the action is outside the viewport container.
# So I handle it here instead.
# I'd still like to get an 'unhandled picking' event but well I have the pseudobackground
# hack for now.
func _gui_input(event):
	get_node('Viewport').unhandled_input(event)
