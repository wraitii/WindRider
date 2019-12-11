extends Control

func _ready():
	get_node("ViewportContainer/Viewport/GalaxyMap").connect("system_selected", self, "on_system_selected")

func _process(delta):
	if Input.is_action_just_released("default_escape_action"):
		hide()
	
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
	pass
