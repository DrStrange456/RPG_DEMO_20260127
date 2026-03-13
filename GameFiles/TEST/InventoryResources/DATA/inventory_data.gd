extends Node

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# This is a fully instanced version of the players inventory
# Operations on the data structure and contents are carried out here
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATA ONLY
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

var blank_item = preload("res://Inventory/ItemResources/blank_item.tres")

@export var max_slots: int = Global.NUMBER_ACTIVE_INVENTORY_SLOTS
var slots: Array[InventorySlot] = []


func _ready() -> void:
	pass



### Basic Functions
func add_item(item: Item, amount: int = 1) -> bool:
	var remaining = amount

	# Step 1: Fill existing stacks
	for slot in slots:
		if slot.enabled and slot.item == item and slot.quantity < item.max_stack:
			var space = item.max_stack - slot.quantity
			var to_add = min(space, remaining)
			slot.quantity += to_add
			remaining -= to_add
			if remaining <= 0:
				return true  # Done adding
	# Step 2: Fill new empty slots
	for slot in slots:
		if (slot.enabled and slot.item == null) or slot.item == blank_item :
			var to_add = min(item.max_stack, remaining)
			slot.item = item
			slot.quantity = to_add
			remaining -= to_add
			if remaining <= 0:
				return true  # Done adding
	# Step 3: Not enough space
	if remaining > 0:
		print("Not enough space to add item: %s (Missing %d)" % [item.name, remaining])
		return false

	return true

func remove_item(item: Item, amount: int = 1) -> bool:
	var total_available := 0

	# Step 1: Calculate total quantity
	for slot in slots:
		if slot.enabled and slot.item == item:
			total_available += slot.quantity
	if total_available < amount:
		print("Not enough '%s' to remove. Needed %d, have %d" % [item.name, amount, total_available])
		return false  # Not enough items

	var remaining = amount

	# Step 2: Remove from slots in order
	for slot in slots:
		if slot.enabled and slot.item == item:
			if slot.quantity > remaining:
				slot.quantity -= remaining
				return true
			else:
				remaining -= slot.quantity
				slot.quantity = 0
				slot.item = null  # Empty the slot
			if remaining <= 0:
				return true

	return true

func remove_slot_item(index: int):
	# * doesn't really remove, just turns to blank
	if index >= 0 and index < slots.size():
		slots[index].item = GlobalItemDB.get_item_by_name("")
		slots[index].quantity = 0

### SUPPLEMENTAL
func decrement_slot_item_quantity(slot, amt):
	var itm_qty = InventoryData.slots[slot.slot_index].quantity
	update_item_quantity(slot.slot_index, itm_qty-amt)

func increment_slot_item_quantity(slot, amt):
	var itm_qty = InventoryData.slots[slot.slot_index].quantity
	update_item_quantity(slot.slot_index, itm_qty+amt)

func update_item_quantity(idx: int, qty: int):
	slots[idx].quantity = qty

func nullify_slot(idx: int):
	if idx >= 0 and idx < slots.size():
		slots[idx].item = null


### Manipulations to DATA Only

func add_slot(enabled, slot_idx: int):
	# Adds blank slot at initialization time
	if slots.size() >= max_slots:
		return
	var new_slot = InventorySlot.new()
	new_slot.idx = slot_idx
	new_slot.enabled = enabled
	slots.append(new_slot)

func add_slot_item(index: int, nm: String, qty: int):
	if index >= 0 and index < slots.size():
		var test = GlobalItemDB.get_item_by_name(nm)
		set_item_quantity(index, test, qty)

func set_item_quantity(idx: int, item: Item, qty: int):
	slots[idx].item = item
	slots[idx].quantity = qty
