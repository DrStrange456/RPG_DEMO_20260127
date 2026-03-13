class_name inventory_api
extends Node

var grid_node: GridContainer


func _ready() -> void:
	_pInvData_Initialize(Global.NUMBER_ACTIVE_INVENTORY_SLOTS,Global.PLAYER_INV_SLOTS_ENABLED,grid_node,slot_gui_input)


func _pInvData_Initialize(_numTotalSlots: int, _numUnlocked: int, _target_grid: GridContainer, _sgi):
	_pInvData_Load_Save_toMemory()

func _pInvData_Load_Save_toMemory():
	var slots_open = Global.NUMBER_ACTIVE_INVENTORY_SLOTS
	var _slots_max = Global.PLAYER_INV_SLOTS_ENABLED
	
	for S in slots_open:
		var _is_slot_enabled: bool = true
		var itm_name = Global.PLAYER_INVENTORY[S][0]
		var itm_qty = Global.PLAYER_INVENTORY[S][1]
		var itm_enabled = Global.PLAYER_INVENTORY[S][2]
		
		# Convert item from string to object
		var tmp_itm = get_item_from_name(itm_name)
		append_new_slot(S, tmp_itm, itm_qty, itm_enabled)
	
	print("Inventory data loaded from Global")

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

func append_new_slot(slotIndex: int, itm, qty: int, isEnabled: bool):
	InventoryData.add_slot(isEnabled, slotIndex)  # Adds an enabled slot
	InventoryData.add_slot_item(slotIndex, itm.name, qty)

func slot_gui_input(_event: InputEvent, _btn: Button):
	pass
