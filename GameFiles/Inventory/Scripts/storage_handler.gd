class_name storage_click_event_handler
extends Node

# I like Storage Manager better  :)
# or Storage Event Manager


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

func handle_click_StrgToInv(SRC: InvSlotUI,gcGRID_STRG: GridContainer,gcGRID_INV: GridContainer, intSlotIndex: int):
	if SRC.slot.item != null:
		if _transfer_storage_to_inv(SRC,gcGRID_INV,intSlotIndex):
			_remove_from_storage(gcGRID_STRG,intSlotIndex)
		else:
			_return_what_didnt_fit_strg(SRC,gcGRID_STRG,intSlotIndex)
		leftover_delta = 0


### - - RIGHT CLICKS
func handle_click_InvToStrg_single_item(gcGRID_INV: GridContainer,gcGRID_STRG: GridContainer, intSlotIndex: int):
	ptrINVENTORY = Global.PLAYER_INVENTORY_TEST
	if ptrINVENTORY[intSlotIndex][0] != null:
		if int(ptrINVENTORY[intSlotIndex][1]) == 1:
			# only 1 left in slot
			handle_click_InvToStrg(gcGRID_INV,gcGRID_STRG,intSlotIndex)
		else:
			# more than 1 in slot, just move 1 and update count
			handle_click_InvToStrg_OnlyOne(gcGRID_INV,gcGRID_STRG,intSlotIndex)
	else:
		print("nothing to move")

func handle_click_InvToStrg_OnlyOne(gcGRID_INV: GridContainer,gcGRID_STRG: GridContainer, intSlotIndex: int):
	if ptrINVENTORY[intSlotIndex][0] != null:
		_transfer_inv_to_storage_JustOne(gcGRID_STRG,intSlotIndex)
		_return_what_didnt_fit(gcGRID_INV,intSlotIndex)
		leftover_delta = 0

func handle_click_StrgToInv_single_item(SRC: InvSlotUI,gcGRID_STRG: GridContainer,gcGRID_INV: GridContainer, intSlotIndex: int):
	if SRC.slot.item != null:
		var amount = int(SRC.qty_label.text)
		if amount == 1:
			# only 1 left in slot
			handle_click_StrgToInv(SRC,gcGRID_STRG,gcGRID_INV,intSlotIndex)
		else:
			# more than 1 in slot, just move 1 and update count
			handle_click_StrgToInv_OnlyOne(SRC,gcGRID_STRG,gcGRID_INV,intSlotIndex)
	else:
		print("nothing to move")




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
		if slot.itm == item and int(slot.slot.quantity) < item.max_stack:
			var space = item.max_stack - int(slot.label.text)
			var to_add = min(space, remaining)
			slot.label.text = str(int(slot.label.text) + to_add)
			slot.slot.quantity = int(slot.label.text)
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
			slot.slot.quantity = int(slot.label.text)
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
	var remaining = int(quantity)

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



func _transfer_storage_to_inv(SRC: InvSlotUI,gcGRID_DEST: GridContainer,_slotIndex: int):
	var item = SRC.slot.item
	var amount = int(SRC.qty_label.text)
	var remaining = amount
	var destIndex: int = 0
	
	# Step 1: Fill existing stacks
	var slots = gcGRID_DEST.get_children()
	destIndex = 0
	for slot in slots:
		if slot.slot.item == item and int(slot.qty_label.text) < item.max_stack:
			var space = int(item.max_stack) - int(ptrINVENTORY[destIndex][1])
			var to_add = min(space, remaining)
			var new_qty = str(int(ptrINVENTORY[destIndex][1]) + to_add)
			slot.qty_label.text = new_qty
			slot.slot.quantity = new_qty
			slot.update_ui()
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
		if slot.slot.item == null:
			var to_add = min(item.max_stack, remaining)
			var new_qty = str(int(ptrINVENTORY[destIndex][1]) + to_add)
			slot.slot.item = item
			slot.qty_label.text = new_qty
			slot.slot.quantity = new_qty
			slot.update_ui()
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
	slots[intSlotIndex].slot.clear()

func _return_what_didnt_fit_strg(_SRC: InvSlotUI, gcGRID: GridContainer, intSlotIndex: int):
	# - - Update Data then UI
	# UI
	var handle_to_source_slot = gcGRID.get_child(intSlotIndex)
	if leftover_delta <= 0:
		handle_to_source_slot.slot.clear()
	else:
		handle_to_source_slot.slot.set_quantity(leftover_delta)



