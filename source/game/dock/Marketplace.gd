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

func init(d):
	ownerDock = d;
	_setup_products()
	_setup_listeners()

func _setup_products():
	NodeHelpers.remove_all_children(get_node('ItemGrid'))
	for socName in ownerDock.societyPresence:
		var society = Core.societyMgr.get(socName)
		for k in society.outfits:
			var item = Item.instance()
			item.init(k);
			item.connect('pressed', self, 'on_item_pressed', [item])
			get_node('ItemGrid').add_child(item);
	update_products()	

func _setup_listeners():
	get_node('Panel/Close').connect('pressed', self, 'on_close');
	get_node('Panel/Buy').connect('pressed', self, 'on_buy');
	get_node('Panel/Sell').connect('pressed', self, 'on_sell');

func update_products():
	for item in get_node('ItemGrid').get_children():
		item.owned = len(Core.gameState.playerShip.shipStats.get_components(item.key))
	get_node('Panel/Player Credits').text = 'Credits: ' + str(Core.gameState.player.credits)

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
	var player = Core.gameState.player

	var item = Core.dataMgr.get(focusedItem.key)

	if !('buy_price' in item):
		return;

	if player.credits >= item['buy_price']:
		player.credits -= item['buy_price']
		player.ship.shipStats.add_component(focusedItem.key)

	update_products()

func on_sell():
	var player = Core.gameState.player
	
	if focusedItem.owned == 0:
		return

	var item = Core.dataMgr.get(focusedItem.key)
	if !('sell_price' in item) and !('buy_price' in item):
		return;

	if 'sell_price' in item:
		player.credits += item['sell_price']
	else:
		player.credits += floor(item['buy_price'] / 2)
	
	player.ship.shipStats.remove_component(focusedItem.key)
	
	update_products()
