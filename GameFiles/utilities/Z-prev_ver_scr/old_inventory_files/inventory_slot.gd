# inventory_slot.gd
class_name InventorySlot
extends Resource

@export var item: Item
@export var quantity: int = 1
@export var enabled: bool = true
@export var idx: int
