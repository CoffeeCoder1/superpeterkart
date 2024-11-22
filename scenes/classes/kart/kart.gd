class_name Kart extends CharacterBody3D

@export var acceleration: float = 50.0
@export var top_speed: float = 30.0
@export var boost_speed: float = 15.0
@export var braking: float = 15
@export var steering_amount: float = 0.3
## Distance from front to rear wheel
@export var wheel_spacing: float = 1
## Should the kart be enabled?
@export var kart_enabled: bool = true
## The ID of the player controlling the kart
@export var player_id: int = 1
## The current speed of the kart.
@export var speed: float
## Drag applied when the kart is off the track.
@export var off_track_drag: float = 10.0
## Rate at which the track drag is changed.
@export var track_drag_smoothing: float = 10.0

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var track_ray_cast: RayCast3D = $TrackRayCast

var _top_speed = top_speed
var _acceleration = acceleration
var boost_amount = 100
var on_track: bool
var track_drag: float = 0

var front_wheel: Vector3
var rear_wheel: Vector3

var input_proxy: InputProxy


func _ready() -> void:
	input_proxy = InputProxy.new()
	add_child(input_proxy)
	
	# Set up the MultiplayerSynchronizer
	multiplayer_synchronizer.replication_config.add_property(":position")
	multiplayer_synchronizer.replication_config.add_property(":rotation")
	multiplayer_synchronizer.replication_config.add_property(":speed")


func _process(delta: float) -> void:
	# TODO: Move this to a setter
	input_proxy.player_id = player_id
	
	# Disable multiplayer calls if the kart is disabled.
	input_proxy.set_process(kart_enabled)
	multiplayer_synchronizer.set_process(kart_enabled)
	
	# If this is the local kart, focus the camera.
	if player_id == multiplayer.get_unique_id():
		$Camera3D.make_current()


func _physics_process(delta: float) -> void:
	# Allow disabling the kart for preview displays and when not being controlled by the local player.
	if kart_enabled and get_multiplayer_authority() == multiplayer.get_unique_id():
		# Check if the kart is on the track or not
		if track_ray_cast:
			var drive_mesh: = track_ray_cast.get_collider()
			on_track = drive_mesh is DriveMesh
			if on_track:
				track_drag = move_toward(track_drag, drive_mesh.get_track_drag(), delta * track_drag_smoothing)
			else:
				track_drag = move_toward(track_drag, off_track_drag, delta * track_drag_smoothing)
		
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		# Boost
		if input_proxy.get_boost() and boost_amount >= 0:
			_top_speed = move_toward(_top_speed, boost_speed, delta)
			boost_amount = move_toward(boost_amount, 0, delta)
			print(boost_amount)
		else:
			_top_speed = move_toward(_top_speed, top_speed, delta)
		
		## Top speed calculated each frame
		var speed_limit: float = _top_speed
		
		# Apply track drag
		speed_limit -= track_drag
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := (transform.basis * Vector3(0, 0, input_proxy.get_throttle())).normalized()
		if direction:
			velocity.x += direction.x * _acceleration * delta
			velocity.z += direction.z * _acceleration * delta
		else:
			velocity.x = move_toward(velocity.x, 0, braking * delta)
			velocity.z = move_toward(velocity.z, 0, braking * delta)
		
		velocity.x = clamp(velocity.x, -speed_limit, speed_limit)
		velocity.z = clamp(velocity.z, -speed_limit, speed_limit)
		
		# Steering
		var steering := input_proxy.get_steering() * steering_amount
		front_wheel = transform.origin - transform.basis.z * (wheel_spacing / 2)
		rear_wheel = transform.origin + transform.basis.z * (wheel_spacing / 2)
		var velocity_total: float = (velocity * Vector3(1, 0, 1)).length()
		# Move the axles forward, rotating the front one's direction to steer
		front_wheel += velocity.rotated(transform.basis.y, steering) * delta
		rear_wheel += velocity * delta
		
		var new_heading = rear_wheel.direction_to(front_wheel)
		
		# Somehow magically fixes some things
		var heading_dot: float = new_heading.dot(velocity.normalized())
		if heading_dot > 0:
			velocity = new_heading * velocity.length()
		if heading_dot < 0:
			velocity = -new_heading * min(velocity.length(), 10)
		
		# Kart speed (used for display in the HUD)
		speed = velocity_total
		
		# Rotate the kart
		look_at(transform.origin + new_heading, transform.basis.y)
		
		move_and_slide()


## Returns the speed of the kart.
func get_speed() -> float:
	return speed
