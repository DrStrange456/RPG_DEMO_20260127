extends Control


@onready var lbl_player_money: Label = $lblPLAYER_MONEY
@onready var main_inventory: Control = $PlayerInventoryPanel/MainInventory


var tmpRes = preload("res://Inventory/ItemResources/seeds_turnip.tres")
var tmpSlot = preload("res://Inventory/inventory_slot_ui.tscn")




func _on_buy_pressed() -> void:
	var os = OptiInventorySlot.new()
	var slt = tmpSlot.instantiate()
	slt.slot = os
	slt.slot.item = tmpRes 
	GameManager.buy_item(slt,3)
	_refresh_inventory_items()

func _on_timer_timeout() -> void:
	update_money()


func update_money():
	lbl_player_money.text = str(Global.PLAYER_MONEY)


func _refresh_inventory_items():
	main_inventory._load_slots_from_save()



# BOTTOM
