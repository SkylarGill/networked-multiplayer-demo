# the main player script - this controls movement and synchronisation with the server

extends KinematicBody2D
class_name Player

export var player_speed : float  = 250 
var player_color: Color
var player_hat: String
var player_id : int
var make_camera_current : bool = false

onready var hat_node = $"%Hat"

onready var player_body : Polygon2D = get_node("PlayerBody") as Polygon2D 
onready var camera : Camera2D = get_node("Camera2D") as Camera2D

# intialises the player with the provided customisation details
func _ready():
	player_body.color = player_color
	hat_node.get_node(player_hat).show()
	
	camera.current = make_camera_current
	
	# disable physics process if this isn't the current player so client is only controlling own player 
	if player_id != get_tree().get_network_unique_id():
		set_physics_process(false)

# handles local movement and sends position to server
func _physics_process(_delta):
	# get input axes
	var xMove = Input.get_axis("movement_left", "movement_right")
	var yMove = Input.get_axis("movement_up", "movement_down")

	var moveAmount = Vector2(xMove, yMove).normalized() * player_speed 	# calculate amount player should move
	
	# warning-ignore:return_value_discarded
	move_and_slide(moveAmount) # move player and collide with other physics objects
	
	# set the players scale to change facing direction to match movement
	if(xMove != 0):
		player_body.scale = Vector2(sign(xMove), player_body.scale.y)
		
	rpc_unreliable_id(1, "set_new_position", position, player_body.scale) # send new position data to the server - we use the unreliable variant of the method as we don't care if the position is slightly out of date

# runs on the server to send the new transform data to all clients
# you could validate player movement here so that players can't cheat by changing their speed locally
master func set_new_position(newPosition: Vector2, newScale: Vector2):
	position = newPosition
	player_body.scale = newScale
	rpc_unreliable("move_player_on_clients", newPosition, newScale) # we use the unreliable variant here again as we don't care if every packet is recieved

# runs on the client. this is called by the server to sync client transforms with the server
puppet func move_player_on_clients(newPosition: Vector2, newScale: Vector2):
	# returns if this is the client's player as movement is handled in the _physics_process function 
	if player_id == get_tree().get_network_unique_id():
		return
	position = newPosition
	player_body.scale = newScale
	
func set_color(color: Color):
	player_color = color
	
func set_hat(hat: String):
	player_hat = hat
