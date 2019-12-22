extends Panel

signal event_ok_pressed(panel)

func _on_OK_pressed():
	emit_signal("event_ok_pressed", self)

func _input(event):
	if event.is_action_released('default_accept_action'):
		emit_signal("event_ok_pressed", self)
