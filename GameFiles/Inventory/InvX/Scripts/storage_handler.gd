class_name storage_click_event_handler
extends Node

var ptrINVENTORY = Global.PLAYER_INVENTORY_TEST  # For Debugging


func _handle_click_InvToStrg(gcGRID_INV: GridContainer,gcGRID_STRG: GridContainer, intSlotIndex: int):
	var tmpINV_Item = load(ptrINVENTORY[intSlotIndex][0])
	_add_to_storage(gcGRID_STRG,tmpINV_Item,ptrINVENTORY[intSlotIndex][1])
	_remove_from_inventory(gcGRID_INV,intSlotIndex)



func _remove_from_inventory(gcGRID: GridContainer, intSlotIndex: int):
	# - - Remove from Data then remove from UI
	# DATA
	ptrINVENTORY.erase(intSlotIndex)
	# UI
	var slots = gcGRID.get_children()
	slots[intSlotIndex]._update(null,0)

func _add_to_storage(gcGRID_DEST: GridContainer,item: Item,amount: int):
	var remaining = amount
	
	# Step 1: Fill existing stacks
	var slots = gcGRID_DEST.get_children()
	for slot in slots:
		if slot.itm == item and int(slot.label.text) < item.max_stack:
			var space = item.max_stack - int(slot.label.text)
			var to_add = min(space, remaining)
			slot.label.text = str(int(slot.label.text) + to_add)
			slot._refresh()
			remaining -= to_add
			if remaining <= 0:
				return true  # Done adding
	# Step 2: Fill new empty slots
	for slot in slots:
		if slot.itm == null:
			var to_add = min(item.max_stack, remaining)
			slot.itm = item
			slot.label.text = str(int(slot.label.text) + to_add)
			slot._refresh()
			remaining -= to_add
			if remaining <= 0:
				print(slot)
				return true  # Done adding
	# Step 3: Not enough space
	if remaining > 0:
		print("Not enough space to add item: %s (Missing %d)" % [item.name, remaining])
		return false
	
		
	
	
	
	
	
	#var tmp = ptrINVENTORY[intSlotIndex]
	#var item: Item = load(tmp[0])
	#slots[4]._update(new_item,tmp[1])




#func _handle_click(srcSlot: InvSlot,destSlot: InvSlot,cursor_node,is_box_xfer):
	#var new_item1: Item = load(res1)
	#var new_item3: Item = load(res3)
	#srcSlot._update(new_item1, 2)
	#destSlot._update(new_item3, 3)

# bottom
