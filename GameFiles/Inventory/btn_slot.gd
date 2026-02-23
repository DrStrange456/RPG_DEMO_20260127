extends Button


signal slot_focused(slot: Button)

func _ready():
	connect("focus_entered", Callable(self, "_on_focus_entered"))

func _on_focus_entered():
	emit_signal("slot_focused", self)


func _on_mouse_entered() -> void:
	self.grab_focus()

func _set_focus_entered():
	self.grab_focus()
