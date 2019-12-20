extends Control

var currentData = null;
var currentID = null;

var mgr;
var path;

func _init():
	Core.societyMgr.populate()
	Core.landablesMgr.populate()
	Core.systemsMgr.populate()
	Core.sectorsMgr.populate()


#func on_system_selected(system):
#	currentData = IO.read_json(Core.systemsMgr.get_data_path(system.ID))
#	_update()

func _on_Validate_pressed():
	var code = JSON.parse(get_node('GUI/Code').text);
	if code.error != OK:
		get_node('GUI/Save').disabled = true;
		return;
	if mgr.has_method('extra_validation'):
		if !mgr.extra_validation(code.result, "_temp"):
			get_node('GUI/Save').disabled = true;
			return;
	elif !mgr.validation(code.result, "_temp"):
		get_node('GUI/Save').disabled = true;
		return;
	get_node('GUI/Save').disabled = false;
	currentData = code.result

func _on_Save_pressed():
	var datapath
	if !mgr.has(currentID):
		get_node('FileDialog').current_dir = path
		get_node('FileDialog').popup();
		yield(get_node('FileDialog'), 'confirmed');
		datapath = get_node('FileDialog').current_path
	else:
		datapath = mgr.get_data_path(currentID)
	IO.save_text_to_file(datapath, JSON.print(currentData, "\t"))
	mgr.create_resource(currentData, datapath)
	_update()

func _on_Code_text_changed():
	get_node('GUI/Save').disabled = true;
	if !get_node('GUI/Identifier').text.ends_with("*"):
		get_node('GUI/Identifier').text += "*"

func _on_New_pressed():
	currentData = { "ID": null }
	_update()

func _on_Reload_pressed():
	get_parent().refresh()

func _update():
	if 'ID' in currentData:
		currentID = currentData['ID']
	else:
		currentID = null
	
	get_node('GUI/Save').disabled = !mgr.validation(currentData, '_temp');
	get_node('GUI/Code').text = JSON.print(currentData, "\t")
	get_node('GUI/Identifier').text = str(currentID);
	get_parent().refresh()
