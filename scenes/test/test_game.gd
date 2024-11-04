extends Node3D

@export var karts: Array[KartMetadata]
@export var map: MapMetadata


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Game.new_game(karts, map)
