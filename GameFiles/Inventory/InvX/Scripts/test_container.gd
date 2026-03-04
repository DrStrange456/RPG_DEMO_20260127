@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
class_name TestContainer extends GridContainer

var res1: String = "res://Inventory/ItemResources/crop_carrot.tres"
var res2: String = "res://Inventory/ItemResources/crop_tomato.tres"
var res3: String = "res://Inventory/ItemResources/seeds_strawberry.tres"

func _ready() -> void:
	_set_slot(0,res3,10)
	_set_slot(1,res2,1)
	_set_slot(2,res3,2)
	_set_slot(3,null,0)
	_set_slot(4,null,0)
	_set_slot(5,null,0)

func _set_slot(indx, itm, qty):
	var new_item: Item = load(itm) if itm != null else null
	var ic_children = get_children()
	var slot_for_update: InvSlot = ic_children[indx]
	slot_for_update._update(new_item, qty)
	slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _set_blank_slot(indx):
	var ic_children = get_children()
	var slot_for_update: InvSlot = ic_children[indx]
	slot_for_update._nullify()
	slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _slot_gui_input(event: InputEvent, slot: InvSlot):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			print("Left Mouse Button Clicked")
			var ic_children = get_children()
			StorageHandler._handle_click(ic_children[3],ic_children[4],self,true)
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			print("Right Mouse Button Clicked")
