class_name game_manager
extends Node

#@onready var player = get_tree().get_first_node_in_group('Player')
@onready var main_player: CharacterBody2D = find_anywhere("MainPlayer")
@onready var main_inventory: Control = find_anywhere("MainInventory")
@onready var ptrINVENTORY = Global.PLAYER_INVENTORY_TEST # For Debugging




### - Shop Manager
func buy_item(item: InvSlotUI,qty: int):
	if Global.PLAYER_MONEY < item.slot.item.cost:
		AudioController.play_sound("sfx_buy_fail")
		return false
	
	if attempt_purchase(item.slot.item.resource_path,qty):
		AudioController.play_sound("sfx_buy_success")
	else:
		# No Room
		AudioController.play_sound("sfx_buy_fail")

func _remove_from_inventory(intSlotIndex: int):
	# - - Remove from Data
	# DATA
	ptrINVENTORY[intSlotIndex][0] = null
	ptrINVENTORY[intSlotIndex][1] = 0




func show_inventory():
	main_inventory.visible = true
	Global.ACTIVE_MENU = Enum.MenuStates.MAIN_INVENTORY

func hide_inventory():
	main_inventory.visible = false
	Global.ACTIVE_MENU = Enum.MenuStates.DEFAULT


func find_anywhere(name1: String) -> Node:
	var tree := get_tree()
	
	# 1. Try to get autoloads
	var autoloads = ProjectSettings.get_setting("application/config/autoloads")
	if autoloads != null:
		for autoload_name in autoloads.keys():
			var singleton = tree.get_first_node_in_group(autoload_name)
			if singleton:
				if singleton.name == name1:
					return singleton
				var found = singleton.find_child(name1, true)
				if found:
					return found

	# 2. Try current scene
	if tree.current_scene:
		var found = tree.current_scene.find_child(name1, true)
		if found:
			return found

	# 3. Try the root (includes autoloads + main viewport)
	return tree.root.find_child(name1, true, false)







func attempt_purchase(item_path: String, amount: int) -> bool:
	var item_res = load(item_path)
	var total_cost = item_res.cost * amount

	if Global.PLAYER_MONEY < total_cost:
		return false

	var remaining = amount

	# PASS 1: Fill existing stacks
	for slot in ptrINVENTORY.keys():
		var data = ptrINVENTORY[slot]

		if not data[2]: # inactive
			continue

		if data[0] == item_path:
			var space = item_res.max_stack - data[1]
			if space > 0:
				var to_add = min(space, remaining)
				data[1] += to_add
				remaining -= to_add

				if remaining <= 0:
					break

	# PASS 2: Fill empty slots
	if remaining > 0:
		for slot in ptrINVENTORY.keys():
			var data = ptrINVENTORY[slot]

			if not data[2]:
				continue

			if data[0] == null:
				var to_add = min(item_res.max_stack, remaining)

				data[0] = item_path
				data[1] = to_add

				remaining -= to_add

				if remaining <= 0:
					break

	# FAIL if no space
	if remaining > 0:
		return false

	Global.PLAYER_MONEY -= total_cost
	return true
