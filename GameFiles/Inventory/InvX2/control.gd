extends Control

var res1: String = "res://Inventory/ItemResources/crop_carrot.tres"
var res2: String = "res://Inventory/ItemResources/crop_tomato.tres"
var res3: String = "res://Inventory/ItemResources/seeds_strawberry.tres"
var res4: String = "res://Inventory/ItemResources/seeds_turnip.tres"


var inventory : Array[InventorySlot] = []

func _ready():
	inventory.resize(10)
	for i in inventory.size():
		inventory[i] = InventorySlot.new()
	print("inventory loaded")
	bind_inventory(inventory)

func bind_inventory(inv):
	var ui_slots = $InventoryContainerUI.get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])
	print("inventory binded")
