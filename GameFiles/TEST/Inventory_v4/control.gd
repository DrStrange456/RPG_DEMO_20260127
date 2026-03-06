extends Control

@onready var inventory_container: InventoryContainer = $InventoryContainer
@onready var test_container: TestContainer = $SmallContainer

#@onready var inventory_slot: InvSlot = $InventoryContainer/InventorySlot


func _ready() -> void:
	_reset_inventory()


func _reset_inventory():
	_clear_all_slots()
	_load_slots_from_save()

func _clear_all_slots():
	# code for removing old slots and adding new ones
	# this makes the function dynamic in case the number changes
	for k in inventory_container.get_children():
		k.queue_free()

func _load_slots_from_save():
	await get_tree().process_frame  # without this the items would not load correctly
	for l in Global.PLAYER_INVENTORY_TEST:
		var new_slot = load("res://Inventory/InvX/inventory_slot.tscn").instantiate()
		new_slot.custom_minimum_size = Vector2(40,40)
		new_slot.indx = l
		new_slot.typ = Enum.SlotType.INVENTORY
		inventory_container.add_child(new_slot)
	
	inventory_container = $InventoryContainer
	await get_tree().process_frame  # without this the items would not load correctly
	for j in Global.PLAYER_INVENTORY_TEST:
		if Global.PLAYER_INVENTORY_TEST[j][0] != null:
			var new_item: Item = load(Global.PLAYER_INVENTORY_TEST[j][0])
			inventory_container._set_slot(j,new_item,Global.PLAYER_INVENTORY_TEST[j][1])
		else:
			inventory_container._set_slot(j,null,Global.PLAYER_INVENTORY_TEST[j][1])
	print("inventory loaded")
