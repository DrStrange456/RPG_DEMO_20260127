class_name general_store 
extends Control


#region *** Base code - For Scene Transitions
signal level_changed(value)
signal effect_finished()

func cleanup():
	effect_finished.emit()
	queue_free()
#endregion



# Buying variables
@onready var slots_inv = $CanvasLayer/TabContainer/BUY/MyInventory_Section/InventoryContainer.get_children()
@onready var merch_list = $CanvasLayer/TabContainer/BUY/Merchant_Section/Panel/ScrollContainer/VBoxContainer

# Selling variables
@onready var slots_inv_sell2 = $CanvasLayer/TabContainer/SELL/MyInventory_Section/InventoryContainer.get_children()
@onready var market_item_sell_ui = $CanvasLayer/market_item_sell_ui
@onready var sell_quantity_container = $CanvasLayer/TabContainer/SELL/MyInventory_Section/SellQuantityContainer.get_children()
@onready var txt_sell_amount = $CanvasLayer/TabContainer/SELL/txtSellValue/txtSellAmount

const SlotClass = preload("res://scenes/levels/general_store/slot_v2.gd")

var first_time_flag: bool = true
var wares_list_pos = Vector2.ZERO
var input_escape_lock: bool = false

var items_to_be_sold: Array = []
var merchant_wares: Dictionary = {
	# Item ID : Quantity
	"2201_seeds_tomato": 10,
	"2202_seeds_turnip": 10,
	"2203_seeds_strawberry": 10,
	"2204_seeds_blueberry": 10,
	"2205_seeds_carrot": 10,
	"2007_carrot": 50,
	"2008_tomato": 50,
	"2009_turnip": 50,
	"2010_strawberry": 50,
	"2011_blueberry": 50,
} 



func _ready():
	#Load buyer stuff
	_load_merchant_wares()
	_initialize_Slots()
	initialize_inventory()
	#Load seller stuff
	_initialize_sell_Slots()
	_on_market_item_refresh_money_cntr()
	initialize_sell_inventory_2()
	reset_sell_qty_labels()

func _input(event: InputEvent) -> void:
	if self.visible:
		if event.is_action_pressed("ui_cancel"):
			Events.emit_signal("GenStore_OnEscape_OkayToClose")


