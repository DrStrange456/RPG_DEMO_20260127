@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
extends GridContainer

@onready var ptrINVENTORY = Global.PLAYER_INVENTORY_TEST # For Debugging


var state
var holding_item

var holding_item_resource
var holding_item_qty

func _ready() -> void:
	state = Enum.InvActionStates.DEFAULT

func _process(_delta: float) -> void:
	if holding_item != null:  # Set item holding to mouse pos
		_update_mouse_holding_item_position()

func _update_mouse_holding_item_position():
	holding_item.position = get_local_mouse_position() - Vector2(20,20)


func _set_state(val):
	state = val

func _set_slot(indx):
	var ic_children = get_children()
	var slot_for_update: InvSlotUI = ic_children[indx]
	if !slot_for_update.is_connected("gui_input", _slot_gui_input.bind(slot_for_update)):
		slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _slot_gui_input(event: InputEvent, slot: InvSlotUI):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			_init_mouse_left_click(event,slot)
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			pass



func _init_mouse_left_click(_event: InputEvent, slot: InvSlotUI):
	if holding_item != null:  # Holding Item with Mouse
		if check_isSlot_Empty(slot):
			Left_Click_Empty_Slot(slot)
		else:  # Putting item into occupied slot
			if is_SlotItem_diff(slot, holding_item):
				Left_Click_Different_Item(slot)
			else:
				Left_Click_Same_Item(slot)
	else:  
		Left_Click_Not_Holding(slot)






func check_isSlot_Empty(slot: InvSlotUI)->bool:
	var idx = slot.indx
	var itm = Global.PLAYER_INVENTORY_TEST[idx][0]
	return itm == null

func is_SlotItem_diff(slot: InvSlotUI, holding)->bool:
	return true  #for testing


func Left_Click_Not_Holding(slot: InvSlotUI):
	if check_isSlot_Empty(slot): return
	mouse_pick_from_slot(slot)

func Left_Click_Empty_Slot(slot: InvSlotUI):
	pass

func Left_Click_Different_Item(slot: InvSlotUI):
	pass

func Left_Click_Same_Item(slot: InvSlotUI):
	pass



func mouse_pick_from_slot(slot: InvSlotUI):
	pin_to_mouse(slot)


func pin_to_mouse(obj):
	holding_item_resource = obj.slot.item
	holding_item_qty = int(obj.qty_label.text)
	var slot_index = obj.indx
	_remove_from_inventory(self, slot_index)
	move_item_to_mouse_holding(obj)
	await get_tree().process_frame






func move_item_to_mouse_holding(obj_Slot):
	holding_item = _pin_item_to_mouse(obj_Slot)

func _pin_item_to_mouse(slot):
	if slot:
		# unparent item obj and attach to mouse, 
		# must add back to scene tree so added to current (InvController) node
		var itm_preview = slot.duplicate()
		itm_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(itm_preview)
		#itm_preview.mouse_default_cursor_shape = Control.CURSOR_ARROW
		return itm_preview

func _remove_from_inventory(gcGRID: GridContainer, intSlotIndex: int):
	# - - Remove from Data then remove from UI
	# * Update Data
	ptrINVENTORY[intSlotIndex][0] = null
	ptrINVENTORY[intSlotIndex][1] = 0
	# * Update UI
	#var slots = gcGRID.get_children()
	#slots[intSlotIndex].slot.item = null
	#slots[intSlotIndex].update_ui()




# Bottom
