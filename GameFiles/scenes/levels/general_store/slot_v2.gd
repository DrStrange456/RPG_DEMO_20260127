extends base_slot

@export var slotNumber : int
@export var default_texture : Texture
@export var empty_texture : Texture
@export var selected_tex : Texture



func _ready():
	default_style = StyleBoxTexture.new()
	empty_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	default_style.texture = default_texture
	empty_style.texture = empty_texture
	selected_style.texture = selected_tex
	refresh_style()


func initialize_item(item_name, item_quantity) -> void:
	ItemClass = preload("res://Inventory/NewInventory/item.tscn")
	
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
	refresh_style()

func set_Item_dimensions():
	if item:
		item.scale = Vector2(1.5,1.5)
		item.position = Vector2(item.position.x + 6, item.position.y + 6)

func reset_Slot() -> void:
	if item: nullify_item()
	refresh_style()
func pickItemFromSlot() -> void:
	var tmpItem
	if item: 
		tmpItem = item
		nullify_item()
	pin_ToMouse(tmpItem,"InvController")
	refresh_style()
func Stg_pickItemFromSlot() -> void:
	var tmpItem
	if item: 
		tmpItem = item
		nullify_item()
	pin_ToMouse(tmpItem,"StorageContainer_UI")
	refresh_style()
func putItemIntoSlot(new_item) -> void:
	item = new_item
	item.position = Vector2.ZERO
	unpin_FromMouse("PlayerInventoryUI")
	pinItem_ToSlot()
	refresh_style()
func Stg_putItemIntoSlot(new_item) -> void:
	item = new_item
	item.position = Vector2.ZERO
	unpin_FromMouse("StorageContainer_UI")
	pinItem_ToSlot()
	refresh_style()

func take_From_Slot_Stack():
	var new_item = ItemClass.instantiate()
	new_item.set_item(item.item_name, 1)
	pin_ToMouse(new_item,"PlayerInventoryUI")
	refresh_style()
func Stg_take_From_Slot_Stack():
	var new_item = ItemClass.instantiate()
	new_item.set_item(item.item_name, 1)
	pin_ToMouse(new_item,"StorageContainer_UI")
	refresh_style()
func takeOne_FromSlot():
	var new_item = ItemClass.instantiate()
	new_item.set_item(item.item_name, 1)
	pin_ToMouse(new_item,"PlayerInventoryUI")
	refresh_style()
func takeAnother_FromSlotStack(amt):
	var new_item = ItemClass.instantiate()
	new_item.set_item(item.item_name, amt)
	pin_ToMouse(new_item,"PlayerInventoryUI")
	refresh_style()
func Stg_takeAnother_FromSlotStack(amt):
	var new_item = ItemClass.instantiate()
	new_item.set_item(item.item_name, amt)
	pin_ToMouse(new_item,"StorageContainer_UI")
	refresh_style()

func nullify_item():
	if item:
		remove_child(item)
		item = null
func pin_ToMouse(itm,p: String):
	find_parent(p).add_child(itm)
func unpin_FromMouse(p: String):
	find_parent(p).remove_child(item)
func pinItem_ToSlot():
	add_child(item)
