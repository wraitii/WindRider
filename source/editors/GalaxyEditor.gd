extends Control

const sm = preload('res://source/gui/GalaxyMap.tscn')
const se = preload('SystemEditor.tscn')

var systemEditor

func _ready():
	$Editor.mgr = Core.systemsMgr
	var graphics = sm.instance()
	$Editor/Graphics.add_child(graphics)
	$Editor/Graphics/GalaxyMap/ViewportContainer/Viewport/GalaxyMap.connect('system_selected', self, "on_system_selected")
	$Editor.path = "res://data/systems/"
	$Editor/Graphics/GalaxyMap.may_hide = false
	refresh()

func on_system_selected(system):
	if $Editor.currentID == system.ID:
		systemEditor = se.instance()
		systemEditor.system = system.ID
		add_child(systemEditor)
	$Editor.currentData = IO.read_json(Core.systemsMgr.get_data_path(system.ID))
	$Editor._update()

func refresh():
	$Editor/Graphics/GalaxyMap/ViewportContainer/Viewport/GalaxyMap.init()

func _input(event):
	if event.is_action_released("default_escape_action"):
		if systemEditor:
			NodeHelpers.queue_delete(systemEditor)
			systemEditor = null
			accept_event()
			refresh()
