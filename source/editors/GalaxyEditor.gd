extends Control

var currentSystem = null;

func _ready():
	self.connect('resized', self, 'on_resize')
	get_node('GalaxyView/GalaxyViewport/GalaxyMap/MapScript').connect('system_selected', self, 'on_system_selected');
	on_resize();
	get_node('GUI/Save').disabled = true;

func on_resize():
	get_node('GalaxyView/GalaxyViewport').size = get_node('GalaxyView').rect_size

func on_system_selected(system):
	currentSystem = system;
	get_node('GUI/SystemName').text = system.ID
	get_node('GUI/Code').text = IO.read_whole_file(Core.systemsMgr.get_data_path(system.ID))
	pass;

func _on_Validate_pressed():
	var code = JSON.parse(get_node('GUI/Code').text);
	if code.error != OK:
		get_node('GUI/Save').disabled = true;
		return;
	if !Core.systemsMgr.validation(Core.systemsMgr.get(currentSystem.ID), Core.systemsMgr.get_data_path(currentSystem.ID)):
		get_node('GUI/Save').disabled = true;
		return;
	get_node('GUI/Save').disabled = false;

func _on_Save_pressed():
	if !Core.systemsMgr.has(currentSystem.ID):
		get_node('FileDialog').current_dir = "res://data/systems/"
		get_node('FileDialog').popup();
		yield(get_node('FileDialog'), 'confirmed');
		IO.save_text_to_file(get_node('FileDialog').current_path, str(get_node('GUI/Code').text))
		Core.systemsMgr._load(get_node('FileDialog').current_path)
		get_node('GalaxyView/GalaxyViewport/GalaxyMap/MapScript').init()
		get_node('GUI/Save').disabled = true;
		on_system_selected(Core.systemsMgr.get(JSON.parse(get_node('GUI/Code').text).result.ID));
		return
	var path = Core.systemsMgr.get_data_path(currentSystem.ID)
	IO.save_text_to_file(path, str(get_node('GUI/Code').text))
	Core.systemsMgr._load(path)
	get_node('GalaxyView/GalaxyViewport/GalaxyMap/MapScript').init()
	get_node('GUI/Save').disabled = true;
	on_system_selected(Core.systemsMgr.get(JSON.parse(get_node('GUI/Code').text).result.ID));

func _on_Code_text_changed():
	get_node('GUI/Save').disabled = true;

func _on_New_pressed():
	var code = "{\n\t\"ID\":\"newSystem\"\n}"
	get_node('GUI/Save').disabled = true;
	get_node('GUI/Code').text = code;
	get_node('GUI/SystemName').text = "New system";
	currentSystem = { "ID": null }

func _on_Reload_pressed():
#	Core.systemsMgr.populate();
	get_node('GalaxyView/GalaxyViewport/GalaxyMap/MapScript').init()