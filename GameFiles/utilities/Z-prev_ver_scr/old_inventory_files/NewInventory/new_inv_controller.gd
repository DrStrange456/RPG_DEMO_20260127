extends Control

@onready var hb_slot_selection: Control = $"../set_hotbar_slot_ui"
@onready var inventory_container = $InventoryContainer
@onready var slots_inv = inventory_container.get_children()
@onready var cms_options = $"../cmsOPTIONS"
@onready var item_split_ui: Control = $"../item_split_ui"


const SlotClass = preload("res://GameData/NewInventory/new_slot.gd")
const ItemClass = preload("res://GameData/NewInventory/item.gd")

var holding_item = null
var originating_slot = -1
var orig_hb_assign
var slot_clicked

enum SlotType {
	HOTBAR = 0,
	INVENTORY,
	STORAGE
}


func _ready():
	# TODO:
	# Loading INV and HB at runtime for testing, change to load on
	# Visibility change in future
	PInv.PIO._load(Global.PLAYER_INVENTORY)
	PInv.HB._load(Global.PLAYER_HOTBAR_NEW)
	_setup_slot_clicks()
	initialize_inventory()

func _process(_delta):
	# Set item in holding to mouse position
	if holding_item != null:
		holding_item.position = get_local_mouse_position() - Vector2(20,20)

func _input(event):
	if self.visible:
		if event is InputEventKey:
			if event.is_action_pressed("options_menu"):
				#if cms_options.visible:
				if Global.flag_enable_options_menu:
					cms_options.show()
					get_viewport().set_input_as_handled()
			# Handling navigation with Keyboard/Controller pads
			if event.is_action_pressed("ui_left"):
				if PInv.active_item_slot_Inventory > 0:
					if (PInv.active_item_slot_Inventory) % inventory_container.columns != 0:
						PInv.active_item_slot_Inventory -=1
				get_viewport().set_input_as_handled()
			if event.is_action_pressed("ui_right"):
				if PInv.active_item_slot_Inventory < slots_inv.size()-1:
					if (PInv.active_item_slot_Inventory + 1) % inventory_container.columns != 0:
						PInv.active_item_slot_Inventory +=1
				get_viewport().set_input_as_handled()
			if event.is_action_pressed("ui_up"):
				if PInv.active_item_slot_Inventory - inventory_container.columns > -1:
					PInv.active_item_slot_Inventory -= inventory_container.columns
				get_viewport().set_input_as_handled()
			if event.is_action_pressed("ui_down"):
				if PInv.active_item_slot_Inventory + inventory_container.columns < slots_inv.size():
					PInv.active_item_slot_Inventory += inventory_container.columns
				get_viewport().set_input_as_handled()







## MAIN FUNCTIONS

func _setup_slot_clicks():
	for i in range(slots_inv.size()):
		slots_inv[i].slot_index = i
		slots_inv[i].slotType = SlotClass.SlotType.INVENTORY
		slots_inv[i].gui_input.connect(slot_gui_input.bind(slots_inv[i]))
	initialize_inventory()

func _reset_slot_clicks():
	for i in range(slots_inv.size()):
		slots_inv[i].slot_index = i
		slots_inv[i].slotType = SlotClass.SlotType.INVENTORY
		if !slots_inv[i].is_connected("gui_input", slot_gui_input.bind(slots_inv[i])):
			slots_inv[i].gui_input.connect(slot_gui_input.bind(slots_inv[i]))
	initialize_inventory()

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			var slot_filled_before: bool = isItemInSlot(slot)
			kbm_input_left_click(event,slot)
			get_viewport().set_input_as_handled()
			var slot_filled_after: bool = isItemInSlot(slot)
			_trigger_sfx(slot_filled_before,slot_filled_after)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			kbm_input_right_click(event,slot)
			get_viewport().set_input_as_handled()


# - - - - - - - - - - - - - - - - - - -  - - -
# - - - KEYBOARD AND MOUSE INPUT DEFAULT - - -
# - - - - - - - - - - - - - - - - - - -  - - -

func kbm_input_right_click(_event,slot):
	var slot_item_qty: Array  = PInv.PIO._get_value_at_key(slot.slot_index)
	slot_clicked = slot
	cms_options.set_item_disabled(0, int(slot_item_qty[1]) <= 1)
	cms_options.show()

