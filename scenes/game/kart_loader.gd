class_name KartLoader extends Node

@export var players: PlayerList
@export var kart_list: KartList

var enabled: bool = false


## Sets the kart of the local player.
func set_local_player_kart(kart: KartMetadata) -> void:
	_set_local_player_kart.rpc_id(1, kart_list.get_kart_id(kart))


## Sets the kart of the player calling this method.
@rpc("any_peer", "reliable", "call_local")
func _set_local_player_kart(kart_id: String) -> void:
	var player_id := multiplayer.get_remote_sender_id()
	set_player_kart(player_id, kart_id)


## Sets a player's kart.
func set_player_kart(player_id: int, kart_id: String) -> void:
	var player := players.get_player_by_id(player_id)
	
	print(player.queued)
	
	player.kart_metadata = kart_list.get_kart_by_id(kart_id)
	
	# Spawn in the new player's kart
	if !player.queued:
		spawn_kart(player_id, kart_id)


## Load a kart in.
## Should only be called on the authority.
func spawn_kart(player_id: int, kart_id: String) -> void:
	_spawn_kart.rpc(player_id, kart_id)


@rpc("authority", "reliable", "call_local")
func _spawn_kart(player_id: int, kart_id: String) -> void:
	var kart_node := kart_list.get_kart_by_id(kart_id).instantiate() as Kart
	# Used to place the new kart in the same place the last one was.
	var old_transform: Transform3D
	
	var player := players.get_player_by_id(player_id)
	if player:
		if is_instance_valid(player.kart):
			old_transform = player.kart.transform
			player.kart.queue_free()
		player.kart = kart_node
	
	# Set the player's ID so the player can control the kart they spawned.
	kart_node.player_id = player_id
	
	# Disable the kart if the game hasn't started yet
	kart_node.kart_enabled = enabled
	
	# Spawn in the new kart.
	kart_node.set_name(kart_id + str(player_id))
	add_child(kart_node)
	
	if multiplayer.get_unique_id() == get_multiplayer_authority() and old_transform:
		kart_node.transform = old_transform


## Tells a client what the current karts are.
## Should only be called on the authority.
func sync_to_client(player_id: int) -> void:
	# Add the current players
	for player in players.players:
		if player.kart:
			_spawn_kart.rpc_id(player_id, player.player_id, kart_list.get_kart_id(player.kart_metadata))


## Spawns in any queued players.
## Should only be called on the authority.
func spawn_queued_players() -> void:
	for player in players.players:
		if player.kart_metadata and player.queued:
			player.queued = false
			spawn_kart(player.player_id, kart_list.get_kart_id(player.kart_metadata))


## Enables or disables the players.
## Should only be called on the authority.
func set_players_enabled(enabled: bool) -> void:
	_set_players_enabled.rpc(enabled)


@rpc("authority", "reliable", "call_local")
func _set_players_enabled(enabled: bool) -> void:
	for player in players.players:
		if player.kart:
			player.kart.kart_enabled = enabled
	self.enabled = enabled


## Prepares the players for a game start.
## Should only be called on the authority.
func prepare_players(map_spawn_location: Transform3D) -> void:
	# Prepare karts
	for i in len(players.players):
		var player := players.players[i]
		if player.kart:
			# Unload preview kart if it exists
			if is_instance_valid(player.preview_kart):
				player.preview_kart.queue_free()
			# Move the kart to the spawn location
			player.kart.transform = map_spawn_location.translated(Vector3.RIGHT * (2 * i))
			# Set their velocity to 0
			player.kart.velocity = Vector3.ZERO
	
	# Enable players
	set_players_enabled(true)
