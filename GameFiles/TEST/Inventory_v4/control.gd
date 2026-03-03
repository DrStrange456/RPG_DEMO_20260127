extends Control

@onready var inventory_container: InventoryContainer = $InventoryContainer
@onready var generic_container: GenericContainer = $GenericContainer
@onready var inventory_slot: InvSlot = $InventoryContainer/InventorySlot


func _ready() -> void:
	
	# insert code for removing old slots and adding new ones
	# this makes the function dynamic in case the number changes
	#for k in inventory_container.get_children():
		#k.queue_free()
	#for l in Global.PLAYER_INVENTORY_TEST:
		#var new_slot = load("res://Inventory/InvX/inventory_slot.tscn").instantiate()
		#new_slot.custom_minimum_size = Vector2(40,40)
		#inventory_container.add_child(new_slot)
	
	# NOT WORKING YET
	inventory_container = $InventoryContainer
	for j in Global.PLAYER_INVENTORY_TEST:
		var ic_children = inventory_container.get_children()
		var new_item: Item = load(Global.PLAYER_INVENTORY_TEST[j][0])
		var slot_for_update: InvSlot = ic_children[j]
		slot_for_update._update(new_item, Global.PLAYER_INVENTORY_TEST[j][1])
