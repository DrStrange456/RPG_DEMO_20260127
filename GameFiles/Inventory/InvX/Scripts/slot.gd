@icon("res://assets/icons/inv_Icons/InventorySlot.svg")
class_name InvSlot extends Panel


@export var itm: Item:
	set(value):
		if get_parent() is InventoryContainer:
			if value != null:
				texture_rect.texture = value.icon
			else:
				texture_rect.texture = null
		elif get_parent() is TestContainer:
			if value != null:
				texture_rect.texture = value.icon
			else:
				texture_rect.texture = null

@onready var texture_rect: TextureRect = $CenterContainer/TextureRect
@onready var label: Label = $Label


func _update(value: Item, qty: int):
	itm = value
	label.visible = true if qty > 1 else false
	label.text = str(qty)

#func _nullify():
	#itm = null
	#label.text = ""

func _gui_clicked():
	print("click detected")
