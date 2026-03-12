@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
class_name TestContainer extends GridContainer


var inventory : Array[OptiInventorySlot] = []


func _ready() -> void:
	_load_slots_from_save()

func _load_slots_from_save():
	inventory.resize(6)
	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()
	
	bind_inventory(inventory)
	
	for k in Global.STORAGE_TEST.size():
		inventory[k].set_item(load(Global.STORAGE_TEST[k][0]) if Global.STORAGE_TEST[k][0] else null)
		inventory[k].set_quantity(Global.STORAGE_TEST[k][1])


func bind_inventory(inv):
	var ui_slots = get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])
