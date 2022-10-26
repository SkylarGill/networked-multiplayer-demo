extends RigidBody2D
class_name Ball

# this object is updated server side so we disable the _physics process method
func _ready():
	if "--server" in OS.get_cmdline_args():
		return
		
	set_physics_process(false)

# this pushes the current position and velocity of the ball to the connected clients at the fixed physics interval
func _physics_process(_delta):
	rpc_unreliable("set_ball_state", position, linear_velocity, angular_velocity)
	
# this runs on the client to update the object's position locally
puppet func set_ball_state(new_position: Vector2, new_linear_velocity: Vector2, new_angular_velocity: float):
	position = new_position
	linear_velocity = new_linear_velocity
	angular_velocity = new_angular_velocity
