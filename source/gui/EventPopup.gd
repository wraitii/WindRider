extends Panel

signal event_ok_pressed(panel)

func _on_OK_pressed():
	emit_signal("event_ok_pressed", self)
