class_name market_list_sell_item
extends Panel

signal refresh_money_cntr

@export var nm: String
@export var qty: int
@export var typ: String
@export var val: int

@export var originating_slot_num: int

@onready var panel = $Panel
@onready var texture_rect = $Panel/TextureRect
@onready var label = $Panel/Label
@onready var txt_item_name = $Panel/txtItemName
@onready var label_2 = $Panel/Label2
@onready var txt_item_cost = $Panel/txtItemCost
@onready var label_3 = $Panel/Label3
@onready var txt_item_value = $Panel/txtItemValue




func _ready():
	setName(nm)
	setQuantity(qty)
	setType(typ)
	setValue(val)


func getName() -> String:
	return txt_item_name.text
func getQuantity() -> int:
	return int(txt_item_cost.text)
func getType() -> String:
	return panel.typ

func setName(nm_val: String):
	panel.nm = nm_val
	txt_item_name.text = str(val)
func setQuantity(qval: int):
	panel.qty = qval
	txt_item_cost.text = str(qval)
func setType(tval: String):
	panel.typ = str(tval)
func setValue(vval: int):
	panel.val = vval
	txt_item_value.text = str(vval)



func _on_button_pressed():
	self.queue_free()
