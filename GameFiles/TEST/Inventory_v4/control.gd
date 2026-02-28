extends Control

@onready var inventory_slot: InvSlot = $InventoryContainer/InventorySlot
@onready var inventory_container: InventoryContainer = $InventoryContainer


func _ready() -> void:
	
	for j in Global.PLAYER_INVENTORY_TEST:
		var ic_children = inventory_container.get_children()
		var new_item: Item = load(Global.PLAYER_INVENTORY_TEST[j][0])
		var slot_for_update: InvSlot = ic_children[j]
		slot_for_update._update(new_item, Global.PLAYER_INVENTORY_TEST[j][1])
