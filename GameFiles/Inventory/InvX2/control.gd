extends Control

#var res1: String = "res://Inventory/ItemResources/crop_carrot.tres"
#var res2: String = "res://Inventory/ItemResources/crop_tomato.tres"
#var res3: String = "res://Inventory/ItemResources/seeds_strawberry.tres"
#var res4: String = "res://Inventory/ItemResources/seeds_turnip.tres"


var inventory : Array[OptiInventorySlot] = []

func _ready():
	_load_slots_from_save()


func bind_inventory(inv):
	var ui_slots = $InventoryContainerUI.get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])
	print("inventory binded")


func _reset_inventory():
	_load_slots_from_save()


func _load_slots_from_save():
	inventory.resize(Global.PLAYER_INVENTORY_TEST.size())
	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()
	
	bind_inventory(inventory)
	
	for j in Global.PLAYER_INVENTORY_TEST:
		if Global.PLAYER_INVENTORY_TEST[j][0] != null:
			var ui = $InventoryContainerUI
			ui._set_slot(j)
			inventory[j].set_item(load(Global.PLAYER_INVENTORY_TEST[j][0]))
			inventory[j].set_quantity(Global.PLAYER_INVENTORY_TEST[j][1])
