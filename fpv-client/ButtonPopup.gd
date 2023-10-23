extends Panel

@export var callback: Callable
@export var control_name: String

func _unhandled_input(event):
	if self.visible:
		if event is InputEventJoypadButton:
			callback.call(control_name, event.button_index)
			self.visible = false
		if event is InputEventKey:
			if event.keycode == KEY_ESCAPE:
				self.visible = false
				return
			callback.call(control_name, event.keycode)
			self.visible = false