# - - - - - - - - - - - - - - - - - - - - - - - - 
# - - - HANDLING CLICKS IN PLAYERS INVENTORY - - -
# - - - - - - - - - - - - - - - - - - - - - - - - 
func slot_gui_input(event: InputEvent, _slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			pass
			#kbm_input_left_click(event,slot)
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			pass
			#kbm_input_right_click(event,slot)
func slot_gui_input_sell(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			kbm_input_left_click(event,slot)
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			kbm_input_right_click(event,slot)

# - - - - - - - - - - - - - - - - - - -  - - -
# - - - KEYBOARD AND MOUSE INPUT DEFAULT - - -
# - - - - - - - - - - - - - - - - - - -  - - -
func kbm_input_left_click(_event: InputEvent, slot: SlotClass) -> void:
	sell_item_clicked(slot)
func kbm_input_right_click(_event: InputEvent, _slot: SlotClass) -> void:
	print("Right Click")


func _reset_buyer_ui()->void:
	_load_merchant_wares()
	_initialize_Slots()
	#_initialize_sell_Slots()
	initialize_inventory()

func _reset_seller_ui()->void:
	#Load seller stuff
	_initialize_sell_Slots()
	_on_market_item_refresh_money_cntr()
	initialize_sell_inventory_2()
	reset_sell_qty_labels()


### - SELLING SECTION
func initialize_sell_inventory_2():
	#Player Inventory Slots
	for i in range(slots_inv_sell2.size()):
		if PInv.PIO.DATA.has(i):
			if PInv.PIO.DATA[i][1] == 0:
				slots_inv_sell2[i].reset_Slot()
			else:
				slots_inv_sell2[i].initialize_item(PInv.PIO.DATA[i][0], PInv.PIO.DATA[i][1])
		else:
			slots_inv_sell2[i].reset_Slot()
	first_time_flag = false

func _initialize_sell_Slots():
	# setup for keypress or click events when using slots
	for i in range(slots_inv_sell2.size()):
		if slots_inv_sell2[i].is_connected("gui_input",slot_gui_input_sell.bind(slots_inv_sell2[i])):
			slots_inv_sell2[i].gui_input.disconnect(slot_gui_input_sell.bind(slots_inv_sell2[i]))
		if slots_inv_sell2[i]:
			slots_inv_sell2[i].slot_index = i
			slots_inv_sell2[i].slotType = SlotClass.SlotType.INVENTORY
			slots_inv_sell2[i].gui_input.connect(slot_gui_input_sell.bind(slots_inv_sell2[i]))

func sell_item_clicked(slot: SlotClass):
	#if already set for sale, reset. else, continue
	if sell_quantity_container[slot.slot_index].get_child(0).self_modulate.a == 1:
		#reset
		sell_quantity_container[slot.slot_index].get_child(0).text = "0"
		sell_quantity_container[slot.slot_index].get_child(0).self_modulate.a = 0
		# remove item from selling list
		for m in items_to_be_sold:
			if m.invSlotNum == slot.slot_index:
				items_to_be_sold.erase(m)
	else:
		open_sell_menu(slot)

func reset_sell_qty_labels():
	for i in range(sell_quantity_container.size()):
		sell_quantity_container[i].get_child(0).self_modulate.a = 0

func open_sell_menu(slot: SlotClass):
	#open UI
	input_escape_lock = true
	Events.emit_signal("GenStore_OnEscape_KeepOpen")
	
	market_item_sell_ui.visible = true
	market_item_sell_ui.set_itemName(Jsondata.getItemName_from_id(slot.item.item_name))
	market_item_sell_ui.set_slotQuantity(slot.item.item_quantity)
	market_item_sell_ui.initialize()
	market_item_sell_ui.set_slotNode(slot)

func commence_selling():
	var value_amt = 0
	for ware_item in items_to_be_sold:
		var qty_sold = ware_item.sellQty
		var qty_inv = PInv.PIO.DATA[ware_item.invSlotNum][1]
		if qty_sold == qty_inv:
			# remove whole slot
			PInv.InventoryItem_RemoveProperly(ware_item.invSlotNum)
			# if referenced on hotbar, remove connection
			if PInv.check_is_in_hbref_table(ware_item.invSlotNum):
				PInv.HotbarRef_RemoveProperly(ware_item.invSlotNum)
				#PInv.HB.DATA.erase(ware_item.invSlotNum)
		else:
			# deduct qty from slot
			PInv.PIO.DATA[ware_item.invSlotNum][1] -= qty_sold
		value_amt += int(calc_net_gain(ware_item.ItemName,qty_sold))
	# update money
	Global.PLAYER_MONEY += value_amt
	txt_sell_amount.text = "0"
	items_to_be_sold = []
	_on_market_item_refresh_money_cntr()
	# update UI and refresh inventory
	_reset_seller_ui()
	# update buying inventory stock list
	initialize_inventory()


### - BUYING SECTION
func _load_merchant_wares():
	clear_list()
	load_merchandise()
	print("Merch loaded into List")

func _initialize_Slots():
	# setup for keypress or click events when using slots
	for i in range(slots_inv.size()):
		slots_inv[i].slot_index = i
		slots_inv[i].slotType = SlotClass.SlotType.INVENTORY
		if !slots_inv[i].is_connected("gui_input", slot_gui_input.bind(slots_inv[i])):
			slots_inv[i].gui_input.connect(slot_gui_input.bind(slots_inv[i]))

func initialize_inventory():
	#Player Inventory Slots
	for i in range(slots_inv.size()):
		if PInv.PIO.DATA.has(i):
			if PInv.PIO.DATA[i][1] == 0:
				slots_inv[i].reset_Slot()
			else:
				slots_inv[i].initialize_item(PInv.PIO.DATA[i][0], PInv.PIO.DATA[i][1])
		else:
			slots_inv[i].reset_Slot()

func clear_list() -> void:
	for m in merch_list.get_children():
		m.free()

func load_merchandise() -> void:
	var list_pos = Vector2.ZERO
	var padding_bottom: int = 54
	for n in merchant_wares:
		var id_to_nm = Jsondata.getItemName_from_id(n)
		_load_merch_item(id_to_nm,merchant_wares[n],list_pos)
		list_pos = Vector2(list_pos.x,list_pos.y+padding_bottom)

func _load_merch_item(itm,qty,loc: Vector2)->void:
	var merch = load("res://Scenes/Levels/general_store/market_item.tscn").instantiate()
	merch.custom_minimum_size.y = 50
	merch.nm =  str(itm)
	merch.typ =  str(itm)
	merch.qty = qty
	merch.global_position = loc
	merch_list.add_child(merch)
	merch.connect("init_market_ui_inv", _on_market_item_init_market_ui_inv)
	merch.connect("refresh_money_cntr", _on_market_item_refresh_money_cntr)

func calc_selling_total2()->void:
	var tot_for_selling: int = 0
	for itm in items_to_be_sold:
		tot_for_selling += int(calc_net_gain(itm.ItemName,itm.sellQty))
	txt_sell_amount.text = str(tot_for_selling)

func calc_net_gain(item_nm,qty):
	var itm_resource_id = Jsondata.getItemID_from_name(str(item_nm))
	#var itm_resource_id = str(item_nm)
	var itm_resource = Jsondata.getItemObject_fromID(itm_resource_id)
	var base_value: int = itm_resource.value
	if base_value:
		return base_value * qty
	else:
		return 0


### - CONNECTED FUNCTIONS
func _on_visibility_changed():
	$CanvasLayer.visible = self.visible

func _on_market_item_init_market_ui_inv():
	initialize_inventory()

func _on_market_item_refresh_money_cntr():
	$CanvasLayer/TabContainer/BUY/MoneyCounterUI/txtMONEY.text = str(Global.PLAYER_MONEY)
	$CanvasLayer/TabContainer/SELL/MoneyCounterUI/txtMONEY.text = str(Global.PLAYER_MONEY)

func _on_market_item_sell_ui_build_selling_block(nm, qty, slot_num):
	sell_quantity_container[slot_num].get_child(0).text = str(qty)
	sell_quantity_container[slot_num].get_child(0).self_modulate.a = 1
	
	var tmpDict: Dictionary = {
		"ItemName": nm,
		"sellQty": qty,
		"invSlotNum": slot_num
	}
	
	# Dup check here
	var dupFound: bool = false
	for M in items_to_be_sold:
		if M["ItemName"] == tmpDict["ItemName"] and M["sellQty"] == tmpDict["sellQty"] and M["invSlotNum"] == tmpDict["invSlotNum"]:
			dupFound = true
	
	if !dupFound:
		items_to_be_sold.append(tmpDict)
	
	calc_selling_total2()
	Events.emit_signal("GenStore_OnEscape_OkayToClose")

func _on_btn_sell_all_items_in_list_pressed():
	commence_selling()

func _on_tab_container_tab_changed(tab: int) -> void:
	match tab:
		0:
			# BUY tab selected
			_reset_buyer_ui()
		1:
			# SELL tab selected
			_reset_seller_ui()
