extends Control

signal split_activated(itm1,amt1,itm2,amt2)

@onready var txt_item_name: Label = $NAME/txtItemName
@onready var txt_quantity: Label = $QUANTITY/txtQuantity
@onready var pic_item_to_be_sold: TextureRect = $picItemToBeSold

@export var item_name: String
@export var max_qty: int

var split_item_slot_index: int
var amount_splitting: int = 1


func _input(event):
	if self.visible:
		var triggered_flag: bool = false
		if event.is_action_pressed("use"):
			_on_btn_accept_pressed()
			triggered_flag = true
		if event.is_action_pressed("ui_accept"):
			_on_btn_accept_pressed()
			triggered_flag = true
		if event.is_action_pressed("ui_cancel"):
			_on_btn_cancel_pressed()
			triggered_flag = true
		if event.is_action_pressed("ui_left"):
			_on_btn_set_qty_minus_1_pressed()
			triggered_flag = true
		if event.is_action_pressed("ui_right"):
			_on_btn_set_qty_plus_1_pressed()
			triggered_flag = true
		if triggered_flag:
			get_viewport().set_input_as_handled()






func _set_name(val)->void:
	item_name = val
	_update()

func _set_max_qty(val)->void:
	max_qty = val
	_update()

func _set_slot_index(val)->void:
	split_item_slot_index = val

func get_ResourceIconImage(itmName: String)->Texture:
	var item_res: inventory_object
	#init resource and qty
	# Sometimes called by name, others by resource id.  Bandaid to cover both cases.
	if ResourceLoader.exists("res://Resources/" + itmName + ".tres"):
		#using resID
		item_res = load("res://Resources/" + itmName + ".tres")
	else:
		#using name
		var nm_to_id = Jsondata.getItemID_from_name(str(itmName))
		item_res = load("res://Resources/" + nm_to_id + ".tres")
	return item_res.itmTexture

func _update():
	txt_item_name.text = Jsondata.getItemName_from_id(item_name)
	txt_quantity.text = str(amount_splitting)
	pic_item_to_be_sold.texture = get_ResourceIconImage(item_name)
	


## FUNCTIONS RELATED TO INPUT

func _on_btn_set_qty_minus_1_pressed():
	amount_splitting -= 1
	if amount_splitting < 1:
		amount_splitting = max_qty - 1
	_update()
func _on_btn_set_qty_plus_1_pressed():
	amount_splitting += 1
	if amount_splitting == max_qty:
		amount_splitting = 1
	_update()
func _on_btn_cancel_pressed():
	self.visible = false
func _on_btn_accept_pressed():
	split_activated.emit(item_name,amount_splitting,split_item_slot_index)
	self.visible = false
