@tool @icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
class_name InventoryContainer extends GridContainer


func _ready() -> void:
	_set_slot(0,"res://Inventory/ItemResources/crop_carrot.tres",1)
	_set_slot(1,"res://Inventory/ItemResources/crop_tomato.tres",1)
	_set_slot(2,"res://Inventory/ItemResources/seeds_strawberry.tres",1)
	_set_slot(3,"res://Inventory/ItemResources/crop_tomato.tres",1)
	_set_slot(4,"res://Inventory/ItemResources/crop_carrot.tres",1)
	_set_slot(5,"res://Inventory/ItemResources/crop_strawberry.tres",1)


func _set_slot(indx, itm, qty):
	var new_item: Item = load(itm)
	var ic_children = get_children()
	var slot_for_update: InvSlot = ic_children[indx]
	slot_for_update._update(new_item, qty)
	slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _slot_gui_input(event: InputEvent, slot: InvSlot):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			print("Left Mouse Button Clicked")
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			print("Right Mouse Button Clicked")
		
