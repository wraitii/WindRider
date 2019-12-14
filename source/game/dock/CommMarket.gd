extends Control

var commodities = ['Food', 'Metal']

const Hold = preload('res://source/game/ShipHold.gd')

func _ready():
	for c in commodities:
		$CommodityView.add_item(c + ' - 50')
	$ShipHoldView.init(Core.gameState.playerShip.hold)

func _process(delta):
	if Input.is_action_just_released("default_escape_action"):
		visible = false
	
	$PlayerCredits.text = "Credits: " + str(Core.gameState.player.credits)

# Amount is relative to the player, i.e. positive means the player is buying.
func _transaction(commodity, amount):
	if amount > 0:
		## TODO: warn
		if Core.gameState.player.credits < amount * 50:
			return

	var ress = Hold.HoldItem.new(commodity, Hold.HoldItem.TYPE.COMMODITY, abs(amount), 0.01)
	var hold = $ShipHoldView.hold

	var cell;
	if len($ShipHoldView.selected_cells):
		cell = $ShipHoldView.selected_cells[0]

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
		Core.gameState.player.credits -= amount * 50
		hold.store(ress, cs[1])
	elif amount < 0:
		Core.gameState.player.credits += amount * 40
		hold.unload(ress, cs[1])

func _buy_pressed():
	var it = commodities[$CommodityView.get_selected_items()[0]]
	_transaction(it, 1)

func _sell_pressed():
	var it = commodities[$CommodityView.get_selected_items()[0]]
	_transaction(it, -1)