func _transfer_inv_to_storage_JustOne(gcGRID_DEST: GridContainer,slotIndex: int):
	var item = load(ptrINVENTORY[slotIndex][0])
	var amount = ptrINVENTORY[slotIndex][1]
	var remaining:int  = int(amount)
	
	# Step 1: Fill existing stacks
	var slots = gcGRID_DEST.get_children()
	for slot in slots:
		if slot.slot.item == item and int(slot.slot.quantity) < item.max_stack:
			var to_add = 1
			slot.qty_label.text = str(int(slot.qty_label.text) + to_add)
			slot.slot.quantity = int(slot.qty_label.text)
			slot.update_ui()
			remaining -= to_add
			leftover_delta = remaining
			return true  # Done adding
	# Step 2: Fill new empty slots
	for slot in slots:
		if slot.slot.item == null:
			var to_add = 1
			slot.slot.item = item
			var new_qty = str(int(slot.qty_label.text) + to_add)
			slot.qty_label.text = new_qty
			slot.slot.quantity = int(new_qty)
			slot.update_ui()
			remaining -= to_add
			leftover_delta = remaining
			return true  # Done adding
	## Step 3: Not enough space
	if remaining > 0:
		print("Not enough space to add item: %s (Missing %d)" % [item.name, remaining])
		leftover_delta = remaining
		return false

func handle_click_StrgToInv_OnlyOne(SRC: InvSlotUI,gcGRID_STRG: GridContainer,gcGRID_INV: GridContainer, intSlotIndex: int):
	if SRC.slot.item != null:
		_transfer_storage_to_inv_JustOne(SRC,gcGRID_INV,intSlotIndex)
		_return_what_didnt_fit_strg(SRC,gcGRID_STRG,intSlotIndex)
		leftover_delta = 0

func _transfer_storage_to_inv_JustOne(SRC: InvSlotUI,gcGRID_DEST: GridContainer,_slotIndex: int):
	var item = SRC.slot.item
	var amount = int(SRC.slot.quantity)
	var remaining = amount
	var destIndex: int = 0
	
	# Step 1: Fill existing stacks
	var slots = gcGRID_DEST.get_children()
	destIndex = 0
	for slot in slots:
		if slot.slot.item == item and int(slot.slot.quantity) < item.max_stack:
			var to_add = 1
			var new_qty = str(int(ptrINVENTORY[destIndex][1]) + to_add)
			slot.qty_label.text = new_qty
			slot.slot.quantity = int(new_qty)
			slot.update_ui()
			remaining -= to_add
			
			# Update DATA here
			ptrINVENTORY[destIndex][0] = item.resource_path
			ptrINVENTORY[destIndex][1] = new_qty
			
			leftover_delta = remaining
			return true  # Done adding
			
		destIndex += 1
	# Step 2: Fill new empty slots
	destIndex = 0
	for slot in slots:
		if slot.slot.item == null:
			var to_add = 1
			slot.slot.item = item
			var new_qty = str(int(ptrINVENTORY[destIndex][1]) + to_add)
			slot.qty_label.text = new_qty
			slot.slot.quantity = int(new_qty)
			slot.update_ui()
			remaining -= to_add
			
			# Update DATA here
			ptrINVENTORY[destIndex][0] = item.resource_path
			ptrINVENTORY[destIndex][1] = new_qty
			
			leftover_delta = remaining
			return true  # Done adding
			
		destIndex += 1
	# Step 3: Not enough space
	if remaining > 0:
		print("Not enough space to add item: %s (Missing %d)" % [item.name, remaining])
		leftover_delta = remaining
		return false





func sort_and_combine_inventory_Inv(inventory: Dictionary):

	var item_totals := {}

	# --- Collect totals ---
	for slot_index in inventory.keys():

		var slot = inventory[slot_index]
		var path = slot[0]
		var qty = slot[1]

		if path == null:
			continue

		var item = load(path)

		if item_totals.has(item):
			item_totals[item] += int(qty)
		else:
			item_totals[item] = int(qty)

	# --- Clear all slots ---
	for slot_index in inventory.keys():
		inventory[slot_index] = [null, 0, true]

	# --- Rebuild stacks ---
	var slot_keys = inventory.keys()
	slot_keys.sort()

	var slot_pointer := 0

	for item in item_totals.keys():

		var remaining: int = item_totals[item]

		while remaining > 0 and slot_pointer < slot_keys.size():

			var stack_size: int = min(item.max_stack, remaining)
			var slot_index = slot_keys[slot_pointer]

			inventory[slot_index] = [
				item.resource_path,
				stack_size,
				true
			]

			remaining -= stack_size
			slot_pointer += 1
	# NOTE: UI needs to be refreshed after this

