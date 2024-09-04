extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var karts = ["res://scenes/karts/test_kart/test_kart.tscn", "res://scenes/karts/test_kart_2/test_kart_2.tscn"]
	#$Game.new_game(karts)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_menu_game_started(karts: Array[Node]) -> void:
	var menu = self.get_node("Menu")
	self.remove_child(menu)
	menu.call_deferred("free")
	$Game.new_game(karts)
