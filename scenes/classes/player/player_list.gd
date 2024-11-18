class_name PlayerList extends Node

@export var players: Array[Player]


func add_player(player: Player) -> void:
	players.append(player)


func get_player_by_id(id: int) -> Player:
	for player in players:
		if player.player_id == id:
			return player
	return null