func sort_and_combine_inventory_Strg(grid: GridContainer):

	var slots := grid.get_children()
	var item_totals := {}

	# Collect all quantities
	for slot in slots:
		if slot.slot.item != null:
			var qty := int(slot.slot.quantity)

			if item_totals.has(slot.slot.item):
				item_totals[slot.slot.item] += qty
			else:
				item_totals[slot.slot.item] = qty

	# Clear all slots
	for slot in slots:
		slot.slot.item = null
		slot.icon.texture = null
		slot.qty_label.text = ""
		slot.slot.quantity = int(0)

	# Rebuild stacks
	var slot_index := 0

	for item in item_totals.keys():

		var remaining: int = item_totals[item]

		while remaining > 0 and slot_index < slots.size():

			var stack_size: int = min(item.max_stack, remaining)
			var slot = slots[slot_index]

			slot.slot.item = item
			slot.icon.texture = item.icon
			slot.qty_label.text = str(stack_size)
			slot.slot.quantity = int(slot.qty_label.text)
			slot.update_ui()

			remaining -= stack_size
			slot_index += 1

func move_all_to_inventory(container: Array, inventory: Dictionary):

	for slot in container:

		if slot.slot.item == null:
			continue

		var item = slot.slot.item
		var qty = slot.slot.quantity

		var remaining = try_add_item_to_inventory(
			inventory,
			item.resource_path,
			qty
		)

		if remaining == 0:
			slot.slot.clear()
		else:
			slot.slot.set_quantity(remaining)






func try_add_item_to_inventory(inventory: Dictionary, item_path: String, quantity: int) -> int:

	var item = load(item_path)
	var max_stack = item.max_stack

	# --- Step 1: Fill existing stacks ---
	for key in inventory.keys():

		var slot = inventory[key]

		if slot[0] == item_path:

			var current_qty = int(slot[1])
			var space = int(max_stack) - int(current_qty)

			if space > 0:

				var add = min(space, quantity)
				slot[1] = str(int(slot[1]) + int(add))
				quantity -= int(add)

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


#func collect_all_from_container(container: GridContainer, inventory: Dictionary):
#
	#var totals := {}
#
	## --- gather totals from inventory dictionary ---
	#for slot in inventory.values():
		#var path = slot[0]
		#var qty = slot[1]
		#if path == null:
			#continue
		#if totals.has(path):
			#totals[path] += int(qty)
		#else:
			#totals[path] = int(qty)
#
	## --- gather totals from container slots ---
	#for slot in container.get_children():
#
		#if slot.slot.item == null:
			#continue
#
		#var path = slot.slot.item.resource_path
		#var qty = int(slot.qty_label.text)
#
		#if totals.has(path):
			#totals[path] += qty
		#else:
			#totals[path] = qty
#
		## clear chest slot
		#slot.slot.item = null
		#slot.icon.texture = null
		#slot.qty_label.text = ""
		#slot.slot.quantity = int(0)
#
	## --- clear inventory dictionary ---
	#for key in inventory.keys():
		#inventory[key] = [null, 0, true]
#
	## --- rebuild stacks ---
	#var keys = inventory.keys()
	#keys.sort()
#
	#var pointer := 0
#
	#for path in totals.keys():
#
		#var item = load(path)
		#var remaining = totals[path]
#
		#while remaining > 0 and pointer < keys.size():
#
			#var stack_size = min(item.max_stack, remaining)
#
			#inventory[keys[pointer]] = [
				#path,
				#stack_size,
				#true
			#]
#
			#remaining -= stack_size
			#pointer += 1

func inventory_has_item(inventory: Dictionary, item_path: String) -> bool:

	for slot in inventory.values():

		if slot[0] == item_path and int(slot[1]) > int(0):
			return true

	return false

var DEBUG_COLLECT := true

func dbg(msg):
	if DEBUG_COLLECT:
		print("[COLLECT] ", msg)



