extends Control

@onready var inventory_container: InventoryContainer = $InventoryContainer
@onready var test_container: TestContainer = $SmallContainer
@onready var menu_button: MenuButton = $Testing/MenuButton

var res1: String = "res://Inventory/ItemResources/crop_carrot.tres"
var res2: String = "res://Inventory/ItemResources/crop_tomato.tres"
var res3: String = "res://Inventory/ItemResources/seeds_strawberry.tres"
var res4: String = "res://Inventory/ItemResources/seeds_turnip.tres"


func _ready() -> void:
	_reset_inventory()
	init_menu_button()

func init_menu_button():
	var popup = menu_button.get_popup()
	popup.add_item("Add Carrots", 0)
	popup.add_item("Save", 1)
	popup.add_separator()
	popup.add_item("Quit", 2)
	popup.id_pressed.connect(_on_item_pressed)


func _on_item_pressed(id):
	match id:
		0:
			print("Add Carrots x5")
			#var new_item: Item = load(Global.PLAYER_INVENTORY_TEST[j][0])
			#inventory_container._set_slot(j,new_item,Global.PLAYER_INVENTORY_TEST[j][1])
			inventory_container.try_add_item_to_inventory(Global.PLAYER_INVENTORY_TEST,res1,5)
			_refresh_inventory_items()
		1:
			print("Save selected")
		2:
			print("Quit selected")


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

func _refresh_inventory_items():
	inventory_container = $InventoryContainer
	for l in Global.PLAYER_INVENTORY_TEST:
		if Global.PLAYER_INVENTORY_TEST[l][0] != null:
			var new_item = load(Global.PLAYER_INVENTORY_TEST[l][0])
			inventory_container._set_slot(l,new_item,Global.PLAYER_INVENTORY_TEST[l][1])
		else:
			inventory_container._set_slot(l,null,0)



func _on_sort_inventory_pressed() -> void:
	StorageHandler.sort_and_combine_inventory_Inv(Global.PLAYER_INVENTORY_TEST)
	_refresh_inventory_items()

func _on_sort_storage_pressed() -> void:
	StorageHandler.sort_and_combine_inventory_Strg(test_container)

func _on_btn_transfer_to_inv_pressed() -> void:
	StorageHandler.collect_all_from_container(test_container,Global.PLAYER_INVENTORY_TEST)
	_refresh_inventory_items()

func _on_btn_move_like_items_pressed() -> void:
	StorageHandler.collect_similar_from_container(test_container,Global.PLAYER_INVENTORY_TEST)
	_refresh_inventory_items()
