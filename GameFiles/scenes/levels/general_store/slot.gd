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

func setBlank() -> void:
	if item: remove_child(item)
	item = null
	refresh_style()
func pickItemFromSlot() -> void:
	if item: remove_child(item)
	get_Inventory_UI().add_child(item)
	item = ItemClass.instantiate()
	add_child(item)
	refresh_style()
func putItemIntoSlot(new_item) -> void:
	# 1) Update inventory to remove
	# 2) append as new node to slot node
	# 3) refresh style of slot
	item = new_item
	item.position = Vector2.ZERO
	get_Inventory_UI().remove_child(item)
	add_child(item)
	refresh_style()

# these should be only 1 function
# take_From_Slot_Stack()
# var new_item = ItemClass.instantiate()
# var old_item = item
# if old_item.quantity == 1
# clear slot
# if > 1
# Quantity -= 1
# refresh style


func takeOne_FromSlot():
	# For taking first of 2 items
	var new_item = ItemClass.instantiate()
	get_Inventory_UI().add_child(new_item)
	new_item.set_item(item.item_name, 1)
	refresh_style()
func takeAnother_FromSlot(amt):
	# Works for pulling second of two items from stack
	var new_item = ItemClass.instantiate()
	new_item.set_item(item.item_name, amt)
	if item: remove_child(item)
	get_Inventory_UI().add_child(new_item)
	item = null
	refresh_style()
func takeAnother_FromSlotStack(amt):
	# For taking from stack of 3 or more
	var new_item = ItemClass.instantiate()
	new_item.set_item(item.item_name, amt)
	get_Inventory_UI().add_child(new_item)
	refresh_style()
