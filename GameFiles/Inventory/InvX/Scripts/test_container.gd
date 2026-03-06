@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
class_name TestContainer extends GridContainer

var res1: String = "res://Inventory/ItemResources/crop_carrot.tres"
var res2: String = "res://Inventory/ItemResources/crop_tomato.tres"
var res3: String = "res://Inventory/ItemResources/seeds_strawberry.tres"

var arrITEMS: Array = [[res3,20],[res2,1],[res3,2],[res2,3],[res2,80],[null,0]]
#var arrITEMS: Array = [[res3,75],[res3,50],[res3,50],[null,0],[null,0],[null,0]]

func _ready() -> void:
	_load_item_set(arrITEMS)



func _load_item_set(itms: Array):
	for N in get_children().size():
		_set_slot(N,null,0)
	for M in itms.size():
		_set_slot(M,itms[M][0],itms[M][1])

func _set_slot(indx, itm, qty):
	var new_item: Item = load(itm) if itm != null else null
	var ic_children = get_children()
	var slot_for_update: InvSlot = ic_children[indx]
	await get_tree().process_frame
	slot_for_update.itm = load(itm) if itm != null else null
	slot_for_update._update(new_item, qty)
	if !slot_for_update.is_connected("gui_input", _slot_gui_input.bind(slot_for_update)):
		slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _set_blank_slot(indx):
	var ic_children = get_children()
	var slot_for_update: InvSlot = ic_children[indx]
	slot_for_update._nullify()
	slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _slot_gui_input(event: InputEvent, slot: InvSlot):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			StorageHandler.handle_click_StrgToInv(slot,self,get_parent().inventory_container,slot.indx)
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			StorageHandler.handle_click_StrgToInv_single_item(slot,self,get_parent().inventory_container,slot.indx)
