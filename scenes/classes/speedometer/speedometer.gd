class_name Speedometer extends Control

## Current speed [0-1].
@export var speed: float
## Speed at which the neede moves.
@export var needle_speed: float = 2.0

@onready var needle: TextureRect = $Needle

var displayed_speed: float


func _process(delta: float) -> void:
	needle.pivot_offset = needle.size / 2
	
	displayed_speed = lerpf(displayed_speed, speed, delta * needle_speed)
	needle.rotation = -2.16 + (4.32 * displayed_speed)
