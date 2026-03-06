@icon("res://assets/icons/inv_Icons/InventorySlot.svg")
class_name InvSlot extends Panel

@export var indx: int  # for inventory slots this will be the place in the array
@export var typ: Enum.SlotType
@export var itm: Item:
	set(value):
		texture_rect.texture = value.icon if value != null else null
		itm = value
		#if get_parent() is InventoryContainer:
			#texture_rect.texture = value.icon if value != null else null
		#elif get_parent() is TestContainer:
			#texture_rect.texture = value.icon if value != null else null

@onready var texture_rect: TextureRect = $CenterContainer/TextureRect
@onready var label: Label = $Label


func _update(value: Item, qty: int):
	itm = value
	label.visible = true if qty > 1 else false
	label.text = str(qty)

func _refresh():
	label.visible = true if int(label.text) > 1 else false

func _gui_clicked():
	print("click detected in slot")
