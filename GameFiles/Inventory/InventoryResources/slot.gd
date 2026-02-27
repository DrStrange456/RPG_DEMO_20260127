extends Panel

@onready var ItemClass = preload("res://Inventory/item.tscn")

@export var slotNumber : int
@export var default_texture : Texture
@export var empty_texture : Texture
@export var selected_tex : Texture

var default_style: StyleBoxTexture = null
var empty_style: StyleBoxTexture = null
var selected_style: StyleBoxTexture = null

var node_for_mouse_pin_inv: String = "New_InvController"
var node_for_mouse_pin_stg: String = "StorageContainer_UI"

var slotType = null
var item = null
var slot_index

enum SlotType {
HOTBAR = 0,
	INVENTORY,
	STORAGE
}


func _ready():
	default_style = StyleBoxTexture.new()
	empty_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	default_style.texture = default_texture
	empty_style.texture = empty_texture
	selected_style.texture = selected_tex
	refresh_style()

func initialize_item(item_name, item_quantity) -> void:
	ItemClass = preload("res://Inventory/item.tscn")
	
	#1) Child attached but Item is null -> Update Item
	#2) Child attached and Item is not null -> Update Item
	
	#Attaching items to slot object (self)
	var ctrSlot
	if get_children().size() > 0: 
		#Item already attached
		ctrSlot = get_child(0)
	
	if item == null:
		item = ItemClass.instantiate()
		if ctrSlot: 
			ctrSlot.add_child(item) 
		else: 
			add_child(item)
		item.set_item(item_name, item_quantity)
	else:
		item.set_item(item_name, item_quantity)
	
	# FIXME - Need to call with active item index of slotType being checked
	#refresh_style()

func refresh_style(): 
	return

#func refresh_style(active_item_indx) -> void:
	#if slotType == SlotType.HOTBAR and active_item_indx == slot_index:
		##This sets the Active Item Style for - Hotbar
		#set('theme_override_styles/panel', selected_style)
	#elif slotType == SlotType.INVENTORY and active_item_indx == slot_index:
		##This sets the Active Item Style for - Player Inventory
		#set('theme_override_styles/panel', selected_style)
	#elif slotType == SlotType.STORAGE and active_item_indx == slot_index:
		##This sets the Active Item Style for - Storage
		#set('theme_override_styles/panel', selected_style)
	#elif item == null:
		##There is no item in the slot
		#set('theme_override_styles/panel', empty_style)
	#else:
		#set("theme_override_styles/panel", default_style)



# Setting up for Controller and KBM support

func _pop_toMouse():
	pass

func _pop_toCursor():
	pass

func _push_toSlot():
	pass



func reset_Slot() -> void:
	if item: nullify_item()
	refresh_style()
func pin_ToMouse(itm,p: String):
	var tmp = find_parent(p)
	tmp.add_child(itm)
	tmp.holding_item = itm
func nullify_item():
	if item:
		remove_child(item)
		item = null
func unpin_FromMouse(p: String):
	var tmp = find_parent(p)
	tmp.remove_child(item)
	tmp.holding_item = null
func pinItem_ToSlot():
	add_child(item)

func pickItemFromSlot() -> void:
	var tmpItem
	if item: 
		tmpItem = item
		nullify_item()
	pin_ToMouse(tmpItem,node_for_mouse_pin_inv)
	refresh_style()
func Stg_pickItemFromSlot() -> void:
	var tmpItem
	if item: 
		tmpItem = item
		nullify_item()
	pin_ToMouse(tmpItem,node_for_mouse_pin_stg)
	refresh_style()
func putItemIntoSlot(new_item) -> void:
	item = new_item
	item.position = Vector2.ZERO
	unpin_FromMouse(node_for_mouse_pin_inv)
	pinItem_ToSlot()
	refresh_style()
func Stg_putItemIntoSlot(new_item) -> void:
	
	item = new_item
	item.position = Vector2.ZERO
	unpin_FromMouse(node_for_mouse_pin_stg)
	pinItem_ToSlot()
	refresh_style()



### Right-click handling
func Storage_take_From_Slot_Stack():
	var new_item = ItemClass.instantiate()
	new_item.set_item(item.item_name, 1)
	pin_ToMouse(new_item,node_for_mouse_pin_stg)
	refresh_style()
func Storage_takeAnother_FromSlotStack(amt):
	var new_item = ItemClass.instantiate()
	new_item.set_item(item.item_name, amt)
	pin_ToMouse(new_item,node_for_mouse_pin_stg)
	refresh_style()
