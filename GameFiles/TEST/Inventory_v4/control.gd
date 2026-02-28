extends Control

@onready var inventory_slot: InvSlot = $InventoryContainer/InventorySlot
@onready var inventory_container: InventoryContainer = $InventoryContainer


func _ready() -> void:
	
	#var tmpItm: Item = load("res://Inventory/ItemResources/crop_carrot.tres")
	#inventory_slot._update(tmpItm, 20)
	
	for j in Global.PLAYER_INVENTORY_TEST:
		var ic_children = inventory_container.get_children()
		var slot_for_update: InvSlot = ic_children[j]
		var new_item: Item = load(Global.PLAYER_INVENTORY_TEST[j][0])
		slot_for_update._update(new_item, Global.PLAYER_INVENTORY_TEST[j][1])