func kbm_input_left_click(event: InputEvent, slot: SlotClass) -> void:
	PInv.active_item_slot_Inventory = slot.slot_index
	var action_to_take: int = 0
	if holding_item != null:
		if !isItemInSlot(slot):
			action_to_take = 1
		else:
			if holding_item.item_name != slot.item.item_name:
				action_to_take = 2
			else:
				action_to_take = 3
	elif slot != null and slot.item:
			action_to_take = 4
	
	match action_to_take:
		1:
			Left_Click_Empty_Slot(slot)
		2:
			Left_Click_Different_Item(event, slot)
		3:
			left_click_same_item(slot)
		4:
			Left_Click_Not_Holding(slot)



# *** LEFT CLICKS ***
func Left_Click_Not_Holding(slot: SlotClass):
	match(slot.slotType):
		SlotType.INVENTORY:
			pickItemFromInventory(slot)
			record_original_slot(slot)
			record_original_hb_assignment(slot)
func Left_Click_Empty_Slot(slot: SlotClass):
	match(slot.slotType):
		SlotType.INVENTORY:
			putItemInEmptySlot_Inventory(holding_item, slot)
			set_HB_Assignment(slot)
func left_click_same_item(slot: SlotClass):
	match(slot.slotType):
		SlotType.INVENTORY:
			handle_slotClick_SameItem_Inventory(slot)
func Left_Click_Different_Item(event: InputEvent, slot: SlotClass):
	match(slot.slotType):
		SlotType.INVENTORY:
			invAction_SwapItems(slot, event)






## APPROVED SUPPORT FUNCTIONS

# INV L-click
func invAction_SwapItems(slot: SlotClass, _event: InputEvent):
	# Update Data
	var prev_orig_hb_assign = orig_hb_assign
	record_original_hb_assignment(slot)
	PInv.replace_Item_in_Inventory_Slot(holding_item,slot)
	# Update UI
	# (slot -> temp, mouse -> slot, temp -> mouse)
	var curr_item = slot.item
	var temp_item = holding_item
	slot.pickItemFromSlot()
	slot.putItemIntoSlot(temp_item)
	holding_item = curr_item
	# Set HB Assignment
	var tmp_hb_value = slot.slot_index
	var tmp_hb_key = prev_orig_hb_assign
	PInv.HB._set_value_at_key(tmp_hb_key,tmp_hb_value)
	
func pickItemFromInventory(slot: SlotClass):
	# Update Data
	PInv.InventoryItem_RemoveProperly(slot.slot_index)
	# Update UI
	slot.pickItemFromSlot()
	initialize_inventory()
func putItemInEmptySlot_Inventory(itemSRC: ItemClass, slotDEST: SlotClass) -> void:
	# Update Data
	PInv.insert_Item_intoEmpty_Inventory_Slot(itemSRC, slotDEST)
	# Update UI
	slotDEST.putItemIntoSlot(itemSRC)
	holding_item = null
	initialize_inventory()
func handle_slotClick_SameItem_Inventory(slot: SlotClass):
	# Manipulate data in memory only, then refresh UI
	var item_name = PInv.PIO._get_value_at_key(slot.slot_index)[0]
	var item_quantity = PInv.PIO._get_value_at_key(slot.slot_index)[1]
	var max_stack_size = load("res://Resources/" + item_name + ".tres").max_stack_size
	var room_to_add = max_stack_size - item_quantity
	if room_to_add >= holding_item.item_quantity:
		invAction_Add_Full_Amount_to_Slot(slot)
	else:
		invAction_Add_What_will_Fit_to_Slot(slot, room_to_add)
	initialize_inventory()
func invAction_Add_Full_Amount_to_Slot(slot: SlotClass):
	# Combine full count to item in slot
	# Update Data
	PInv.increment_ItemByAmount(slot, holding_item.item_quantity)
	# Update UI
	holding_item.free()
	holding_item = null
func invAction_Add_What_will_Fit_to_Slot(slot: SlotClass, able_to_add: int):
	# Add what will fit to slot
	# Update Data
	PInv.increment_ItemByAmount(slot, able_to_add)
	# Update UI
	holding_item.decrease_item_quantity(able_to_add)

# MISC
func initialize_inventory() -> void:
	if slots_inv:
		#Player Inventory Slots
		for i in range(slots_inv.size()):
			if PInv.PIO._is_valid_key(i):
				#var test_name = str(PInv.PIO._get_value_at_key(i)[0])
				slots_inv[i].initialize_item(str(PInv.PIO._get_value_at_key(i)[0]), PInv.PIO._get_value_at_key(i)[1])
			else:
				slots_inv[i].reset_Slot()
		refresh_hb_assign_icons()
		refresh_textures()
