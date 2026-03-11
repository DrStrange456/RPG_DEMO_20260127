extends GridContainer

#var res1: String = "res://Inventory/ItemResources/crop_carrot.tres"
#var res2: String = "res://Inventory/ItemResources/crop_tomato.tres"
#var res3: String = "res://Inventory/ItemResources/seeds_strawberry.tres"
#var res4: String = "res://Inventory/ItemResources/seeds_turnip.tres"


var inventory : Array[OptiInventorySlot] = []


func _ready() -> void:
	_load_slots_from_save()

func _load_slots_from_save():
	inventory.resize(6)
	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()
	
	bind_inventory(inventory)
	
	inventory[0].set_item(load(Global.INVENTORY_TEST[0][0]) if Global.INVENTORY_TEST[0][1] else null)
	inventory[0].set_quantity(Global.INVENTORY_TEST[0][1])
	inventory[1].set_item(load(Global.INVENTORY_TEST[1][0]) if Global.INVENTORY_TEST[1][1] else null)
	inventory[1].set_quantity(Global.INVENTORY_TEST[1][1])
	inventory[2].set_item(load(Global.INVENTORY_TEST[2][0]) if Global.INVENTORY_TEST[2][1] else null)
	inventory[2].set_quantity(Global.INVENTORY_TEST[2][1])
	inventory[3].set_item(load(Global.INVENTORY_TEST[3][1]) if Global.INVENTORY_TEST[3][1] else null)
	inventory[3].set_quantity(Global.INVENTORY_TEST[3][1])
	inventory[4].set_item(load(Global.INVENTORY_TEST[4][0]) if Global.INVENTORY_TEST[4][1] else null)
	inventory[4].set_quantity(Global.INVENTORY_TEST[4][1])
	inventory[5].set_item(load(Global.INVENTORY_TEST[5][0]) if Global.INVENTORY_TEST[5][1] else null)
	inventory[5].set_quantity(Global.INVENTORY_TEST[5][1])


func bind_inventory(inv):
	var ui_slots = get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])
