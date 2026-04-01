class_name game_manager
extends Node

#@onready var player = get_tree().get_first_node_in_group('Player')
@onready var main_player: CharacterBody2D = find_anywhere("MainPlayer")
@onready var main_inventory: Control = find_anywhere("MainInventory")
@onready var ptrINVENTORY = Global.PLAYER_INVENTORY_TEST # For Debugging



### - Shop Manager
func buy_item(item: InvSlotUI,qty: int) -> bool:
	if Global.PLAYER_MONEY < item.slot.item.cost:
		return false

	Global.PLAYER_MONEY -= (item.slot.item.cost * qty)
	#player_inventory.append(item)
	return true

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
