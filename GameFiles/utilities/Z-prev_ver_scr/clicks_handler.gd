class_name handle_clicks
extends Node

const SlotClass = preload("res://Player_Inventory/slot_v2.gd")


func getClickType(event: InputEvent, slot: SlotClass, holding_item) -> String:
	var result: String = ""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			result = input_leftClick(slot,holding_item)
		elif event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			if input_rightClick(slot,holding_item):
				result = input_rightClick(slot,holding_item)
	return result
func input_leftClick(slot: SlotClass, holding_item):
	if holding_item != null:
		if !isItemInSlot(slot):
			return Left_Click_Empty_Slot()
		else:
			if holding_item.item_name != slot.item.item_name:
				return Left_Click_DiffItem()
			else:
				return Left_Click_LikeItem()
	elif slot != null and slot.item:
		return Left_Click_NotHolding()
func input_rightClick(slot: SlotClass, holding_item):
	if holding_item != null:
		if isItemInSlot(slot):
			if holding_item.item_name == slot.item.item_name:
				return Right_Click_LikeItem()
	elif slot != null and slot.item:
		return Right_Click_NotHolding()



func Left_Click_Empty_Slot() -> String:
	return "leftClick_EmptySlot"
func Left_Click_NotHolding() -> String:
	return "leftClick_NotHolding"
func Left_Click_LikeItem() -> String:
	return "leftClick_LikeItem"
func Left_Click_DiffItem() -> String:
	return "leftClick_DiffItem"
func Right_Click_LikeItem() -> String:
	return "rightClick_LikeItem"
func Right_Click_NotHolding() -> String:
	return "rightClick_NotHolding"

func isItemInSlot(slot: SlotClass) -> bool:
	#Item is there and the item has an item_name
	var result = false
	if slot:
		if slot.item != null:
			if slot.item.item_name != null:
				result = true
	return result
