extends Control

signal hbref_changes_made

@onready var hotbar_slots = $Panel/HBoxContainer
@onready var slots_hb = hotbar_slots.get_children()
@onready var slot_mapping: Dictionary = {
	0: $Panel/Selector_Buttons/slot_selector/slot_hb_1,
	1: $Panel/Selector_Buttons/slot_selector2/slot_hb_2,
	2: $Panel/Selector_Buttons/slot_selector3/slot_hb_3,
	3: $Panel/Selector_Buttons/slot_selector4/slot_hb_4,
	4: $Panel/Selector_Buttons/slot_selector5/slot_hb_5,
	5: $Panel/Selector_Buttons/slot_selector6/slot_hb_6,
	6: $Panel/Selector_Buttons/slot_selector7/slot_hb_7,
	7: $Panel/Selector_Buttons/slot_selector8/slot_hb_8
}

#var hotbar_ref = PlayerInventoryV3.hotbar_ref.duplicate()
var hotbar_ref = PInv.DATA_HB.duplicate()
var inv_slot_idx_ref
var old_hb_ref


func _ready() -> void:
	init_slots()


func init_slots()->void:
	hotbar_ref = PInv.HB.DATA.duplicate()
	for i in range(slots_hb.size()):
		slot_mapping[i].reset_Slot()
		if hotbar_ref.has(i):
			# checking for reference
			#if PlayerInventoryV3.inventory.has(hotbar_ref[i]):
			if PInv.PIO._is_valid_key(hotbar_ref[i]):
				var hb_itm_name = PInv.PIO.DATA[hotbar_ref[i]][0]
				var hb_itm_qty = PInv.PIO.DATA[hotbar_ref[i]][1]
				slot_mapping[i].initialize_item(hb_itm_name, hb_itm_qty)
			else:
				push_warning("Invalid hotbar reference: ", hotbar_ref[i])

func _set_references(inv_slot_idx):
	#if PlayerInventoryV3.HB_Ref_has_Slot(inv_slot_idx):
	if PInv.HB._is_valid_key(inv_slot_idx):
		inv_slot_idx_ref = inv_slot_idx
		old_hb_ref = PInv.HB._get_key_at_value(inv_slot_idx)

func _on_exit_button_pressed() -> void:
	#Events.emit_signal("update_viewonly_hotbar")  #refreshes ui
	self.visible = false


### Handle slot Selection Clicks

func _handle_selection(idx):
	if PInv.HB._is_valid_key(idx):
		_handle_slot_ref_connection_filled_slot(idx)
	else:
		_handle_slot_ref_connection_empty_slot(idx)
	hbref_changes_made.emit()  # Refresh Inventory UI
	init_slots()               # Refresh own UI

func _handle_slot_ref_connection_empty_slot(slotIndex):

	# make change in hotbar_ref (EMPTY SLOT)
	var invCtrlr = get_parent().find_child("New_InvController")
	var tmp = invCtrlr.get_slot_clicked()  # INV slot
	
	# First test if connection exists.  If yes,
	# break old connection.  Then assign
	var new_hb_slot = slotIndex
	var inv_slotnum_clicked = tmp.slot_index
	var old_hb_slot = PInv.HB._get_key_at_value(inv_slotnum_clicked)
	
	# Delete the old
	if inv_slotnum_clicked >= 0:
		if old_hb_slot != null:
			if old_hb_slot >= 0:
				PInv.HB._delete_at_index(old_hb_slot)
				hbref_changes_made.emit()  # Refresh Inventory UI
	
	# Set the new
	PInv.HB._set_value_at_key(new_hb_slot,inv_slotnum_clicked)
	hbref_changes_made.emit()  # Refresh Inventory UI
	init_slots()               # Refresh own UI
	self.visible = false

func _handle_slot_ref_connection_filled_slot(slotIndex):
	# make change in hotbar_ref (NON-EMPTY SLOT)	
	# remove ref connection
	PInv.HB._delete_at_index(slotIndex)
	# call handle connection empty slot
	_handle_slot_ref_connection_empty_slot(slotIndex)


### Clear Hotbar Slot 

func clear_slot(val):
	PInv.HB._delete_at_index(val-1)
	hbref_changes_made.emit()  # Refresh Inventory UI
	init_slots()               # Refresh own UI
