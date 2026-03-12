class_name storage_click_event_handler
extends Node

# I like Storage Manager better  :)


@onready var ptrINVENTORY = Global.PLAYER_INVENTORY_TEST # For Debugging
var leftover_delta: int = 0


### - - LEFT CLICKS
func handle_click_InvToStrg(gcGRID_INV: GridContainer,gcGRID_STRG: GridContainer, intSlotIndex: int):
	if ptrINVENTORY[intSlotIndex][0] != null:
		if transfer_inventory_slot_to_container(ptrINVENTORY,gcGRID_STRG.get_children(),intSlotIndex):
			_remove_from_inventory(gcGRID_INV,intSlotIndex)  # All items successfully transferred
		else:
			_return_what_didnt_fit(gcGRID_INV,intSlotIndex)
		leftover_delta = 0


func handle_click_StrgToInv(SRC: InvSlot,gcGRID_STRG: GridContainer,gcGRID_INV: GridContainer, intSlotIndex: int):
	if SRC.itm != null:
		if _transfer_storage_to_inv(SRC,gcGRID_INV,intSlotIndex):
			_remove_from_storage(gcGRID_STRG,intSlotIndex)
		else:
			_return_what_didnt_fit_strg(SRC,gcGRID_STRG,intSlotIndex)
		leftover_delta = 0




### SUPPORT FUNCTIONS

func _remove_from_inventory(gcGRID: GridContainer, intSlotIndex: int):
	# - - Remove from Data then remove from UI
	# DATA
	ptrINVENTORY[intSlotIndex][0] = null
	ptrINVENTORY[intSlotIndex][1] = 0
	# UI
	var slots = gcGRID.get_children()
	slots[intSlotIndex]._update(null,0)

func _transfer_inv_to_storage(gcGRID_DEST: GridContainer,slotIndex: int):
	var item = load(ptrINVENTORY[slotIndex][0])
	var amount = ptrINVENTORY[slotIndex][1]
	var remaining:int  = int(amount)
	
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
				return true  # Done adding
	## Step 3: Not enough space
	if remaining > 0:
		print("Not enough space to add item: %s (Missing %d)" % [item.name, remaining])
		leftover_delta = remaining
		return false

func _return_what_didnt_fit(gcGRID_INV: GridContainer,intSlotIndex: int):
	# - - Update Data then UI
	# DATA
	ptrINVENTORY[intSlotIndex][1] = leftover_delta
	# UI
	var handle_to_source_slot = gcGRID_INV.get_child(intSlotIndex)
	if leftover_delta <= 0:
		handle_to_source_slot.slot.clear()
	else:
		handle_to_source_slot.slot.set_quantity(leftover_delta)



#func transfer_slot_to_container(inventory: Array, container: Array, slot_index: int):
	#var inv_slot = inventory[slot_index]
#
	#if inv_slot.item == null:
		#return
#
	#var item = inv_slot.item
	#var remaining = inv_slot.quantity
	#var max_stack = item.max_stack
#
	## --- fill existing stacks first ---
	#for slot in container:
#
		#if remaining <= 0:
			#break
#
		#if slot.item == item:
#
			#var space = max_stack - slot.quantity
			#if space <= 0:
				#continue
#
			#var add = min(space, remaining)
#
			#slot.set_quantity(slot.quantity + add)
			#remaining -= add
#
	## --- fill empty slots ---
	#for slot in container:
#
		#if remaining <= 0:
			#break
#
		#if slot.item == null:
#
			#var stack = min(max_stack, remaining)
#
			#slot.set_item(item)
			#slot.set_quantity(stack)
#
			#remaining -= stack
#
	## --- update inventory slot ---
	#if remaining <= 0:
		#inv_slot.clear()
	#else:
		#inv_slot.set_quantity(remaining)

func transfer_inventory_slot_to_container(inventory: Dictionary, container: Array, slot_index: int):

	var slot_data = inventory[slot_index]
	var item_path = slot_data[0]
	var quantity = slot_data[1]

	if item_path == null:
		return

	var item = load(item_path)
	var max_stack = item.max_stack
	var remaining = quantity

	# --- fill existing stacks ---
	for slot in container:

		if remaining <= 0:
			break

		if slot.slot.item == item:

			var space = max_stack - slot.slot.quantity
			if space <= 0:
				continue

			var add = min(space, remaining)

			slot.slot.set_quantity(slot.slot.quantity + add)
			remaining -= add

	# --- fill empty slots ---
	for slot in container:

		if remaining <= 0:
			break

		if slot.slot.item == null:

			var stack = min(max_stack, remaining)

			slot.slot.set_item(item)
			slot.slot.set_quantity(stack)

			remaining -= stack

	# --- update inventory dictionary ---
	if remaining > 0:
		leftover_delta = remaining
		#inventory[slot_index] = [null, 0]
	#else:
		#inventory[slot_index][1] = remaining



func _transfer_storage_to_inv(SRC: InvSlot,gcGRID_DEST: GridContainer,_slotIndex: int):
	var item = SRC.itm
	var amount = int(SRC.label.text)
	var remaining = amount
	var destIndex: int = 0
	
	# Step 1: Fill existing stacks
	var slots = gcGRID_DEST.get_children()
	destIndex = 0
	for slot in slots:
		if slot.itm == item and int(slot.label.text) < item.max_stack:
			var space = int(item.max_stack) - int(ptrINVENTORY[destIndex][1])
			var to_add = min(space, remaining)
			var new_qty = str(int(ptrINVENTORY[destIndex][1]) + to_add)
			slot.label.text = new_qty
			slot._refresh()
			remaining -= to_add
			
			# Update DATA here
			ptrINVENTORY[destIndex][0] = item.resource_path
			ptrINVENTORY[destIndex][1] = new_qty
			
			if remaining <= 0:
				return true  # Done adding
		destIndex += 1
	# Step 2: Fill new empty slots
	destIndex = 0
	for slot in slots:
		if slot.itm == null:
			var to_add = min(item.max_stack, remaining)
			var new_qty = str(int(ptrINVENTORY[destIndex][1]) + to_add)
			slot.itm = item
			slot.label.text = new_qty
			slot._refresh()
			remaining -= to_add
			
			# Update DATA here
			ptrINVENTORY[destIndex][0] = item.resource_path
			ptrINVENTORY[destIndex][1] = new_qty
			
			if remaining <= 0:
				return true  # Done adding
		destIndex += 1
	# Step 3: Not enough space
	if remaining > 0:
		print("Not enough space to add item: %s (Missing %d)" % [item.name, remaining])
		leftover_delta = remaining
		return false

func _remove_from_storage(gcGRID: GridContainer, intSlotIndex: int):
	# - - Only remove from UI.  Not handling data same as inventory.
	# UI
	var slots = gcGRID.get_children()
	slots[intSlotIndex]._update(null,0)

func _return_what_didnt_fit_strg(SRC: InvSlot, gcGRID: GridContainer, intSlotIndex: int):
	# - - Update Data then UI
	# UI
	var handle_to_source_slot = gcGRID.get_child(intSlotIndex)
	handle_to_source_slot._update(SRC.itm,leftover_delta)
	handle_to_source_slot._refresh()



# bottom
