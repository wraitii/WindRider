extends Control

const Item = preload('../../graphics/MarketPlaceItem.tscn')

### Marketplace
## Allows you to buy and sell stuff.
## Combines the trade, outfit and shipyards functionality all in one.
## This is just an abstraction for what's happening on the dock.

signal close();
func on_close():
	emit_signal('close');

var ownerDock;

var focusedItem = null;

var products = {}

func setup_listeners():
	get_node('Close').connect('pressed', self, 'on_close');
	get_node('Buy').connect('pressed', self, 'on_buy');
	get_node('Sell').connect('pressed', self, 'on_sell');

func init(d):
	ownerDock = d;
	_update_products()
	setup_listeners()

func _update_products():
	NodeHelpers.remove_all_children(get_node('ItemGrid'))
	for socName in ownerDock.societyPresence:
		var society = Core.societyMgr.get(socName)
		for k in society.outfits:
			var item = Item.instance()
			item.init(k);
			item.connect('pressed', self, 'on_item_pressed', [item])
			get_node('ItemGrid').add_child(item);

func on_item_pressed(item):
	item.focused = true
	if focusedItem != null:
		focusedItem.focused = false
	focusedItem = item;
	
	if 'describe' in item:
		get_node('Panel/Specs').text = item.describe()
	else:
		get_node('Panel/Specs').text = JSON.print(Core.dataMgr.get(item.key), "\t")

func on_buy():
	pass

func on_sell():
	pass