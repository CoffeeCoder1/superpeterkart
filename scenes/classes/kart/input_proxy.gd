class_name InputProxy extends Node

## Unique ID of the player controlling the character.
@export var player_id: int

var throttle: float
var steering: float
var boost: bool


func _process(delta):
	if player_id == multiplayer.get_unique_id():
		_set_throttle.rpc_id(1, Input.get_axis("ui_up", "ui_down"))
		_set_steering.rpc_id(1, Input.get_axis("ui_right", "ui_left"))
		_set_boost.rpc_id(1, Input.is_action_pressed("player1_boost"))


@rpc("any_peer", "call_local")
func _set_throttle(value: float) -> void:
	throttle = value


## Gets the throttle value.
func get_throttle() -> float:
	return throttle


@rpc("any_peer", "call_local")
func _set_steering(value: float) -> void:
	steering = value


## Gets the steering amount.
func get_steering() -> float:
	return steering


@rpc("any_peer", "call_local")
func _set_boost(value: bool) -> void:
	boost = value


## Gets the boost.
func get_boost() -> bool:
	return boost
