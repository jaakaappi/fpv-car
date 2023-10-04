extends Panel

@onready var address_field = get_node("AddressField") as TextEdit
@onready var connection_status = get_node("ConnectionStatus") as ColorRect

@onready var wheel_hid_menu_button = get_node("MenuButton")
@onready var pedals_hid_menu_button = get_node("MenuButton2")
@onready var wheel_label = get_node("SteeringWheelDeviceLabel")
@onready var pedals_label = get_node("PedalsDeviceLabel")

var wheel_hid_id = -1
var pedals_hid_id = -1

var udp_ip = ""
var udp_port = 0
var udp_client := PacketPeerUDP.new()
var NOT_CONNECTED_COLOR = "#ff4969"
var CONNECTING_COLOR = "#d0d800"
var CONNECTED_COLOR = "#4eb100"

# Called when the node enters the scene tree for the first time.
func _ready():
	wheel_hid_menu_button.get_popup().id_pressed.connect(on_wheel_hid_selected)
	pedals_hid_menu_button.get_popup().id_pressed.connect(on_pedals_hid_selected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if udp_client.is_socket_connected():
		connection_status.color = CONNECTED_COLOR
		print("socket connected")
	elif udp_ip != "" && udp_port != 0:
		connection_status.color = CONNECTING_COLOR
		udp_client.connect_to_host(udp_ip, udp_port)
	
func on_connect_pressed():
	connection_status.color = CONNECTING_COLOR
	if address_field.text.split(":").size() == 2:
		var ip = address_field.text.split(":")[0]
		var port = int(address_field.text.split(":")[1])
		udp_client.connect_to_host(ip, port)
		udp_ip = ip
		udp_port = port

func on_wheel_hid_pressed():
	var device_ids = Input.get_connected_joypads()
	print(device_ids)
	var device_names = device_ids.map(func(id): return Input.get_joy_name(id))
	print(device_names)
	
	wheel_hid_menu_button.get_popup().clear()
	
	for i in range(0,device_ids.size()):
		wheel_hid_menu_button.get_popup().add_item(device_names[i], i)
		
func on_wheel_hid_selected(id):
	wheel_hid_id = id
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
	pedals_hid_id = id
	pedals_label.text = Input.get_joy_name(id)