func collect_similar_from_chest(storage_slots: Array, inventory: Dictionary) -> void:
	dbg("=== START COLLECT ===")
	
	# --- STEP 1: Build item type list ---
	var item_types := []
	
	for chest_slot in storage_slots:
		if chest_slot.slot.item == null:
			continue
		
		var item_path = chest_slot.slot.item.resource_path
		
		if not item_types.has(item_path):
			item_types.append(item_path)
	
	dbg("Item types found: %s" % item_types)
	
	
	# --- STEP 2: Process each item type ---
	for item_path in item_types:
		dbg("--- Processing: %s ---" % item_path)
		
		# Check if exists in inventory
		var exists := false
		for i in inventory.keys():
			var slot = inventory[i]
			if slot[2] and slot[0] == item_path:
				exists = true
				break
		
		if not exists:
			dbg("Skipped (not in inventory)")
			continue
		
		var item_res = load(item_path)
		var max_stack = item_res.max_stack
		
		# --- PASS 1: Fill existing stacks ---
		dbg("PASS 1: Filling stacks")
		
		for i in inventory.keys():
			var inv_slot = inventory[i]
			
			if not inv_slot[2]:
				continue
			if inv_slot[0] != item_path:
				continue
			
			var space = max_stack - inv_slot[1]
			if space <= 0:
				continue
			
			dbg(" Inventory slot %d has %d space" % [i, space])
			
			for chest_index in range(storage_slots.size()):
				var chest_slot = storage_slots[chest_index]
				
				if chest_slot.slot.item == null:
					continue
				if chest_slot.slot.item.resource_path != item_path:
					continue
				
				if space <= 0:
					break
				
				var chest_qty = int(chest_slot.qty_label.text)
				if chest_qty <= 0:
					continue
				
				var transfer = min(space, chest_qty)
				
				dbg("  Taking %d from chest slot %d (had %d)" % [transfer, chest_index, chest_qty])
				
				# Apply transfer
				inv_slot[1] += transfer
				inventory[i] = inv_slot
				
				chest_qty -= transfer
				chest_slot.qty_label.text = str(chest_qty)
				
				if chest_qty <= 0:
					dbg("   Chest slot %d emptied" % chest_index)
					chest_slot.slot.item = null
					chest_slot.icon.texture = null
					chest_slot.qty_label.text = ""
				
				space -= transfer
		
		
		# --- PASS 2: Fill empty slots ---
		dbg("PASS 2: Using empty slots")
		
		for i in inventory.keys():
			var inv_slot = inventory[i]
			
			if inv_slot[2]:
				continue
			
			for chest_index in range(storage_slots.size()):
				var chest_slot = storage_slots[chest_index]
				
				if chest_slot.slot.item == null:
					continue
				if chest_slot.slot.item.resource_path != item_path:
					continue
				
				var chest_qty = int(chest_slot.qty_label.text)
				if chest_qty <= 0:
					continue
				
				var transfer = min(max_stack, chest_qty)
				
				dbg(" Filling empty slot %d with %d from chest slot %d" % [i, transfer, chest_index])
				
				inventory[i] = [item_path, transfer, true]
				
				chest_qty -= transfer
				chest_slot.qty_label.text = str(chest_qty)
				
				if chest_qty <= 0:
					dbg("   Chest slot %d emptied" % chest_index)
					chest_slot.slot.item = null
					chest_slot.icon.texture = null
					chest_slot.qty_label.text = ""
				
				break
		
	# --- FINAL STATE ---
	dbg("=== FINAL STORAGE STATE ===")
	for i in range(storage_slots.size()):
		var s = storage_slots[i]
		if s.slot.item == null:
			dbg(" Slot %d: EMPTY" % i)
		else:
			dbg(" Slot %d: %s x%s" % [i, s.slot.item.resource_path, s.qty_label.text])
	
	dbg("=== FINAL INVENTORY STATE ===")
	for i in inventory.keys():
		var s = inventory[i]
		if not s[2]:
			dbg(" Slot %d: EMPTY" % i)
		else:
			dbg(" Slot %d: %s x%d" % [i, s[0], s[1]])
	
	dbg("=== END COLLECT ===")







#
#func collect_similar_from_chest(container: Array, inventory: Dictionary):
#
	#var keys = inventory.keys()
	#keys.sort()
#
	## --- build item type set already in inventory ---
	#var inventory_types := {}
#
	#for i in keys:
		#var item_path = inventory[i][0]
		#var qty = int(inventory[i][1])
#
		#if item_path != null and qty > 0:
			#inventory_types[item_path] = true
#
#
	#for chest_slot in container:
#
		#if chest_slot.slot.item == null:
			#continue
#
		#var item = chest_slot.slot.item
		#var item_path = item.resource_path
		#var max_stack = item.max_stack
		#var remaining = int(chest_slot.slot.quantity)
#
#
		## skip if inventory does not already contain this type
		#if not inventory_types.has(item_path):
			#continue
#
#
		## --- pass 1: fill existing stacks ---
		#for i in keys:
#
			#if remaining <= 0:
				#break
#
			#if inventory[i][0] != item_path:
				#continue
#
			#var slot_qty = int(inventory[i][1])
#
			#if slot_qty >= max_stack:
				#continue
#
			#var space = max_stack - slot_qty
			#var add = min(space, remaining)
#
			#inventory[i][1] = int(inventory[i][1]) + add
			#remaining -= add
#
#
		## --- pass 2: overflow into empty slots ---
		#for i in keys:
#
			#if remaining <= 0:
				#break
#
			#if inventory[i][0] == null:
#
				#var stack = min(max_stack, remaining)
#
				#inventory[i][0] = item_path
				#inventory[i][1] = stack
#
				#remaining -= stack
#
#
		## --- update chest slot ---
		#if remaining == 0:
			#chest_slot.slot.clear()
		#else:
			#chest_slot.slot.set_quantity(remaining)







# bottom
