extends Control

### Marketplace
## Allows you to buy and sell stuff.
## Combines the trade, outfit and shipyards functionality all in one.
## This is just an abstraction for what's happening on the dock.

signal close();
func on_close():
	emit_signal('close');

var ownerDock;
var ship;

var focusedItem = null;

var products = {}

const Component = preload('res://source/game/Component.gd')

func init(d):
	ownerDock = d;
	ship = Core.gameState.playerShip;
	_setup_products()
	_setup_listeners()

func _setup_products():
	NodeHelpers.remove_all_children($ItemGrid)
	for socName in ownerDock.societyPresence:
		var society = Core.societyMgr.get(socName)
		for k in society.outfits:
			var item = $ItemDetail.duplicate()
			item.init(k);
			item.connect('pressed', self, 'on_item_pressed', [item])
			$ItemGrid.add_child(item);
	update_products()

func _setup_listeners():
	get_node('Panel/Close').connect('pressed', self, 'on_close');
	get_node('Panel/Buy').connect('pressed', self, 'on_buy');
	get_node('Panel/Sell').connect('pressed', self, 'on_sell');

func update_products():
	for item in $ItemGrid.get_children():
		var itemData = Core.dataMgr.get(item.key)
		var ress = Component.ress(itemData)
		var owned = ship.hold.get_stocked_amount(ress)
		var installed = len(ship.get_installed(item.key.replace("ship_components/","")))
		item.owned = owned + installed
		item.installed = installed
	get_node('Panel/Player Credits').text = 'Credits: ' + str(Core.gameState.player.credits)

func on_item_pressed(item):
	item.focused = true
	if focusedItem != null:
		focusedItem.focused = false
	focusedItem = item;
	
	$Panel/Sell.disabled = focusedItem.owned == 0
	
	if item.has_method('describe'):
		get_node('Panel/Specs').text = item.describe()
	else:
		get_node('Panel/Specs').text = JSON.print(Core.dataMgr.get(item.key), "\t")

func on_buy():
	var player = ship.ownerChar

	var item = Core.dataMgr.get(focusedItem.key)

	if !('buy_price' in item):
		$Chat.add_message("Item cannot be bought.")
		return

	var install = true
	if !ship.can_install(focusedItem.key.replace("ship_components/", "")):
		if !ship.hold.can_store(Component.ress(item)):
			$Chat.add_message("Item cannot be installed or stored.")
			return
		else:
			install = false
			$Chat.add_message("Item cannot be installed, will be stored.")

	if player.credits >= item['buy_price']:
		player.credits -= item['buy_price']
	else:
		$Chat.add_message("Not enough credits")
		return
	
	if install:
		ship.install_component(focusedItem.key.replace("ship_components/", ""))
	else:
		var cs = ship.hold.can_store(Component.ress(item))
		ship.hold.store(Component.ress(item), cs[1])

	update_products()

func on_sell():
	var player = ship.ownerChar
	
	if focusedItem.owned == 0:
		$Chat.add_message("Nothing to sell")
		return

	var item = Core.dataMgr.get(focusedItem.key)

	if !('sell_price' in item) and !('buy_price' in item):
		$Chat.add_message("Item cannot be sold")
		return;
	
	## TODO: warn about uninstalling.

	if 'sell_price' in item:
		player.credits += item['sell_price']
	else:
		player.credits += floor(item['buy_price'] / 2)
	
	if focusedItem.owned == focusedItem.installed:
		player.ship.uninstall_component(focusedItem.key.replace("ship_components/", ""))
		$Chat.add_message("Warning: component was uninstalled")

	var cs = ship.hold.can_unload(Component.ress(item))
	assert(cs[0])
	ship.hold.unload(Component.ress(item), cs[1])
	
	update_products()
