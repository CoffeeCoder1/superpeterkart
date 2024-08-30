extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var karts = ["res://scenes/karts/test_kart/test_kart.tscn", "res://scenes/karts/test_kart_2/test_kart_2.tscn"]
	$Game.new_game(karts)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
