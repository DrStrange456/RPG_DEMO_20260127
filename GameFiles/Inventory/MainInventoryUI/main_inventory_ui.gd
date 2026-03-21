extends Control

@onready var main_inventory_container_ui: GridContainer = $MainInventoryContainerUI


func _ready() -> void:
	for i in $MainInventoryContainerUI.get_child_count():
		var ui = $MainInventoryContainerUI
		ui._set_slot(i)
