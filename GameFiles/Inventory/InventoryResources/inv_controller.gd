extends Panel

var grid_node: GridContainer

func _ready() -> void:
	InvMW._pInvData_Initialize(Global.PLAYER_INV_SLOTS_MAX,Global.PLAYER_INV_SLOTS_UNLOCKED,grid_node,slot_gui_input)


func slot_gui_input(_event: InputEvent, _btn: Button):
	pass
