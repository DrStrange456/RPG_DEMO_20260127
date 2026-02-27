class_name player_inventory_object
extends Node

var DATA: Dictionary = {}


func _ready() -> void:
	pass


###
## SETTERS

func _delete_at_index(idx)->void:
	if DATA.has(idx):
		DATA.erase(idx)
		#CommonFuncs.write_log(true, "Inv item successfully removed", "info")

func _clear_all()->void:
	DATA = {}

func _load(dict: Dictionary):
	DATA = dict.duplicate()

func _set_value_at_key(ky, val)->void:
	if DATA:
		DATA[ky] = val

func _insert(ky, val)->void:
	if DATA:
		if val:
			DATA[ky] = val

func _update_amount_atIndex(ky, amt)->void:
	if DATA:
		if amt:
			DATA[ky][1] += amt


###
## GETTERS

func _does_contain_reference(val):
	if DATA:
		return DATA.values().has(val)

func _is_valid_key(ky):
	if DATA:
		return DATA.has(ky)

func _get_value_at_key(ky):
		if DATA:
			return DATA[ky]

func _get_key_at_value(val):
	if DATA:
		for N in DATA:
			if str(DATA[N]) == str(val):
				return N

func _is_open_slot_available()->bool:
	return DATA.keys().size() < Global.NUMBER_ACTIVE_INVENTORY_SLOTS

func _is_open_slot_with_matching_key(ky,qty)->bool:
	var slot_indices: Array = DATA.keys()
	slot_indices.sort()
	for item in slot_indices:
		# Is there a slot with a matching item name.  
		#  If so, is there also room to add
		if DATA[item][0] == ky:
			var stack_size = getStackLimit(ky)
			var able_to_add = stack_size - DATA[item][1]
			if able_to_add >= qty: 
				return true
	return false

func getStackLimit(item_name) -> int:
	return Jsondata.getItemMaxStackSize(Jsondata.getItemName_from_id(str(item_name)))

func get_ResourceItemName(itmName: String)->String:
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
	return item_res.idx
