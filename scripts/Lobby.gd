# this script handles the registration and intial synchronisation of players on connection
# player data is stored in a dictionary here and sent to players when after connecting
# this is also responsible for instanciating player entities on each client, either on initial connection or when new players connect

extends Node

# get world node to specify where to instanciate new players as children
export(NodePath) onready var world_node = get_node(world_node) as Node2D

# load player scene resource for instanciating players
var player_scene = preload("res://scenes/Player.tscn")

# data structure for storing player customisation data
var player_infos = {}

# connect signals to respond to events related to the network peer
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# runs when a player connects
func _player_connected(id):
	if get_tree().get_network_unique_id() == 1: # network unique id will always be 1 on the server
		rpc_id(id, "send_player_infos", player_infos) # sends the current player info to the client who just connected so a copy can be instanciated

# removes player instance and data upon disconnection
func _player_disconnected(id):
	player_infos.erase(id)
	world_node.get_node(str(id)).call_deferred("queue_free")
	
func _connected_ok():
	pass

func _server_disconnected():
	pass
	
func _connected_fail():
	pass

# the client script makes a call to this to register the player with player info
# adds data to the player_infos structure and prompts clients to create an instance for the player
master func register_player(color: Color, hat: String):
	var id = get_tree().get_rpc_sender_id()
	var info = { color = color, hat = hat}
	
	rpc("add_player", id, info)
	add_player(id, info)

# called by the server on a connecting client - sends the existing player's info to the client and instanciates the players there
puppet func send_player_infos(info):
	player_infos = info
	instanciate_players()
	
func instanciate_players():
	for id in player_infos:
		var player_info = player_infos[id]
		var player = create_player_node(id, player_info)
		world_node.call_deferred("add_child", player)

puppet func add_player(id, player_info):
	player_infos[id] = player_info
	var player = create_player_node(id, player_info)
	world_node.call_deferred("add_child", player)
	
func create_player_node(id, player_info) -> Player:
	var player = player_scene.instance()
	player.set_name(str(id))
	player.set_network_master(1)
	player.player_id = id
	player.set_color(player_info.color)
	player.set_hat(player_info.hat)
	if id == get_tree().get_network_unique_id():
		player.make_camera_current = true
		
	return player
