class_name p_inv
extends Node

signal activeitem_Hotbar

const SlotClass = preload("res://Inventory/NewInventory/new_slot.gd")
const ItemClass = preload("res://Inventory/NewInventory/item.gd")


var PIO = player_inventory_object.new()
var HB = player_inventory_object.new()

var active_item_slot_Hotbar = 0
var active_item_slot_Inventory = 0
var active_item_slot_Storage = 0

var active_item_slot_Hotbar_name
var active_item_slot_Hotbar_type
var active_item_slot_Hotbar_speed
var active_item_slot_Hotbar_DamageMin
var active_item_slot_Hotbar_DamageMax
var active_item_slot_Hotbar_Capacity

var NUM_INVENTORY_SLOTS = Global.NUMBER_ACTIVE_INVENTORY_SLOTS
var NUM_HOTBAR_SLOTS = Global.NUMBER_ACTIVE_HOTBAR_SLOTS
var prev_slot_index
var hotbar_ref

var DATA: Dictionary = {}
var DATA_HB: Dictionary = {}

func _ready() -> void:
	PIO._load(DATA)
	HB._load(DATA_HB)


#FAVORITE: Hotbar Scrolling Actions
### Hotbar Related scrolling
func active_item_scroll_up() -> void:
	# No hotbar scrolling allowed
	if Global.flag_hotbar_change_lock: return
	
	#changing hotbar to hotbar_ref
	if (active_item_slot_Hotbar + 1) <= NUM_HOTBAR_SLOTS - 1:
		if hotbar_ref.has((active_item_slot_Hotbar + 1) % NUM_HOTBAR_SLOTS):
			setActiveItem_Hotbar((active_item_slot_Hotbar + 1) % NUM_HOTBAR_SLOTS)
		else:
			if active_item_slot_Hotbar + 1 < NUM_HOTBAR_SLOTS:
				if !hotbar_ref.has(active_item_slot_Hotbar + 1):
					active_item_slot_Hotbar = (active_item_slot_Hotbar + 1) % NUM_HOTBAR_SLOTS
					active_item_scroll_up()
func active_item_scroll_down() -> void:
	# No hotbar scrolling allowed
	if Global.flag_hotbar_change_lock: return

	#changing hotbar to hotbar_ref
	if active_item_slot_Hotbar <= 0:
		active_item_slot_Hotbar = 0
	else:
		if hotbar_ref.has(active_item_slot_Hotbar - 1):
			setActiveItem_Hotbar(active_item_slot_Hotbar - 1)
		else:
			if active_item_slot_Hotbar - 1 > 0:
				active_item_slot_Hotbar -= 1
				active_item_scroll_down()

#ADD
func add_item(item_name, item_quantity)->void:
	var itm_res_nm = PIO.get_ResourceItemName(item_name)
	var slot_indices: Array = PIO.DATA.keys()
	slot_indices.sort()
	# Iterate through each inventory slot
	for item in slot_indices:
		if str(PIO.DATA[item][0]) == itm_res_nm:
			var nm: String = itm_res_nm
			var stack_size = PIO.getStackLimit(nm)
			var able_to_add = stack_size - PIO.DATA[item][1]
			# Is amount to add more than stack size
			if able_to_add >= item_quantity:
				PIO.DATA[item][1] += item_quantity
				return
			else:
				PIO.DATA[item][1] += able_to_add
				item_quantity = item_quantity - able_to_add

	# item doesn't exist in inventory yet. put into empty slot
	for i in range(NUM_INVENTORY_SLOTS):
		if PIO.DATA.has(i) == false:
			PIO.DATA[i] = [itm_res_nm, item_quantity]
			return
func insert_Item_intoEmpty_Inventory_Slot(item: ItemClass, slot: SlotClass)->void:
	if slot and item:
		PIO._insert(slot.slot_index, [item.item_name, item.item_quantity])
func split_and_add_to_Inventory(idx: int, nm: String, qty: int)->void:
	PIO._insert(idx, [nm, qty])

#REMOVE
func InventoryItem_RemoveProperly(slot_num: int)->void:
	# Remove item from Inventory
	PIO._delete_at_index(slot_num)
	# Mark the slot number that item was removed from
	prev_slot_index = slot_num
