class_name insta_inventory
extends Node

# This class is where the low level nodes go to interact with the inventory db
# Methods are meant to be as basic and multifunctional as possible

# UI and DATA are handled here

var new_item = preload("res://Inventory/item.tscn")
var blank_item = preload("res://Inventory/ItemResources/blank_item.tres")
var new_button = preload("res://Inventory/btn_slot.tscn")
var new_slot = preload("res://Inventory/slot.tscn")

enum SlotType {
	INVENTORY,
	STORAGE
}


# BASIC API FUNCTIONS
# IN - Total Slots, Num Slots unlocked (optional), Grid node to populate inventory to, Slot GUI Input
func _api_pInvData_Initialize(numTotalSlots: int, _numUnlocked: int, target_grid: GridContainer, sgi):
	clear_inv_ui_slots(target_grid)
	construct_ui(numTotalSlots,target_grid,sgi)
	_pInvData_Load_Save_toMemory()
	populate_ui_nodes_per_Inv_data(target_grid)

func _api_pHotbarData_Initialization(target_grid: GridContainer):
	populate_hb_nodes_per_data(target_grid)

# - - - CORE BUILDING FUNCTIONS - - -
func append_new_slot(slotIndex: int, itm, qty: int, isEnabled: bool):
	Inventory.add_slot(isEnabled, slotIndex)  # Adds an enabled slot
	Inventory.add_slot_item(slotIndex, itm.name, qty)

func clear_inv_ui_slots(target_grid: GridContainer):
	for N in target_grid.get_children():
		N.free()

func construct_ui(num_slots: int, target_grid: GridContainer, sgi):
	for i in range(num_slots):
		var new_button_insta = new_button.instantiate()
		new_button_insta.gui_input.connect(sgi.bind(new_button_insta))  # set input
		new_button_insta.custom_minimum_size = Vector2(40,40)
		new_button_insta.toggle_mode = true
		new_button_insta.add_to_group("inventory_slot")
		if new_button_insta.has_signal("slot_focused"):
			new_button_insta.connect("slot_focused", Callable(self, "_on_slot_focused"))
		
		var slot = new_slot.instantiate()
		slot.slot_index = i
		slot.slotType = SlotType.INVENTORY
		slot.custom_minimum_size = Vector2(40,40)
		
		var itm = new_item.instantiate()
		
		target_grid.add_child(new_button_insta)
		new_button_insta.add_child(slot)
		slot.add_child(itm)

func populate_ui_nodes_per_Inv_data(target_grid: GridContainer):
	var buttons = target_grid.get_children()
	for j in range(Inventory.slots.size()):
		if _slot_GetSlotItem(buttons[j]) != null:
			var refSlot = _slot_GetBaseSlot(buttons[j])
			var tmp = Inventory.slots[j]
			var tmp_ui = _slot_GetSlotItem(buttons[j])
			
			# Clear the default data
			tmp_ui._set_texture(null)
			tmp_ui._set_quantity(0)
			
			if tmp.item != blank_item:
				if tmp.item != null: 
					# If this is null, this is likely a disabled slot
					refSlot.item = tmp.item
					tmp_ui._set_texture(tmp.item.icon)
					tmp_ui._set_quantity(tmp.quantity)
			refSlot.refresh_style()

func populate_hb_nodes_per_data(_target_grid: GridContainer):
	#var buttons = target_grid.get_children()
	#for j in range(Global.PLAYER_HOTBAR.size()):
		#var tmp_slot = _slot_GetBaseSlot(buttons[j])
		#var itm = new_item.instantiate()
		#tmp_slot.add_child(itm)
		#
		#var tmp = Global.PLAYER_HOTBAR[j]
		#var nm = tmp[0]
		#var tmp_item = get_item_from_name(nm)
		#var tmp_qty = tmp[1]
		#
		#tmp_slot.item = tmp_item
		#itm._set_texture(tmp_item.icon)
		#itm._set_quantity(tmp_qty)
	pass


func _pInvData_Save_toMemory(_target_grid: GridContainer):
	var TMP_PLAYER_INVENTORY: Dictionary = {}
	
	var tmpIdx: int = 0
	for S in Inventory.slots:
		if S.item != null:
			var itm_name = S.item.name
			var itm_qty = S.quantity
			var itm_enabled = S.enabled
			TMP_PLAYER_INVENTORY[tmpIdx] = [itm_name, itm_qty, itm_enabled]
			tmpIdx += 1
	Global.PLAYER_INVENTORY = TMP_PLAYER_INVENTORY
	# Add in inactive slots
	var diff = Global.PLAYER_INV_SLOTS_MAX - TMP_PLAYER_INVENTORY.size()
	for S in range(diff):
		TMP_PLAYER_INVENTORY[tmpIdx] = ["", 0, false]
		tmpIdx += 1
	print("Inventory data saved to Global")

func _pInvData_Load_Save_toMemory():
	var slots_open = Global.PLAYER_INV_SLOTS_UNLOCKED
	var _slots_max = Global.PLAYER_INV_SLOTS_MAX
	
	for S in slots_open:
		var _is_slot_enabled: bool = true
		var itm_name = Global.PLAYER_INVENTORY[S][0]
		var itm_qty = Global.PLAYER_INVENTORY[S][1]
		var itm_enabled = Global.PLAYER_INVENTORY[S][2]
		
		# Convert item from string to object
		var tmp_itm = get_item_from_name(itm_name)
		append_new_slot(S, tmp_itm, itm_qty, itm_enabled)
	
	print("Inventory data loaded from Global")


### - OTHER
func _slot_GetBaseSlot(btn: Button)->Panel:
	if btn.get_child_count() > 0:
		var baseSlot = btn.get_child(0)
		if baseSlot:
			return baseSlot
	return null

func _slot_GetSlotItem(btn: Button)->Node2D:
	if btn.get_child_count() > 0:
		var baseSlot = btn.get_child(0)
		if baseSlot.get_child_count() > 0:
			var chldItem = baseSlot.get_child(0)
			if chldItem:
				return chldItem
	return null


func get_item_from_name(itm_name: String) -> Item:
	# called name returns Name value from Resource
	var name_map := {
		"Fire Sword":"Fire Sword",
		"wood": "Wood",
		"Wood": "Wood",
		"sword": "Basic Sword",
		"Basic Sword": "Basic Sword",
		"StrawberrySeeds": "StrawberrySeeds",
		"CarrotSeeds": "CarrotSeeds",
		"TomatoSeeds": "TomatoSeeds",
		"TurnipSeeds": "TurnipSeeds",
		"Gem_Purple": "Gem_Purple",
		"Gem_Silver": "Gem_Silver",
		"CarrotCrop": "CarrotCrop",
		"StrawberryCrop": "StrawberryCrop",
		"TomatoCrop": "TomatoCrop",
		"TurnipCrop": "TurnipCrop",
		"Basic Hat": "Basic Hat",
		"bomb_small": "bomb_small",
	}

	var canonical_name = name_map.get(itm_name, "")
	if canonical_name:
		return GlobalItemDB.get_item_by_name(canonical_name)
	else:
		return GlobalItemDB.get_item_by_name(itm_name)

func _translate_seed_nm_to_plant_nm(itm_name: String) -> String:
	# called name returns Name value from Resource
	var name_map := {
		"seeds_carrot":"carrot",
	}

	var canonical_name = name_map.get(itm_name, "")
	return canonical_name
