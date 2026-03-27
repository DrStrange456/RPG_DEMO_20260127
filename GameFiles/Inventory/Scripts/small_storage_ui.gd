extends Control

@onready var inventory_container_ui: GridContainer = $InventorySlotContainer
@onready var test_container: TestContainer = $SmallContainer

var inventory : Array[OptiInventorySlot] = []

func _ready():
	_load_slots_from_save()


func bind_inventory(inv):
	var ui_slots = $InventorySlotContainer.get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])

func _reset_inventory():
	_load_slots_from_save()

func _load_slots_from_save():
	# build out inventory data structure
	inventory.resize(Global.PLAYER_INVENTORY_TEST.size())
	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()
	
	# bind the data structure to the ui
	bind_inventory(inventory)
	
	# load data and ui
	for j in Global.PLAYER_INVENTORY_TEST:
		# - DATA
		if Global.PLAYER_INVENTORY_TEST[j][0] != null:
			if int(Global.PLAYER_INVENTORY_TEST[j][1]) > 0:
				inventory[j].indx = j
				inventory[j].set_item(load(Global.PLAYER_INVENTORY_TEST[j][0]))
				inventory[j].set_quantity(Global.PLAYER_INVENTORY_TEST[j][1])
		# - UI
		var ui = $InventorySlotContainer
		ui._set_slot(j)

func _refresh_inventory_items():
	_load_slots_from_save()



func _on_btn_sort_chest_pressed() -> void:
	StorageManager.sort_and_combine_inventory_Strg(test_container)

func _on_btn_sort_inv_pressed() -> void:
	StorageManager.sort_and_combine_inventory_Inv(Global.PLAYER_INVENTORY_TEST)
	_refresh_inventory_items()

func _on_btn_transfer_all_pressed() -> void:
	StorageManager.move_all_to_inventory(test_container.get_children(),Global.PLAYER_INVENTORY_TEST)
	_refresh_inventory_items()

func _on_btn_transfer_like_pressed() -> void:
	StorageManager.collect_similar_from_chest(test_container.get_children(),Global.PLAYER_INVENTORY_TEST)
	_refresh_inventory_items()




### - Context Menu Options
func _on_btn_move_pressed() -> void:
	StorageManager._handle_move_action()
