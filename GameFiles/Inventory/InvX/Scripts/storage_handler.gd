class_name storage_click_event_handler
extends Node

@onready var ptrINVENTORY = Global.PLAYER_INVENTORY_TEST # For Debugging
var leftover_delta: int = 0

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

func handle_click_StrgToInv_single_item(SRC: InvSlot,gcGRID_STRG: GridContainer,gcGRID_INV: GridContainer, intSlotIndex: int):
	if SRC.itm != null:
		var amount = int(SRC.label.text)
		if amount == 1:
			# only 1 left in slot
			handle_click_StrgToInv(SRC,gcGRID_STRG,gcGRID_INV,intSlotIndex)
		else:
			# more than 1 in slot, just move 1 and update count
			handle_click_StrgToInv_OnlyOne(SRC,gcGRID_STRG,gcGRID_INV,intSlotIndex)
	else:
		print("nothing to move")



func handle_click_InvToStrg_OnlyOne(gcGRID_INV: GridContainer,gcGRID_STRG: GridContainer, intSlotIndex: int):
	if ptrINVENTORY[intSlotIndex][0] != null:
		_transfer_inv_to_storage_JustOne(gcGRID_STRG,intSlotIndex)
		_return_what_didnt_fit(gcGRID_INV,intSlotIndex)
		leftover_delta = 0

func handle_click_StrgToInv_OnlyOne(SRC: InvSlot,gcGRID_STRG: GridContainer,gcGRID_INV: GridContainer, intSlotIndex: int):
	if SRC.itm != null:
		_transfer_storage_to_inv_JustOne(SRC,gcGRID_INV,intSlotIndex)
		_return_what_didnt_fit_strg(SRC,gcGRID_STRG,intSlotIndex)
		leftover_delta = 0

### - - LEFT CLICKS

##
### PRIMARY FUNCTION CALLS
##
func handle_click_InvToStrg(gcGRID_INV: GridContainer,gcGRID_STRG: GridContainer, intSlotIndex: int):
	if ptrINVENTORY[intSlotIndex][0] != null:
		if _transfer_inv_to_storage(gcGRID_STRG,intSlotIndex):
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

##
### INTERMEDIATE FUNCTION CALLS
##
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

func _transfer_inv_to_storage_JustOne(gcGRID_DEST: GridContainer,slotIndex: int):
	var item = load(ptrINVENTORY[slotIndex][0])
	var amount = ptrINVENTORY[slotIndex][1]
	var remaining:int  = int(amount)
	
	# Step 1: Fill existing stacks
	var slots = gcGRID_DEST.get_children()
	for slot in slots:
		if slot.itm == item and int(slot.label.text) < item.max_stack:
			var to_add = 1
			slot.label.text = str(int(slot.label.text) + to_add)
			slot._refresh()
			remaining -= to_add
			leftover_delta = remaining
			return true  # Done adding
	# Step 2: Fill new empty slots
	for slot in slots:
		if slot.itm == null:
			var to_add = 1
			slot.itm = item
			slot.label.text = str(int(slot.label.text) + to_add)
			slot._refresh()
			remaining -= to_add
			leftover_delta = remaining
			return true  # Done adding
	## Step 3: Not enough space
	if remaining > 0:
		print("Not enough space to add item: %s (Missing %d)" % [item.name, remaining])
		leftover_delta = remaining
		return false

func _transfer_storage_to_inv_JustOne(SRC: InvSlot,gcGRID_DEST: GridContainer,_slotIndex: int):
	var item = SRC.itm
	var amount = int(SRC.label.text)
	var remaining = amount
	var destIndex: int = 0
	
	# Step 1: Fill existing stacks
	var slots = gcGRID_DEST.get_children()
	destIndex = 0
	for slot in slots:
		if slot.itm == item and int(slot.label.text) < item.max_stack:
			var to_add = 1
			var new_qty = str(int(ptrINVENTORY[destIndex][1]) + to_add)
			slot.label.text = new_qty
			slot._refresh()
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
		if slot.itm == null:
			var to_add = 1
			var new_qty = str(int(ptrINVENTORY[destIndex][1]) + to_add)
			slot.itm = item
			slot.label.text = new_qty
			slot._refresh()
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

##
### SUPPORT FUNCTIONS
##
func _remove_from_inventory(gcGRID: GridContainer, intSlotIndex: int):
	# - - Remove from Data then remove from UI
	# DATA
	ptrINVENTORY[intSlotIndex][0] = null
	ptrINVENTORY[intSlotIndex][1] = 0
	# UI
	var slots = gcGRID.get_children()
	slots[intSlotIndex]._update(null,0)

func _return_what_didnt_fit(gcGRID_INV: GridContainer,intSlotIndex: int):
	# - - Update Data then UI
	# DATA
	ptrINVENTORY[intSlotIndex][1] = leftover_delta
	# UI
	var handle_to_source_slot = gcGRID_INV.get_child(intSlotIndex)
	var tmpItemForReturn = load(ptrINVENTORY[intSlotIndex][0])
	handle_to_source_slot._update(tmpItemForReturn,leftover_delta)
	handle_to_source_slot._refresh()

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









