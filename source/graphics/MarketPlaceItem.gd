extends Control

signal pressed()
func on_pressed():
	emit_signal('pressed')
	
var focused : bool setget set_focused, get_focused;

var owned : int = 0;

# Key of the item
var key;

func set_focused(v):
	focused = v;
	get_node('Panel/Focus').visible = focused

func get_focused():
	return focused

func init(k):
	key = k
	var item = Core.dataMgr.get(k)
	get_node('Panel/Button').connect('pressed', self, 'on_pressed');
	
	if 'name' in item:
		get_node('Panel/Name').text = item.name
	
	_compute_owned()

func _compute_owned():
	owned = 0;
	var player = Core.gameState.player;
	var ship = player.get_current_ship()
	## This isn't efficient.
	for comp in ship.shipStats.get_children():
		if comp.ID == key:
			owned += 1;
	get_node('Panel/Owned').text = str(owned);