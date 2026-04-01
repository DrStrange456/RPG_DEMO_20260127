extends Control


@onready var lbl_player_money: Label = $lblPLAYER_MONEY

var tmpRes = preload("res://Inventory/ItemResources/seeds_turnip.tres")
var tmpSlot = preload("res://Inventory/inventory_slot_ui.tscn")




func _on_buy_pressed() -> void:
	var os = OptiInventorySlot.new()
	var slt = tmpSlot.instantiate()
	slt.slot = os
	slt.slot.item = tmpRes 
	GameManager.buy_item(slt,3)


func _on_timer_timeout() -> void:
	update_money()


func update_money():
	lbl_player_money.text = str(Global.PLAYER_MONEY)



# BOTTOM