func sort_and_combine_inventory_Strg(grid: GridContainer):

	var slots := grid.get_children()
	var item_totals := {}

	# Collect all quantities
	for slot in slots:
		if slot.itm != null:
			var qty := int(slot.label.text)

			if item_totals.has(slot.itm):
				item_totals[slot.itm] += qty
			else:
				item_totals[slot.itm] = qty

	# Clear all slots
	for slot in slots:
		slot.itm = null
		slot.texture_rect.texture = null
		slot.label.text = ""

	# Rebuild stacks
	var slot_index := 0

	for item in item_totals.keys():

		var remaining: int = item_totals[item]

		while remaining > 0 and slot_index < slots.size():

			var stack_size: int = min(item.max_stack, remaining)
			var slot = slots[slot_index]

			slot.itm = item
			slot.texture_rect.texture = item.icon
			slot.label.text = str(stack_size)
			slot._refresh()

			remaining -= stack_size
			slot_index += 1

#func sort_and_combine_inventory_Inv(inventory: Dictionary):
#
	#var item_totals := {}
	#var enabled_slots := []
#
	## --- Collect totals and track enabled slots ---
	#for slot_index in inventory.keys():
#
		#var slot = inventory[slot_index]
		#var path = slot[0]
		#var qty = slot[1]
		#var enabled = slot[2]
#
		#if enabled:
			#enabled_slots.append(slot_index)
#
		#if path == null:
			#continue
#
		#var item = load(path)
#
		#if item_totals.has(item):
			#item_totals[item] += qty
		#else:
			#item_totals[item] = qty
#
	## --- Clear enabled slots ---
	#for i in enabled_slots:
		#inventory[i] = [null, 0, true]
#
	## --- Rebuild stacks ---
	#var slot_pointer := 0
#
	#for item in item_totals.keys():
#
		#var remaining: int = item_totals[item]
#
		#while remaining > 0 and slot_pointer < enabled_slots.size():
#
			#var slot_index = enabled_slots[slot_pointer]
			#var stack_size = min(item.max_stack, remaining)
#
			#inventory[slot_index] = [
				#item.resource_path,
				#stack_size,
				#true
			#]
			##slot._refresh()
#
			#remaining -= stack_size
			#slot_pointer += 1

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

func collect_all_from_container(container: GridContainer, inventory: Dictionary):

	var totals := {}

	# --- gather totals from inventory dictionary ---
	for slot in inventory.values():

		var path = slot[0]
		var qty = slot[1]

		if path == null:
			continue

		if totals.has(path):
			totals[path] += qty
		else:
			totals[path] = qty

	# --- gather totals from container slots ---
	for slot in container.get_children():

		if slot.itm == null:
			continue

		var path = slot.itm.resource_path
		var qty = int(slot.label.text)

		if totals.has(path):
			totals[path] += qty
		else:
			totals[path] = qty

		# clear chest slot
		slot.itm = null
		slot.texture_rect.texture = null
		slot.label.text = ""

	# --- clear inventory dictionary ---
	for key in inventory.keys():
		inventory[key] = [null, 0, true]

	# --- rebuild stacks ---
	var keys = inventory.keys()
	keys.sort()

	var pointer := 0

	for path in totals.keys():

		var item = load(path)
		var remaining = totals[path]

		while remaining > 0 and pointer < keys.size():

			var stack_size = min(item.max_stack, remaining)

			inventory[keys[pointer]] = [
				path,
				stack_size,
				true
			]

			remaining -= stack_size
			pointer += 1

func collect_similar_from_container(container: GridContainer, inventory: Dictionary):

	# --- Build a set of existing inventory items ---
	var existing_paths := []
	for slot in inventory.values():
		var path = slot[0]
		if path != null and not existing_paths.has(path):
			existing_paths.append(path)

	# --- Gather totals for matching items ---
	var totals := {}
	for path in existing_paths:
		totals[path] = 0

	# --- Process chest slots ---
	for slot in container.get_children():

		if slot.itm == null:
			continue

		var path = slot.itm.resource_path

		# Only collect if inventory already has this item
		if existing_paths.has(path):
			var qty = int(slot.label.text)

			if totals.has(path):
				totals[path] += qty
			else:
				totals[path] = qty

			# Clear chest slot
			slot.itm = null
			slot.texture_rect.texture = null
			slot.label.text = ""

	# --- Add quantities to inventory ---
	for key in inventory.keys():
		var slot = inventory[key]
		var path = slot[0]

		if path == null:
			continue

		if totals.has(path) and totals[path] > 0:
			var item = load(path)
			var remaining = totals[path]

			# Fill stack respecting max_stack
			var current_qty = slot[1]
			var space = item.max_stack - current_qty
			var to_add = min(space, remaining)

			slot[1] = current_qty + to_add
			totals[path] -= to_add








# bottom
