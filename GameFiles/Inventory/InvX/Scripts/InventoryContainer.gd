@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
class_name InventoryContainer extends GridContainer


func _set_slot(indx, itm, qty):
	var new_item: Item = itm
	var ic_children = get_children()
	var slot_for_update: InvSlot = ic_children[indx]
	slot_for_update._update(new_item, int(qty))
	slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _slot_gui_input(event: InputEvent, slot: InvSlot):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			StorageHandler.handle_click_InvToStrg(self,get_parent().test_container,slot.indx)
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			StorageHandler.handle_click_InvToStrg_single_item(self,get_parent().test_container,slot.indx)

func try_add_item_to_inventory(inventory: Dictionary, item_path: String, quantity: int) -> int:

	var item = load(item_path)
	var max_stack = item.max_stack

	# --- Step 1: Fill existing stacks ---
	for key in inventory.keys():

		var slot = inventory[key]

		if slot[0] == item_path:

			var current_qty = slot[1]
			var space = max_stack - current_qty

			if space > 0:

				var add = min(space, quantity)
				slot[1] += add
				quantity -= add

				if quantity <= 0:
					return 0

	# --- Step 2: Use empty slots ---
	var keys = inventory.keys()
	keys.sort()

	for key in keys:

		if quantity <= 0:
			break

		var slot = inventory[key]

		if slot[0] == null:

			var stack_size = min(max_stack, quantity)

			inventory[key] = [
				item_path,
				stack_size,
				true
			]

			quantity -= stack_size

	return quantity
