# this handles the setup of the networking server 
# as discussed in Client.gd, this uses the websocket server as this is the protocol best supported by the web export

extends Node

export var port : int = 2560

var useSsl = false
var sslCertLocation = ""
var sslKeyLocation = ""

var server : WebSocketServer

func _ready():
	set_process(false) # the process function is disabled so the unconfigured server isn't polled
	# start server if --server commandline argument is present
	if "--server" in OS.get_cmdline_args():
		start_server_with_websocket()

# starts the websocket server
func start_server_with_websocket():
	server = WebSocketServer.new()
	
	# setup ssl cert for secure websocket (wss protocol)
	if useSsl:
		server.ssl_certificate = load(sslCertLocation)
		server.private_key = load(sslKeyLocation)
	
	# listens for connections on the specified port
	var status = server.listen(port, PoolStringArray(), true)
	if status != OK:
		print("error starting server with status: " + str(status))
		return
	
	get_tree().network_peer = server # set this as the network peer that the high-level api will interact with
	set_process(true) # reenable the process method to start polling
	
	connect_signals()
	print("server started successfully on port: " + str(port))

func connect_signals():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

# poll the server for new packets/messages each frame
func _process(delta):
	server.poll()

func _player_connected(id):
	print("player connected with id: " + str(id))
	
func _player_disconnected(id):
	print("player disconnected with id: " + str(id))

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST and "--server" in OS.get_cmdline_args():
		for peer in get_tree().get_network_connected_peers():
			server.disconnect_peer(peer, 1000, "shutting down server")
