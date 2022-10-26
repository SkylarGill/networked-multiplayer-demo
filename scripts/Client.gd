# this script is responsible for setting up the network client for the player
# it handles most of the lower-level interaction with the client to set up the high-level API
# as the demo runs in the web, this uses the websocket client
# the tcp/ip client is incompatible with the web export whereas the webrtc client requires an additional engine module  

extends Node

# retrieve nodes from scene tree
onready var pre_connect_menu = $"%PreConnectMenu"
onready var server_ip_text_box : LineEdit = $"%ServerIpTextBox"
onready var localhost_check_box : CheckBox = $"%LocalhostCheckBox"
onready var connect_button : Button = $"%ConnectButton"
onready var color_selector = $"%ColorSelector"
onready var hat_selector = $"%HatSelector"
onready var lobby = $"%Lobby"

# set parameters - the export keyword allows these to be edited from the godot editor
export var server_ip : String
export var use_localhost : bool = true
export var port: int = 2560

var client : WebSocketClient

func _ready():
	# disables the process method until the websocket client is configured
	set_process(false)
	
	# we don't need a client on the server side
	if "--server" in OS.get_cmdline_args():
		return
	
	# connect button event to connection method and show the connection menu
	connect_button.connect("pressed", self, "_connect_button_pressed")
	pre_connect_menu.show()
	connect_signals()

func _connect_button_pressed():
	use_localhost = localhost_check_box.pressed
	server_ip = server_ip_text_box.text
	start_client_with_websocket()

func start_client_with_websocket():
	client = WebSocketClient.new()
	
	# determines server url (with port) from config
	var server_url = ""
	if use_localhost: 
		server_url += "127.0.0.1"
	else:
		server_url += server_ip
	
	server_url+= ":" + str(port)
	
	# establishes connection to the server and check the status
	var status = client.connect_to_url(server_url, PoolStringArray(), true)
	if status != OK:
		print("error connecting to server with status: " + str(status))
		return

	# set the network peer of the scene tree to the client to ensure compatibility with high-level multiplayer API	
	get_tree().network_peer = client
	set_process(true) # reenable process method now the client is connected

func connect_signals():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connection_successful")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# polls the websocket connection each frame - if this method stops being called, the client won't recieve any more updates
func _process(_delta):
	client.poll()

# this runs on successful connection to send player customisation info to the server
func _connection_successful():
	get_tree().paused = false # the scene tree is initially paused and needs unpausing 
	print("connected successfully")
	pre_connect_menu.hide()
	var color = color_selector.selected_color
	var hat = hat_selector.selected_hat
	lobby.rpc("register_player", color, hat) # calls a remote procedure to register the player with the server and other clients
	
# logging and reinitialisation on connection failure
func _connection_failed():
	get_tree().paused = true
	pre_connect_menu.show()
	OS.alert("connection to server failed")
	print("connection failed")

# logging and reinitialisation on disconnection	
func _server_disconnected():
	get_tree().paused = true
	pre_connect_menu.show()
	OS.alert("disconnected by server")
	
func _player_connected(id):
	print("client: player connected with id: " + str(id))
	
func _player_disconnected(id):
	print("client: player disconnected with id: " + str(id))