func HotbarRef_RemoveProperly(slot_num: int)->void:
	#NOTE: slot_num comes in as value.  Must be converted to Dictionary Index
	# Remove item from Hotbar
	HB._delete_at_index(CommonFuncs.get_dictionary_key_from_value(HB.DATA,slot_num))
	# Mark the slot number that item was removed from
	prev_slot_index = slot_num


#UPDATE
func increment_ItemByAmount(slot: SlotClass, quantity_to_add: int)->void:
	PIO._update_amount_atIndex(slot.slot_index, quantity_to_add)
func replace_Item_in_Inventory_Slot(item: ItemClass, slot: SlotClass)->void:
	PIO._delete_at_index(slot.slot_index)
	if slot and item:
		PIO._set_value_at_key(slot.slot_index,[item.item_name, item.item_quantity])
func increment_ItemByAmount_byIndex(idx: int, quantity_to_add: int)->void:
	PIO._update_amount_atIndex(idx, quantity_to_add)



#MISC
func inv_find_a_place(item_name, item_quantity):
	#we have an empty slot somewhere, find the first one and stick it in
	for N in NUM_INVENTORY_SLOTS:
		if !PIO.DATA.has(N):
			PIO.DATA[N] = [item_name, item_quantity]
			return
func isSpaceAvailable(item_name, item_quantity) -> bool:
	if PIO._is_open_slot_available(): 
		return true
	return PIO._is_open_slot_with_matching_key(item_name,item_quantity)
func check_is_in_hbref_table(slot_idx):
	if hotbar_ref:
		if hotbar_ref.values().has(slot_idx):
			return hotbar_ref.find_key(slot_idx)
		else:
			return -1
	else:
		return -1
func is_inv_slot_available()->bool:
	var kys = PIO.DATA.keys().size()
	return kys < NUM_INVENTORY_SLOTS
func setActiveItem_Hotbar(idx: int):
	#used in number quick select actions
	active_item_slot_Hotbar = idx
	record_HB_ActiveItem_Info()
	emit_signal("activeitem_Hotbar")
func record_HB_ActiveItem_Info() -> void:
	hotbar_ref = PInv.HB.DATA.duplicate()
	
	#pointer is to player inventory, get name must reflect that
	if hotbar_ref.has(active_item_slot_Hotbar):
		var tmp = str(PInv.PIO.DATA[hotbar_ref[active_item_slot_Hotbar]][0])
		var hb_obj = Jsondata.getItemObject_fromID(tmp)
		if hb_obj:
			active_item_slot_Hotbar_name = hb_obj["name"]
			active_item_slot_Hotbar_type = hb_obj["item_category"]
			active_item_slot_Hotbar_speed = hb_obj["speed"]
			active_item_slot_Hotbar_DamageMin = hb_obj["damage_min"]
			active_item_slot_Hotbar_DamageMax = hb_obj["damage_max"]
			if hb_obj.has("water_capacity"):
				active_item_slot_Hotbar_Capacity = hb_obj["water_capacity"]
		else:
			push_warning("Item object not defined: " + str(tmp))
		
	Global.SELECTED_HB_ITEM_NAME = get_HB_ActiveItem_Name()
	Global.SELECTED_HB_ITEM_TYPE = get_HB_ActiveItem_Type()
func get_HB_ActiveItem_Name() -> String:
	if active_item_slot_Hotbar_name:
		return active_item_slot_Hotbar_name
	return ""
func get_HB_ActiveItem_Type() -> String:
	if active_item_slot_Hotbar_type:
		return active_item_slot_Hotbar_type
	return ""
func get_HB_ActiveItem_Speed() -> float:
	if active_item_slot_Hotbar_speed:
		return active_item_slot_Hotbar_speed
	return 1
func get_HB_ActiveItem_DamageMin() -> int:
	if active_item_slot_Hotbar_DamageMin:
		return active_item_slot_Hotbar_DamageMin
	return 1
func get_HB_ActiveItem_DamageMax() -> int:
	if active_item_slot_Hotbar_DamageMax:
		return active_item_slot_Hotbar_DamageMax
	return 1
func get_HB_ActiveItem_Capacity() -> int:
	if active_item_slot_Hotbar_Capacity:
		return active_item_slot_Hotbar_Capacity
	return 1
