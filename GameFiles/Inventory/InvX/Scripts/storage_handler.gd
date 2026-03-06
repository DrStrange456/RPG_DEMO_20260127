class_name storage_click_event_handler
extends Node

@onready var ptrINVENTORY = Global.PLAYER_INVENTORY_TEST # For Debugging ( Global.PLAYER_INVENTORY_TEST )
var leftover_delta: int = 0

### - - RIGHT CLICKS

func handle_click_single_item(gcGRID_INV: GridContainer,gcGRID_STRG: GridContainer, intSlotIndex: int):
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
				print(slot)
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








# Keeping this function in case its needed.  Currently not used.
func reindex_sorted(dict: Dictionary) -> Dictionary:
	var keys := dict.keys()
	keys.sort()
	var new_dict := {}
	var i := 0
	for k in keys:
		new_dict[i] = dict[k]
		i += 1  
	return new_dict

# bottom
