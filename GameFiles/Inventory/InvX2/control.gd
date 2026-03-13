extends Control

@onready var inventory_container_ui: GridContainer = $InventoryContainerUI
@onready var test_container: TestContainer = $SmallContainer

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
		var ui = $InventoryContainerUI
		ui._set_slot(j)
		if Global.PLAYER_INVENTORY_TEST[j][0] != null:
			inventory[j].indx = j
			inventory[j].set_item(load(Global.PLAYER_INVENTORY_TEST[j][0]))
			inventory[j].set_quantity(Global.PLAYER_INVENTORY_TEST[j][1])


func _refresh_inventory_items():
	_load_slots_from_save()




func _on_btn_sort_chest_pressed() -> void:
	StorageHandler.sort_and_combine_inventory_Strg(test_container)


func _on_btn_sort_inv_pressed() -> void:
	StorageHandler.sort_and_combine_inventory_Inv(Global.PLAYER_INVENTORY_TEST)
	_refresh_inventory_items()


func _on_btn_transfer_all_pressed() -> void:
	#StorageHandler.collect_all_from_container(test_container,Global.PLAYER_INVENTORY_TEST)
	StorageHandler.move_all_to_inventory(test_container.get_children(),Global.PLAYER_INVENTORY_TEST)
	_refresh_inventory_items()


func _on_btn_transfer_like_pressed() -> void:
	pass # Replace with function body.
