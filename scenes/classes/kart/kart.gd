class_name Kart extends CharacterBody3D

@export var acceleration: float = 10.0
@export var top_speed: float = 10.0
@export var boost_speed: float = 15.0
@export var braking: float = 15
@export var steering_amount: float = 10
## Distance from front to rear wheel
@export var wheel_spacing: float = 1
## Is the kart instantiated for a kart preview?
@export var kart_preview: bool = false

@onready var front_axle: Node3D = $FrontAxle
@onready var rear_axle: Node3D = $RearAxle

var _top_speed = top_speed
var _acceleration = acceleration
var _steer_target = 0
var boost_amount = 100


func _ready() -> void:
	# $Camera3D.make_current()
	pass


func _physics_process(delta: float) -> void:
	if !kart_preview:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		# Boost
		if Input.is_action_pressed("player1_boost") and boost_amount >= 0:
			_top_speed = move_toward(_top_speed, boost_speed, delta)
			boost_amount = move_toward(boost_amount, 0, delta)
			print(boost_amount)
		else:
			_top_speed = move_toward(_top_speed, top_speed, delta)
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var throttle := Input.get_axis("ui_up", "ui_down")
		var direction := (transform.basis * Vector3(0, 0, throttle)).normalized()
		if direction:
			velocity.x += direction.x * _acceleration * delta
			velocity.z += direction.z * _acceleration * delta
		else:
			velocity.x = move_toward(velocity.x, 0, braking * delta)
			velocity.z = move_toward(velocity.z, 0, braking * delta)
		
		velocity.x = clamp(velocity.x, -_top_speed, _top_speed)
		velocity.z = clamp(velocity.z, -_top_speed, _top_speed)
		
		# Steering
		var steering = Input.get_axis("ui_right", "ui_left")
		var front_wheel: Vector3 = transform.origin - transform.basis.z * (wheel_spacing / 2)
		var rear_wheel: Vector3 = transform.origin + transform.basis.z * (wheel_spacing / 2)
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
		
		# Rotate the kart
		look_at(transform.origin + new_heading, transform.basis.y)
		
		# Debug things
		front_axle.global_position = front_wheel
		rear_axle.global_position = rear_wheel
		
		move_and_slide()