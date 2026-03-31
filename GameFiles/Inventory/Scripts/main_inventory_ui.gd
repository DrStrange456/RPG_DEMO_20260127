extends Control

@onready var btn_move: Label = $SlotActions/HBoxContainer/btnMove
@onready var btn_swap: Label = $SlotActions/HBoxContainer/btnSwap
@onready var btn_combine: Label = $SlotActions/HBoxContainer/btnCombine
@onready var btn_split: Label = $SlotActions/HBoxContainer/btnSplit


@onready var main_inventory_container_ui: GridContainer = $MainInventoryController
var inventory : Array[OptiInventorySlot] = []


func _ready() -> void:
	_load_slots_from_save()


func bind_inventory(inv):
	var ui_slots = main_inventory_container_ui.get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])


func _load_slots_from_save():
	inventory.resize(Global.PLAYER_INVENTORY_TEST.size())
	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()
	
	bind_inventory(inventory)
	
	for j in Global.PLAYER_INVENTORY_TEST:
		for i in main_inventory_container_ui.get_child_count():
			main_inventory_container_ui._set_slot(i)
		if Global.PLAYER_INVENTORY_TEST[j][0] != null:
			if int(Global.PLAYER_INVENTORY_TEST[j][1]) > 0:
				inventory[j].indx = j
				inventory[j].set_item(load(Global.PLAYER_INVENTORY_TEST[j][0]))
				inventory[j].set_quantity(Global.PLAYER_INVENTORY_TEST[j][1])


func _on_btn_sort_inv_pressed() -> void:
	StorageManager.sort_and_combine_inventory_Inv(Global.PLAYER_INVENTORY_TEST)
	AudioController.play_sound("sfx_slots_reorder")
	_refresh_inventory_items()

func _refresh_inventory_items():
	_load_slots_from_save()