func refresh_textures()->void:
	# Refreshing the sprite textures from the resources
	for n in inventory_container.get_children():
		if n.has_method("load_item_img"):
			n.load_item_img()
			n.refresh_style()
func refresh_hb_assign_icons():
	for n in inventory_container.get_children():
		if n.get_class() == "Panel":
			# Using slot number...
			var sn = n.slot_index
			# if hotbar has slot number assigned, update items hb index value
			if PInv.HB._does_contain_reference(sn):
				var key = PInv.HB._get_key_at_value(sn)
				if key or key == 0:
					set_HB_slot_num(n, key)
				else:
					# No assignment, hide icon
					set_HB_slot_num(n, -1)
			else:
				# No assignment, hide icon
				set_HB_slot_num(n, -1)
func set_HB_slot_num(slotDEST: SlotClass, newVal: int):
	if slotDEST.item:
		slotDEST.item.hb_slot = newVal
		slotDEST.item.refresh_hb_lbl()
func isItemInSlot(slot: SlotClass) -> bool:
	#Item is there and the item has an item_name
	var result = false
	if slot:
		if slot.item != null:
			if slot.item.item_name != null:
				result = true
	return result
func record_original_slot(slot) -> void:
	originating_slot = slot.slot_index
func get_slot_clicked():
	return slot_clicked
func record_original_hb_assignment(slot)->void:
	var tmp_hb_value = slot.slot_index
	var tmp_hb_key = PInv.HB._get_key_at_value(tmp_hb_value)
	orig_hb_assign = tmp_hb_key
	#print(tmp_hb_value,tmp_hb_key)
func set_HB_Assignment(slot)->void:
	var tmp_hb_value = slot.slot_index
	var tmp_hb_key = orig_hb_assign
	PInv.HB._set_value_at_key(tmp_hb_key,tmp_hb_value)
	initialize_inventory()

# CONTEXT MENU STRIP
func _on_cms_options_id_pressed(id: int) -> void:
	# ID of 0 = Split option, 1 = Set Hotbar option
	match id:
		0:
			_show_split_menu()
		1:
			_add_slot_to_Hotbar()
func _add_slot_to_Hotbar():
	#first check if slot is already assigned
	var src_slot_number = slot_clicked.slot_index
	if PInv.HB._does_contain_reference(src_slot_number):
		print("Slot already assigned, Reassigning")
	# check if there are any slots available (up to 8)
	# player can choose one to get swapped out in next screen
	var slots_used = PInv.HB.DATA.keys().size()
	if slots_used >= Global.NUMBER_ACTIVE_HOTBAR_SLOTS:
		print("No Empty Hotbar Slots available")
	
	#if not, proceed to open Selection screen
	hb_slot_selection._set_references(src_slot_number)
	hb_slot_selection.visible = true
func _show_split_menu():
	# item name => resource file (ex: 2203_seeds_strawberry)
	var max_stack_size = int(PInv.PIO.DATA[slot_clicked.slot_index][1])
	item_split_ui._set_name(slot_clicked.item.item_name)
	item_split_ui._set_slot_index(slot_clicked.slot_index)
	item_split_ui._set_max_qty(max_stack_size)
	item_split_ui.visible = true


func _remove_slot_from_Hotbar():
	#slot_clicked.item.hb_slot = -1
	#slot_clicked.item.refresh_hb_lbl()
	pass
func _on_set_hotbar_slot_ui_hbref_changes_made() -> void:
	initialize_inventory()
func get_ResourceIconImage(itmName: String)->int:
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
	return item_res.max_stack_size
func _on_item_split_ui_split_activated(itm1: String, amt1: int, _idx_source: int) -> void:
	print("splitting item")
	# First, is slot available
	if !PInv.is_inv_slot_available():
		print("No Slots Available.  Aborting")
		return
	
	# 1) Create new slot item and add to inventory using 
	#     item name and quantity to be split
	# 2) Decrease amount in slot clicked by quantity to be split
	
	# Update Data
	PInv.inv_find_a_place(itm1, amt1)
	# Using increment function to subtract by using negative symbol
	PInv.increment_ItemByAmount(slot_clicked,-amt1)
	
	# Update UI
	initialize_inventory()


func _trigger_sfx(beef,aff)->void:
	# beef = slot filled before (T/F)
	# aff = slot filled after (T/F)
	if beef and !aff:
		#item was picked
		CommonFuncs.sfx_play("button_click", $"../sound_player")
	if !beef and aff:
		#item was pinned
		CommonFuncs.sfx_play("action_failed", $"../sound_player")
