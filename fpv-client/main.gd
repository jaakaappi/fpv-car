extends Control

@onready var throttle_slider = $"HUD/ThrottleSlider" as Slider
@onready var steering_slider = $"HUD/SteeringSlider" as Slider

var wheel_hid = -1
var pedals_hid = -1
var wheel_axis = -1
var wheel_left_button = -1
var wheel_right_button = -1
var throttle_axis = -1
var throttle_button = -1
var reverse_button = -1
#var reverse_button_number = ""

var udp_ip = ""
var udp_port = 0
var udp_client := PacketPeerUDP.new()
var NOT_CONNECTED_COLOR = "#ff4969"
var CONNECTING_COLOR = "#d0d800"
var CONNECTED_COLOR = "#4eb100"

var current_steering_value = 0.0
var current_throttle_value = 0.0
var current_reverse_value = false

var reverse_timeout_timestamp = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if udp_client.is_socket_connected():
		#connection_status.color = CONNECTED_COLOR
		send_data()
	elif udp_ip != "" && udp_port != 0:
		#connection_status.color = CONNECTING_COLOR
		udp_client.connect_to_host(udp_ip, udp_port)
		
func _unhandled_input(event):
	if wheel_hid != -1 && wheel_axis != -1:
		if event is InputEventJoypadMotion:
			print("wheel motion")
			event = event as InputEventJoypadMotion
			if event.device == wheel_hid && event.axis == wheel_axis:
				steering_slider.value = event.axis_value*50
				current_steering_value = event.axis_value*50
		if event is InputEventJoypadButton:
			if event.device == wheel_hid && event.button_index == reverse_button:
				current_reverse_value = event.pressed
				
	if event is InputEventKey:
		if event.keycode == reverse_button:
			current_reverse_value = event.pressed
		if event.keycode == throttle_button:
			current_throttle_value = 50 if event.pressed else 0
		if event.keycode == wheel_left_button:
			current_steering_value = -50 if event.pressed else 0
		if event.keycode == wheel_right_button:
			current_steering_value = 50 if event.pressed else 0
	
	if pedals_hid != -1 && throttle_axis != -1:
		if event is InputEventJoypadMotion:
			print("pedal motion")
			event = event as InputEventJoypadMotion
			if event.device == pedals_hid && event.axis == throttle_axis:
				throttle_slider.value = event.axis_value*100
				current_throttle_value = event.axis_value*100
				
func send_data():
	var steering_data = PackedByteArray()
	steering_data.resize(4)
	steering_data.encode_float(0, current_steering_value)
	
	var throttle_data = PackedByteArray()
	throttle_data.resize(4)
	throttle_data.encode_float(0, current_throttle_value if !current_reverse_value else 0)
	
	var reverse_data = PackedByteArray()
	reverse_data.resize(4)
	reverse_data.encode_float(0, 1.0 if current_reverse_value else 0)
	
	udp_client.put_packet(steering_data+throttle_data+reverse_data)

func try_connect(ip: String, port: int):
	var result = udp_client.connect_to_host(ip, port)
	if result == 0:
		print("no error")
		udp_ip = ip
		udp_port = port
		return true
	else:
		print("result", result)
		return false
		
func set_wheel_hid(hid):
	print("wheel hid", hid)
	self.wheel_hid = hid
		
func set_wheel_axis(axis):
	print("wheel axis", axis)
	self.wheel_axis = axis
	
func set_pedals_hid(hid):
	print("pedals hid", hid)
	self.pedals_hid = hid
	
func set_throttle_axis(axis):
	print("pedals axis", axis)
	self.throttle_axis = axis
	
func set_reverse_button(button):
	print("reverse button", button)
	self.reverse_button = button
	
func set_left_button(button):
	print("left button", button)
	self.wheel_left_button = button
	
func set_right_button(button):
	print("right button", button)
	self.wheel_right_button = button
	
func set_throttle_button(button):
	print("throttle button", button)
	self.throttle_button = button
