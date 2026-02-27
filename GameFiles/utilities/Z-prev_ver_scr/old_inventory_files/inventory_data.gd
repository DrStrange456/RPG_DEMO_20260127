# DATA INVENTORY (inventory.gd)
extends Node

# This is a fully instanced version of the players inventory data
# Operations on the data are carried out here

# DATA ONLY

var blank_item = preload("res://Inventory/ItemResources/blank_item.tres")


@export var max_slots: int = Global.NUMBER_ACTIVE_INVENTORY_SLOTS
var slots: Array[InventorySlot] = []


func _ready():
	#build_out_inventory()
	#debug_init_player_inv()
	#print("stop")
	pass


func _collect_gatherable_item(item: Item, amount: int = 1):
	add_item(item,amount)




func debug_init_player_inv():
	var sword = GlobalItemDB.get_item_by_name("Basic Sword")
	var wood = GlobalItemDB.get_item_by_name("Wood")
	var no_item = GlobalItemDB.get_item_by_name("")
	
	Inventory.add_slot(true, 0)  # Adds an enabled slot
	#Inventory.add_item(no_item, 0)
	Inventory.add_item(wood, 90)
	
	Inventory.add_slot(true, 1)  # Adds an enabled slot
	Inventory.add_item(sword, 1)  # blank item to nullify slot
	
	Inventory.add_slot(true, 2)  # Adds an enabled slot
	#Inventory.add_item(no_item, 0)  # blank item to nullify slot
	Inventory.add_slot_item(2, "Wood", 21)
	
	Inventory.add_slot(true, 3)  # Adds an enabled slot
	Inventory.add_item(no_item, 0)
	#Inventory.add_slot_item(3, "Wood", 21)
	
	
	Inventory.add_slot(true, 4)  # Adds an enabled slot
	#Inventory.add_item(no_item, 0)  # blank item to nullify slot
	Inventory.add_slot_item(4, "Wood", 21)
#	
	Inventory.add_slot(false, 5)  # Adds a disabled slot
	Inventory.add_item(no_item, 0)



#func add_item_and_refresh_ui(item: Item, amount: int = 1):
	#var slot_to_refresh = add_item_special(item, amount)

func add_item_special(item: Item, amount: int = 1) -> int:
	var slot_num: int = -1
	var remaining = amount

	# Step 1: Fill existing stacks
	for slot in slots:
		if slot.enabled and slot.item == item and slot.quantity < item.max_stack:
			var space = item.max_stack - slot.quantity
			var to_add = min(space, remaining)
			slot.quantity += to_add
			remaining -= to_add
			if remaining <= 0:
				slot_num = slot.idx
				return slot_num  # Done adding
	# Step 2: Fill new empty slots
	for slot in slots:
		if slot.enabled and slot.item == null:
			var to_add = min(item.max_stack, remaining)
			slot.item = item
			slot.quantity = to_add
			remaining -= to_add
			if remaining <= 0:
				slot_num = slot.idx
				return slot_num  # Done adding
	# Step 3: Not enough space
	if remaining > 0:
		print("Not enough space to add item: %s (Missing %d)" % [item.name, remaining])
		return slot_num

	return slot_num

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

func nullify_slot(idx: int):
	if idx >= 0 and idx < slots.size():
		slots[idx].item = null

func set_quantity_to_max(slot, _itm):
	var itm_resource = slot.item
	var itm_max_stack = itm_resource.max_stack
	
	update_item_quantity(slot.slot_index, itm_max_stack)

func decrement_slot_item_quantity(slot, amt):
	var itm_qty = Inventory.slots[slot.slot_index].quantity
	update_item_quantity(slot.slot_index, itm_qty-amt)

func increment_slot_item_quantity(slot, amt):
	var itm_qty = Inventory.slots[slot.slot_index].quantity
	update_item_quantity(slot.slot_index, itm_qty+amt)


func add_slot_item(index: int, nm: String, qty: int):
	if index >= 0 and index < slots.size():
		var test = GlobalItemDB.get_item_by_name(nm)
		set_item_quantity(index, test, qty)

func get_item_texture_by_index(idx) -> Texture:
	if Inventory.slots[idx].item == null:
		return null
	else:
		return Inventory.slots[idx].item.icon

func get_item_quantity(item: Item) -> int:
	var total = 0
	for slot in slots:
		if slot.enabled and slot.item == item:
			total += slot.quantity
	return total

func set_item_quantity(idx: int, item: Item, qty: int):
	slots[idx].item = item
	slots[idx].quantity = qty

func update_item_quantity(idx: int, qty: int):
	slots[idx].quantity = qty

func has_item(item: Item, amount: int = 1) -> bool:
	return get_item_quantity(item) >= amount

func find_first_stackable_slot(item: Item) -> InventorySlot:
	for slot in slots:
		if slot.enabled and slot.item == item and slot.quantity < item.max_stack:
			return slot
	return null

func find_first_empty_slot_in_data() -> InventorySlot:
	for slot in slots:
		if slot.enabled and slot.item == preload("res://Inventory/ItemResources/blank_item.tres"):
			return slot
	return null

