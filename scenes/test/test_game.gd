extends Node3D

@export var kart_list: KartList
@export var karts: Array[KartMetadata]
@export var map: MapMetadata

@onready var game: Game = $Game


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game.add_player(1)
	for kart in karts:
		game.set_player_kart.rpc_id(1, kart_list.get_kart_id(kart))
	game.load_map(map)
	game.start_game()
