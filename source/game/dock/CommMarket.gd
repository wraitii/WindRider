extends Control

var commodities = ['Food', 'Metal']

const Hold = preload('res://source/game/ShipHold.gd')

func _ready():
	for c in commodities:
		$CommodityView.add_item(c)
	$ShipHoldView.init(Core.gameState.playerShip.hold)

func _process(delta):
	if Input.is_action_just_released("default_escape_action"):
		visible = false

# Amount is relative to the player, i.e. positive means the player is buying.
func _transaction(commodity, amount):
	## TODO	: select
	if !len($ShipHoldView.selected_cells):
		return

	var cell = $ShipHoldView.selected_cells[0]
	var ress = Hold.HoldItem.new(commodity, Hold.HoldItem.TYPE.COMMODITY, abs(amount))
	var hold = $ShipHoldView.hold

	var cs;
	if amount > 0:
		cs = hold.can_store(ress, cell)
	elif amount < 0:
		cs = hold.can_unload(ress, cell)

	if !cs[0]:
		## TODO: warn
		return

	if !cs[1]:
		## TODO: warn
		return
	
	if amount > 0:
		hold.store(ress, cs[1])
	elif amount < 0:
		hold.unload(ress, cs[1])

func _buy_pressed():
	var it = commodities[$CommodityView.get_selected_items()[0]]
	_transaction(it, 1)

func _sell_pressed():
	var it = commodities[$CommodityView.get_selected_items()[0]]
	_transaction(it, -1)
