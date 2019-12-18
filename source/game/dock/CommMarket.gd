extends Control

const Hold = preload('res://source/game/ShipHold.gd')

var commodities = ['Food', 'Metal']
var buyer;
var landable

func init(l):
	landable = l

func _ready():
	buyer = Core.gameState.player
	for c in commodities:
		$CommodityView.add_item(c + ' - 50')
	$ShipHoldView.init(buyer.ship.hold)

func _process(delta):
	if Input.is_action_just_released("default_escape_action"):
		visible = false
	
	$PlayerCredits.text = "Credits: " + str(buyer.credits)

# Amount is relative to the player, i.e. positive means the player is buying.
func _transaction(commodity, amount):
	if amount > 0:
		## TODO: warn
		if buyer.credits < amount * 50:
			return

	var ress = Hold.HoldItem.new(commodity, Hold.HoldItem.TYPE.COMMODITY, 100, abs(amount))
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
		buyer.credits -= amount * 50
		hold.store(ress, cs[1])
	elif amount < 0:
		buyer.credits += amount * 40
		hold.unload(ress, cs[1])
	
	if !buyer.traits.has('traded'):
		var tt = load('res://source/game/traits/Trade.gd')
		var trait = tt.new()
		trait.landable = landable
		trait.commodities = [commodity]
		trait.amount = amount
		buyer.traits.add('traded',trait)

func _buy_pressed():
	var it = commodities[$CommodityView.get_selected_items()[0]]
	_transaction(it, 1)

func _sell_pressed():
	var it = commodities[$CommodityView.get_selected_items()[0]]
	_transaction(it, -1)
