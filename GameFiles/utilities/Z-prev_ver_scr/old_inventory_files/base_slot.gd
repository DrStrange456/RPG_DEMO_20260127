class_name base_slot
extends Panel

@onready var ItemClass = preload("res://Inventory/item.tscn")

var default_style: StyleBoxTexture = null
var empty_style: StyleBoxTexture = null
var selected_style: StyleBoxTexture = null
var slotType = null
var item = null
var slot_index

enum SlotType {
HOTBAR = 0,
	INVENTORY,
	STORAGE
}

func getItemName() -> String:
	if item:
		return item.item_name
	else:
		return ""
func getItemQuantity() -> int:
	return item.item_quantity
func get_Inventory_UI() -> Object:
	return find_parent("PlayerInventoryUI")
func refresh_style() -> void:
	if slotType == SlotType.HOTBAR and PInv.active_item_slot_Hotbar == slot_index:
		#This sets the Active Item Style for - Hotbar
		set('theme_override_styles/panel', selected_style)
	elif slotType == SlotType.INVENTORY and PInv.active_item_slot_Inventory == slot_index:
		#This sets the Active Item Style for - Player Inventory
		set('theme_override_styles/panel', selected_style)
	elif slotType == SlotType.STORAGE and PInv.active_item_slot_Storage == slot_index:
		#This sets the Active Item Style for - Storage
		set('theme_override_styles/panel', selected_style)
	elif item == null:
		#There is no item in the slot
		set('theme_override_styles/panel', empty_style)
	else:
		set("theme_override_styles/panel", default_style)
