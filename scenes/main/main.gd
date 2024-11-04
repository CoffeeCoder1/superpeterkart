extends Node3D

@onready var menu: Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu = self.get_node("Menu")
	menu.open_menu(menu.Menu.START_MENU)


func _on_menu_game_started(karts: Array[KartMetadata], map: MapMetadata) -> void:
	menu.close_menu()
	$Game.new_game(karts, map)
