class_name market_list_item
extends Panel

signal init_market_ui_inv
signal refresh_money_cntr

@export var nm: String
@export var qty: int
@export var typ: String

@onready var panel = $Panel
@onready var texture_rect = $Panel/TextureRect
@onready var label = $Panel/Label
@onready var txt_item_name = $Panel/txtItemName
@onready var label_2 = $Panel/Label2
@onready var txt_item_cost = $Panel/txtItemCost

func _ready():
	setName(nm)
	setQuantity(qty)
	setType(typ)


func getName() -> String:
	return txt_item_name.text
func getQuantity() -> int:
	return int(txt_item_cost.text)
func getType() -> String:
	return panel.typ

func setName(val: String):
	panel.nm = val
	txt_item_name.text = str(val)
func setQuantity(val: int):
	panel.qty = val
	txt_item_cost.text = str(val)
func setType(val: String):
	panel.typ = str(val)




# - - - - - - - - - - - - - - - - - - - - - - - - 
# - - - HANDLING CLICKS IN MARKET INVENTORY - - -
# - - - - - - - - - - - - - - - - - - - - - - - - 

func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			#Item purchased
			_attempt_purchase(qty)

func _attempt_purchase(amt):
	if Global.PLAYER_MONEY >= abs(amt):
		if PInv.isSpaceAvailable(typ,qty):
			PInv.add_item(typ,qty)
			init_market_ui_inv.emit()
			Global.PLAYER_MONEY = Global.PLAYER_MONEY - amt
			refresh_money_cntr.emit()
			cFuncs.sfx_play("sell_item",$AudioStreamPlayer2D)
		else:
			cFuncs.sfx_play("action_failed",$AudioStreamPlayer2D)
			print("You don't have space in your inventory")
	else:
		cFuncs.sfx_play("action_failed",$AudioStreamPlayer2D)
		print("You don't have enough money")
