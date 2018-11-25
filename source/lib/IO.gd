extends Node

## Brand new full-cost abstraction

# returns null in case of error
static func list_dir(dirPath, ext = null):
	var dir = Directory.new()

	if dir.open(dirPath) != OK:
		return null

	var ret = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while (file_name != ""):
		if file_name.begins_with('.'):
			file_name = dir.get_next()
			continue;		
		if dir.current_is_dir():
			var dret = list_dir(dirPath + file_name, ext)
			for a in dret:
				ret.push_back(file_name + '/' + a)
			print(ret)
			file_name = dir.get_next()
			continue
		if ext == null || file_name.ends_with(ext):
			ret.push_back(file_name)
		file_name = dir.get_next()
	return ret

static func read_whole_file(path):
	var file = File.new()
	if file.open(path, File.READ) != OK:
		return null;
	return file.get_as_text()

static func save_text_to_file(path, data):
	var file = File.new()
	if file.open(path, File.WRITE) != OK:
		return null;
	file.store_string(data)

# opens, parses JSON or returns null
static func read_json(path):
	var file = File.new()
	if file.open(path, File.READ) != OK:
		return null;

	var json = JSON.parse(file.get_as_text())
	if json.error != OK:
		print("IO.read_json failure: " + path)
		print(json.get_error_string())
		return null;
	return json.result
