class_name storage_click_event_handler
extends Node

var res1: String = "res://Inventory/ItemResources/crop_carrot.tres"
var res2: String = "res://Inventory/ItemResources/crop_tomato.tres"
var res3: String = "res://Inventory/ItemResources/seeds_strawberry.tres"



func _handle_click(srcSlot: InvSlot,destSlot: InvSlot,cursor_node,is_box_xfer):
	var new_item1: Item = load(res1)
	var new_item3: Item = load(res3)
	srcSlot._update(new_item1, 2)
	destSlot._update(new_item3, 3)
