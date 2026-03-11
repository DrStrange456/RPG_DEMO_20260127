extends GridContainer

var res1: String = "res://Inventory/ItemResources/crop_carrot.tres"
var res2: String = "res://Inventory/ItemResources/crop_tomato.tres"
var res3: String = "res://Inventory/ItemResources/seeds_strawberry.tres"
var res4: String = "res://Inventory/ItemResources/seeds_turnip.tres"


var inventory : Array[OptiInventorySlot] = []


func _ready() -> void:
	_load_slots_from_save()

func _load_slots_from_save():
	inventory.resize(6)
	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()
	
	bind_inventory(inventory)
	
	inventory[0].set_item(load(res2))
	inventory[0].set_quantity(10)
	inventory[1].set_item(load(res3))
	inventory[1].set_quantity(4)
	inventory[2].set_item(load(res3))
	inventory[2].set_quantity(12)
	inventory[3].set_item(null)
	inventory[3].set_quantity(0)
	inventory[4].set_item(load(res4))
	inventory[4].set_quantity(5)
	inventory[5].set_item(load(res4))
	inventory[5].set_quantity(5)


func bind_inventory(inv):
	var ui_slots = get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])
