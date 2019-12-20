extends Control

var currentSystemData = null;
var currentSystemID = null;

func _init():
	Core.societyMgr.populate()
	Core.landablesMgr.populate()
	Core.systemsMgr.populate()
	Core.sectorsMgr.populate()

func _ready():
	self.connect('resized', self, 'on_resize')
	get_node('GalaxyView/Viewport/GalaxyMap').connect('system_selected', self, 'on_system_selected');
	on_resize();
	get_node('GUI/Save').disabled = true;

func on_resize():
	get_node('GalaxyView/Viewport').size = get_node('GalaxyView').rect_size

func on_system_selected(system):
	currentSystemData = IO.read_json(Core.systemsMgr.get_data_path(system.ID))
	_update()

func _on_Validate_pressed():
	var code = JSON.parse(get_node('GUI/Code').text);
	if code.error != OK:
		get_node('GUI/Save').disabled = true;
		return;
	if !Core.systemsMgr.validation(code.result, "_temp"):
		get_node('GUI/Save').disabled = true;
		return;
	get_node('GUI/Save').disabled = false;
	currentSystemData = code.result

func _on_Save_pressed():
	var path
	if !Core.systemsMgr.has(currentSystemID):
		get_node('FileDialog').current_dir = "res://data/systems/"
		get_node('FileDialog').popup();
		yield(get_node('FileDialog'), 'confirmed');
		path = get_node('FileDialog').current_path
	else:
		path = Core.systemsMgr.get_data_path(currentSystemID)
	IO.save_text_to_file(path, JSON.print(currentSystemData, "\t"))
	Core.systemsMgr.create_resource(currentSystemData, path)
	_update()

func _on_Code_text_changed():
	get_node('GUI/Save').disabled = true;
	if !get_node('GUI/SystemName').text.ends_with("*"):
		get_node('GUI/SystemName').text += "*"

func _on_New_pressed():
	currentSystemData = { "ID": null }
	_update()

func _on_Reload_pressed():
	$GalaxyView/Viewport/GalaxyMap.init()

func _update():
	if 'ID' in currentSystemData:
		currentSystemID = currentSystemData['ID']
	else:
		currentSystemID = null
	
	get_node('GUI/Save').disabled = !Core.systemsMgr.validation(currentSystemData, '_temp');
	get_node('GUI/Code').text = JSON.print(currentSystemData, "\t")
	get_node('GUI/SystemName').text = str(currentSystemID);
	$GalaxyView/Viewport/GalaxyMap.init()
