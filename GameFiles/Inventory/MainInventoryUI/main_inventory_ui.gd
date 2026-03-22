extends Control

@onready var btn_move: Label = $SlotActions/HBoxContainer/btnMove
@onready var btn_swap: Label = $SlotActions/HBoxContainer/btnSwap
@onready var btn_combine: Label = $SlotActions/HBoxContainer/btnCombine
@onready var btn_split: Label = $SlotActions/HBoxContainer/btnSplit


@onready var main_inventory_container_ui: GridContainer = $MainInventoryController
var inventory : Array[OptiInventorySlot] = []


func _ready() -> void:
	#_lightup_move(false)
	#_lightup_swap(false)
	#_lightup_combine(false)
	#_lightup_split(false)
	
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


func bind_inventory(inv):
	var ui_slots = main_inventory_container_ui.get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])

#
#func _lightup_move(val):
	#btn_move.visible = val
#
#func _lightup_swap(val):
	#btn_swap.visible = val
#
#func _lightup_combine(val):
	#btn_combine.visible = val
#
#func _lightup_split(val):
	#btn_split.visible = val
