extends CharacterBody3D


@export var ACCELERATION = 10.0
@export var TOP_SPEED = 1.0
@export var BOOST_SPEED = 1.5
@export var BRAKING = 15

var top_speed = TOP_SPEED
var acceleration = ACCELERATION

func _ready() -> void:
	# $Camera3D.make_current()
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Boost
	if Input.is_action_just_pressed("player1_boost"):
		top_speed = move_toward(top_speed, BOOST_SPEED, delta)
	else:
		top_speed = move_toward(top_speed, TOP_SPEED, delta)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x += direction.x * acceleration * delta
		velocity.z += direction.z * acceleration * delta
	else:
		velocity.x = move_toward(velocity.x, 0, BRAKING * delta)
		velocity.z = move_toward(velocity.z, 0, BRAKING * delta)
	
	velocity.x = clamp(velocity.x, -top_speed, top_speed)
	velocity.y = clamp(velocity.y, -top_speed, top_speed)

	move_and_slide()
