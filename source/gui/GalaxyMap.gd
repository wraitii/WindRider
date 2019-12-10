extends Control

func _ready():
	get_node("ViewportContainer/Viewport/GalaxyMap").connect("system_selected", self, "on_system_selected")

func _process(delta):
	# TODO: check if we can be opened
	if Input.is_action_just_released('player_open_galaxy_map'):
		show()

func _on_CloseMap_pressed():
	hide()

func on_system_selected(systemData):
	pass
