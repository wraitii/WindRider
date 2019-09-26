extends Control

signal pressed()
func on_pressed():
	emit_signal('pressed')
	
var focused : bool setget set_focused, get_focused;

var owned : int = 0 setget set_owned, get_owned;

# Key of the item
var key;

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

func init(k):
	key = k
	var item = Core.dataMgr.get(k)
	get_node('Panel/Button').connect('pressed', self, 'on_pressed');
	
	if 'name' in item:
		get_node('Panel/Name').text = item.name