func find_first_empty_slot_in_ui() -> int:
	var idx: int = 0
	for slot in slots:
		if slot.enabled and slot.item == preload("res://Inventory/ItemResources/blank_item.tres"):
			return idx
		idx += 1
	return -1

func clear_inventory():
	for slot in slots:
		if slot.enabled:
			slot.item = null
			slot.quantity = 0

func get_all_items() -> Dictionary:
	var result := {}
	for slot in slots:
		if slot.enabled and slot.item != null:
			if not result.has(slot.item):
				result[slot.item] = 0
			result[slot.item] += slot.quantity
	return result

func can_add_item(item: Item, amount: int = 1) -> bool:
	var remaining = amount

	# Check existing stacks
	for slot in slots:
		if slot.enabled and slot.item == item and slot.quantity < item.max_stack:
			var space = item.max_stack - slot.quantity
			remaining -= space
			if remaining <= 0:
				return true

	# Check empty slots
	var firstEmptySlot: int = find_first_empty_slot_in_ui()
	if firstEmptySlot == -1:
		return false
	else:
		return firstEmptySlot
	#for slot in slots:
		#if slot.enabled and slot.item == null:
			#var space = item.max_stack
			#remaining -= space
			#if remaining <= 0:
				#return true
#
	#return false

func enable_slot(index: int, enabled: bool):
	if index >= 0 and index < slots.size():
		slots[index].enabled = enabled
		if not enabled:
			slots[index].item = null
			slots[index].quantity = 0

func check_is_enabled(index: int)->bool:
	return slots[index].enabled

func add_slot(enabled, slot_idx: int):
	# Adds blank slot at initialization time
	if slots.size() >= max_slots:
		#print("Inventory is at max capacity.")
		return
	var new_slot = InventorySlot.new()
	new_slot.idx = slot_idx
	new_slot.enabled = enabled
	slots.append(new_slot)

func condense_items():
	var item_stacks := {}

	# Step 1: Collect all item quantities
	for slot in slots:
		if slot.enabled and slot.item != null:
			var item := slot.item
			if not item_stacks.has(item):
				item_stacks[item] = 0
			item_stacks[item] += slot.quantity

	# Step 2: Clear all non-empty slots
	for slot in slots:
		if slot.enabled:
			slot.item = null
			slot.quantity = 0

	# Step 3: Redistribute items with stacking
	for item in item_stacks.keys():
		var quantity = item_stacks[item]
		while quantity > 0:
			for slot in slots:
				if slot.enabled and slot.item == null:
					var to_add = min(item.max_stack, quantity)
					slot.item = item
					slot.quantity = to_add
					quantity -= to_add
					break

func condense_and_sort_items(sort_by: String = "name"):
# Sort by either Name or Type
	var item_stacks := []

	# Step 1: Collect all item quantities
	var stack_map := {}
	for slot in slots:
		if slot.enabled and slot.item != null:
			var item := slot.item
			if not stack_map.has(item):
				stack_map[item] = 0
			stack_map[item] += slot.quantity

	# Step 2: Clear all non-empty slots
	for slot in slots:
		if slot.enabled:
			slot.item = null
			slot.quantity = 0

	# Step 3: Convert to array for sorting
	for item in stack_map:
		item_stacks.append({
			"item": item,
			"quantity": stack_map[item]
		})

	# Step 4: Sort
	match sort_by:
		"name":
			item_stacks.sort_custom(func(a, b): return a["item"].name < b["item"].name)
		"type":
			item_stacks.sort_custom(func(a, b): return a["item"].item_type < b["item"].item_type)
		_:
			print("Unknown sort mode: ", sort_by)

	# Step 5: Refill inventory
	for stack in item_stacks:
		var item = stack["item"]
		var quantity = stack["quantity"]
		while quantity > 0:
			for slot in slots:
				if slot.enabled and slot.item == null:
					var to_add = min(item.max_stack, quantity)
					slot.item = item
					slot.quantity = to_add
					quantity -= to_add
					break

func condense_and_sort_items_Storage(grid):
	# Sort by either Name or Type
	var items: Array[Node] = []
	
	# Extract items from inside each button
	for slot in grid.get_children():
		var button = slot.get_child(0)  # Button is the first child
		var item = button
		items.append(button)
		item.get_parent().remove_child(item)  # Remove from current button
	
	# Condense items by resource (merge stackable ones)
	# NOTE: ALMOST WORKS.  JUST NEED TO TRACK QUANTITY
	#var condensed: Array[Node] = []
	#var resource_map: Dictionary = {}
#
	#for item in items:
		#var res = item.item
		#if resource_map.has(res):
			## Merge into existing item stack
			#resource_map[res].count += item.count
			#item.queue_free()  # Remove the merged duplicate
		#else:
			#resource_map[res] = item
			#condensed.append(item)
	#
	# Clear all buttons (already empty from above)
	await get_tree().process_frame  # Ensure removals are processed
	
	# Sort items (by name in this example)
	items.sort_custom(func(a, b):
		return str(a.item) < str(b.item)
	)
	
	# Refill buttons starting at the first slot
	var index := 0
	for slot in grid.get_children():
		#var button = slot.get_child(0)
		if index < items.size():
			slot.add_child(items[index])
			index += 1
