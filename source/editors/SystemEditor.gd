extends Node

const sm = preload('res://source/gui/SystemMap.tscn')

var system = "Sol"

func _ready():
	$Editor.mgr = Core.sectorsMgr
	var graphics = sm.instance()
	$Editor/Graphics.add_child(graphics)
	$Editor/Graphics/SystemMap/ViewportContainer/Viewport/SystemMap.connect('sector_selected', self, "on_sector_selected")
	$Editor.path = "res://data/sectors/"
	$Editor/Graphics/SystemMap.may_hide = false
	refresh()

func on_sector_selected(ID):
	$Editor.currentData = IO.read_json(Core.sectorsMgr.get_data_path(ID))
	$Editor._update()

func refresh():
	$Editor/Graphics/SystemMap/ViewportContainer/Viewport/SystemMap.init(system)
