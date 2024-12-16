class_name PlayerList extends Node

@export var players: Array[Player]


func add_player(player: Player) -> void:
	players.append(player)


func remove_player_by_id(player_id: int) -> void:
	var player := get_player_by_id(player_id)
	players.erase(player)
	player.remove()


func get_player_by_id(id: int) -> Player:
	for player in players:
		if is_instance_valid(player):
			if player.player_id == id:
				return player
	return null


## Returns the Player of the local player.
func get_local_player() -> Player:
	return get_player_by_id(multiplayer.get_unique_id())
