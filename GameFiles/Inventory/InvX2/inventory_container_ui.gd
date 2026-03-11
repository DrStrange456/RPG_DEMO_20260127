@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
extends GridContainer

func _set_slot(indx):
	var ic_children = get_children()
	var slot_for_update: InvSlotUI = ic_children[indx]
	slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _slot_gui_input(event: InputEvent, slot: InvSlotUI):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			#StorageHandler.handle_click_InvToStrg(self,get_parent().test_container,slot.indx)
			printt("Left click registered")
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			#StorageHandler.handle_click_InvToStrg_single_item(self,get_parent().test_container,slot.indx
			printt("Right click registered")
