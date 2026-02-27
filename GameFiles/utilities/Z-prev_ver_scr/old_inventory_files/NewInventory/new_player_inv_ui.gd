extends Control

func refresh_slot_contents():
	$New_InvController.initialize_inventory()
func refresh_slot_clicks():
	$New_InvController._reset_slot_clicks()
func get_inv_cont():
	return $New_InvController/InventoryContainer
func get_inv_cont_itm(val):
	var tmp = $New_InvController/InventoryContainer
	return tmp.get_child(val)

func _on_set_hotbar_slot_ui_visibility_changed() -> void:
	if !$set_hotbar_slot_ui.visible:
		Events.emit_signal("hotbar_contents_changed")
