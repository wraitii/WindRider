extends Control

var may_hide = true setget set_may_hide, get_may_hide

signal system_selected(systemID)

func set_may_hide(v):
	$CloseMap.visible = v
	may_hide = v

func get_may_hide():
	return may_hide

func _ready():
	get_node("ViewportContainer/Viewport/GalaxyMap").connect("system_selected", self, "on_system_selected")

func _input(event):
	if visible and may_hide and event.is_action_released("default_escape_action"):
		hide()
		accept_event()

func _process(delta):
	# TODO: check if we can be opened
	if Input.is_action_just_released('player_open_galaxy_map'):
		# force a refresh
		var n = get_node("ViewportContainer/Viewport/GalaxyMap")
		n.get_parent().remove_child(n)
		get_node("ViewportContainer/Viewport").add_child(n)
		show()

func _on_CloseMap_pressed():
	hide()

func on_system_selected(systemData):
	emit_signal("system_selected", systemData.ID)
