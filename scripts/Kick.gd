# this handles the abilty for players to kick the ball

class_name Kick
extends Area2D

onready var player : Player = $"../.."

export var kick_force : float = 10
	
# disable this script if this isn't the client's associated player
func _ready():
	if player.player_id != get_tree().get_network_unique_id():
		set_physics_process(false)

# if the player presses the kick button, the kick function is called on the server
func _physics_process(_delta):
	if Input.is_action_just_pressed("action_kick"):
		rpc("kick")

# runs on the server to add an impulse to colliding rigid bodies (physics objects)
master func kick():
	var collisions = get_overlapping_bodies()
	for body in collisions:
		if body.has_method("apply_central_impulse"):
			var impulse = (body.global_position - global_position) * kick_force
			body.apply_central_impulse(impulse)
