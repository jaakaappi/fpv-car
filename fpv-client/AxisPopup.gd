extends Panel

@export var callback: Callable
@export var control_name: String

func _unhandled_input(event):
	if self.visible:
		if event is InputEventJoypadMotion and abs(event.axis_value) >= 0.3:
			callback.call(control_name, event.axis)
			self.visible = false
