@tool @icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
class_name GenericContainer extends GridContainer


var res1: String = "res://Inventory/ItemResources/crop_carrot.tres"
var res2: String = "res://Inventory/ItemResources/crop_tomato.tres"
var res3: String = "res://Inventory/ItemResources/seeds_strawberry.tres"


func _ready() -> void:
	_set_slot(0,res3,1)
	#_set_slot(1,res2,1)
	#_set_slot(2,res3,1)
	#_set_slot(3,res2,1)
	#_set_slot(4,res1,1)
	#_set_slot(5,res3,1)
	pass


func _set_slot(indx, itm, qty):
	var new_item: Item = load(itm)
	var ic_children = get_children()
	print(ic_children[indx].itm)
	var slot_for_update: InvSlot = ic_children[indx]
	slot_for_update._update(new_item, qty)
	print(ic_children[indx].itm)
	slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _slot_gui_input(event: InputEvent, slot: InvSlot):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			print("Left Mouse Button Clicked")
			var ic_children = get_children()
			StorageHandler._handle_click(ic_children[3],ic_children[4],self,true)
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			print("Right Mouse Button Clicked")

# Pop item preview to cursor
func _itm_to_cursor():
	pass

# SECTION RESERVED FOR SCRIPT
func left_click():
	pass
