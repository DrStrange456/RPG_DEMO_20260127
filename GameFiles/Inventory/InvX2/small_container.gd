@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
class_name TestContainer extends GridContainer


var inventory : Array[OptiInventorySlot] = []


func _ready() -> void:
	_load_slots_from_save()

func _load_slots_from_save():
	inventory.resize(6)
	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()
	
	bind_inventory(inventory)
	
	for k in Global.STORAGE_TEST.size():
		inventory[k].set_item(load(Global.STORAGE_TEST[k][0]) if Global.STORAGE_TEST[k][0] else null)
		inventory[k].set_quantity(Global.STORAGE_TEST[k][1])

func bind_inventory(inv):
	var ui_slots = get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])


func _set_slot(indx):
	var ic_children = get_children()
	var slot_for_update: InvSlotUI = ic_children[indx]
	slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _slot_gui_input(event: InputEvent, slot: InvSlot):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			StorageHandler.handle_click_StrgToInv(slot,self,get_parent().inventory_container,slot.indx)
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			StorageHandler.handle_click_StrgToInv_single_item(slot,self,get_parent().inventory_container,slot.indx)
