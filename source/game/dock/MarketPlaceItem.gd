extends Control

signal pressed()
func on_pressed():
	emit_signal('pressed')
	
var focused : bool setget set_focused, get_focused;

var owned : int = 0 setget set_owned, get_owned;
var installed : int = 0 setget set_installed, get_installed;

# Key of the item
var key;

func _ready():
	get_node('Panel').connect("resized", self, "on_resized")

func set_focused(v):
	focused = v;
	get_node('Panel/Focus').visible = focused

func get_focused():
	return focused

func set_owned(o):
	owned = o
	get_node('Panel/Owned').text = str(owned)

func get_owned():
	return owned;

func set_installed(o):
	installed = o
	get_node('Panel/Installed').text = str(installed)

func get_installed():
	return installed;
	
func init(k):
	key = k
	var item = Core.dataMgr.get(k)
	get_node('Panel/Button').connect('pressed', self, 'on_pressed');
	
	if 'name' in item:
		get_node('Panel/Name').text = item.name

func on_resized():
	#get_node('Panel').anchor_right = 1
	var pts = get_node('Panel/Focus').points
	var i = 0
	for p in pts:
		var pp = p
		pp.x = min(1, pp.x)
		pp.y = min(1, pp.y)
		pts.set(i, pp * get_node('Panel').rect_size)
		i += 1
	get_node('Panel/Focus').points = pts
