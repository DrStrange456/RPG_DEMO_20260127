@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
class_name InventoryContainer extends GridContainer



func _ready() -> void:
	pass


func _set_slot(indx, itm, qty):
	var new_item: Item = itm
	var ic_children = get_children()
	var slot_for_update: InvSlot = ic_children[indx]
	slot_for_update._update(new_item, qty)
	slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _slot_gui_input(event: InputEvent, slot: InvSlot):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			StorageHandler.handle_click_InvToStrg(self,get_parent().test_container,slot.indx)
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			StorageHandler.handle_click_single_item(self,get_parent().test_container,slot.indx)
