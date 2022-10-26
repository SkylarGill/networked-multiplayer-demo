# this script handles playing animations for each player and syncs with the server 

extends AnimationPlayer

export(NodePath) onready var player_node = get_node(player_node) as Player

func _ready():
	if player_node.player_id != get_tree().get_network_unique_id():
		set_physics_process(false)

func _physics_process(delta):
	var inputX = Input.get_axis("movement_left", "movement_right")
	var inputY = Input.get_axis("movement_up", "movement_down")
	
	if inputX != 0 or inputY != 0:
		play("walking") 
		# we call these unreliably as we don't mind if the animations are out of sync
		rpc_unreliable("play_animation", "walking")
		return
	play("idle")
	rpc_unreliable("play_animation", "idle")

# runs on client and server to sync the animation currently being played
remote func play_animation(animation_name: String):
	play(animation_name)
