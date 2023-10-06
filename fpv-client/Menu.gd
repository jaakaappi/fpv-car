extends Panel

@onready var main = $".."

@onready var address_field = get_node("AddressField") as TextEdit
@onready var connection_status = get_node("ConnectionStatus") as ColorRect

@onready var wheel_hid_menu_button = get_node("MenuButton")
@onready var pedals_hid_menu_button = get_node("MenuButton2")
@onready var wheel_label = get_node("SteeringWheelDeviceLabel")
@onready var pedals_label = get_node("PedalsDeviceLabel")

@onready var axis_popup = get_node("AxisPopup") as Panel
@onready var button_popup = get_node("ButtonPopup") as Panel

var NOT_CONNECTED_COLOR = "#ff4969"
var CONNECTING_COLOR = "#d0d800"
var CONNECTED_COLOR = "#4eb100"

# Called when the node enters the scene tree for the first time.
func _ready():
	wheel_hid_menu_button.get_popup().id_pressed.connect(on_wheel_hid_selected)
	pedals_hid_menu_button.get_popup().id_pressed.connect(on_pedals_hid_selected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func on_close_pressed():
	self.visible = false
	
func on_settings_pressed():
	self.visible = true
	
func on_connect_pressed():
	connection_status.color = CONNECTING_COLOR
	if address_field.text.split(":").size() == 2:
		var ip = address_field.text.split(":")[0]
		var port = int(address_field.text.split(":")[1])
		var result = main.try_connect(ip, port)
		if result:
			connection_status.color = CONNECTED_COLOR
		else:
			connection_status.color = NOT_CONNECTED_COLOR
			

func on_wheel_hid_pressed():
	var device_ids = Input.get_connected_joypads()
	print(device_ids)
	var device_names = device_ids.map(func(id): return Input.get_joy_name(id))
	print(device_names)
	
	wheel_hid_menu_button.get_popup().clear()
	
	for i in range(0,device_ids.size()):
		wheel_hid_menu_button.get_popup().add_item(device_names[i], i)
		
func on_wheel_hid_selected(id):
	main.set_wheel_hid(id)
	wheel_label.text = Input.get_joy_name(id)

func on_pedals_hid_pressed():
	var device_ids = Input.get_connected_joypads()
	print(device_ids)
	var device_names = device_ids.map(func(id): return Input.get_joy_name(id))
	print(device_names)
	
	pedals_hid_menu_button.get_popup().clear()
	
	for i in range(0,device_ids.size()):
		pedals_hid_menu_button.get_popup().add_item(device_names[i], i)
		
func on_pedals_hid_selected(id):
	main.set_pedals_hid(id)
	pedals_label.text = Input.get_joy_name(id)

func on_set_axis_pressed(control_name):
	axis_popup.callback = set_axis
	axis_popup.control_name = control_name
	axis_popup.visible = true

func set_axis(control_name: String, axis: int):
	match control_name:
		"wheel":
			main.set_wheel_axis(axis)
		"throttle":
			main.set_throttle_axis(axis)
	print("set ", control_name, " to axis", axis)

#func on_set_button_pressed(control_name):
#	button_popup.callback = set_button
#	button_popup.control_name = control_name
#	button_popup.visible = true
#
#func set_button(control_name: String, button: int):
#	match control_name:
#		"reverse":
#			reverse_button_number = button
#	print("set ", control_name, " to button", button)
