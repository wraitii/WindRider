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
	get_node('GUI/SystemName').text = system.name
	get_node('GUI/Code').text = IO.read_whole_file(system.raw_path)
	pass;

func _on_Validate_pressed():
	var code = JSON.parse(get_node('GUI/Code').text);
	if code.error != OK:
		get_node('GUI/Save').disabled = true;
		return;
	if !Core.systemsMgr._core_validation(code.result, "", currentSystem.name):
		get_node('GUI/Save').disabled = true;
		return;
	get_node('GUI/Save').disabled = false;

func _on_Save_pressed():
	if !('raw_path' in currentSystem):
		get_node('FileDialog').current_dir = "res://data/systems/"
		get_node('FileDialog').popup();
		yield(get_node('FileDialog'), 'confirmed');
		IO.save_text_to_file(get_node('FileDialog').current_path, str(get_node('GUI/Code').text))
		Core.systemsMgr._load(get_node('FileDialog').current_path)
		get_node('GalaxyView/GalaxyViewport/GalaxyMap/MapScript').init()
		get_node('GUI/Save').disabled = true;
		on_system_selected(Core.systemsMgr.get(JSON.parse(get_node('GUI/Code').text).result.name));
		return
	IO.save_text_to_file(currentSystem.raw_path, str(get_node('GUI/Code').text))
	Core.systemsMgr._unload(currentSystem.name)
	Core.systemsMgr._load(currentSystem.raw_path)
	get_node('GalaxyView/GalaxyViewport/GalaxyMap/MapScript').init()
	get_node('GUI/Save').disabled = true;
	on_system_selected(Core.systemsMgr.get(JSON.parse(get_node('GUI/Code').text).result.name));

func _on_Code_text_changed():
	get_node('GUI/Save').disabled = true;

func _on_New_pressed():
	var code = "{\n\t\"name\":\"newSystem\"\n}"
	get_node('GUI/Save').disabled = true;
	get_node('GUI/Code').text = code;
	get_node('GUI/SystemName').text = "New system";
	currentSystem = { "name": null }
