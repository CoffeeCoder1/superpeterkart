extends Menu

## List of maps to show.
@export var map_list: MapList
@export var player_list: PlayerList

## Emitted on all clients when the map selection ends.
## Should only trigger a map load on the server.
signal map_selected(map: MapMetadata)

@onready var map_card_container: GridContainer = $MapCardContainer

var selected_map: MapMetadata


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for map in map_list.maps:
		var button = Button.new()
		map_card_container.add_child(button)
		
		button.text = map.get_map_name()
		button.custom_minimum_size = Vector2(100, 100)
		
		button.pressed.connect(self._on_map_selected.bind(map))


## Called when a map is selected.
func _on_map_selected(map: MapMetadata) -> void:
	selected_map = map
	set_map_vote.rpc_id(1, map_list.get_map_id(map))


## Sets the calling player's map vote.
## Should only be called on the authority.
@rpc("any_peer", "reliable", "call_local")
func set_map_vote(map_id: String) -> void:
	_set_map_vote.rpc(map_id, multiplayer.get_remote_sender_id())


## Sets a player's map vote.
@rpc("authority", "reliable", "call_local")
func _set_map_vote(map_id: String, player_id: int) -> void:
	var player := player_list.get_player_by_id(player_id)
	if is_instance_valid(player):
		player.map_vote = map_id


func _on_next_button() -> void:
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		var map_votes: Dictionary
		
		# Count how many players voted for each map
		for player in player_list.players:
			if player.map_vote:
				map_votes[player.map_vote] = map_votes.get(player.map_vote, 0) + 1
		
		# Find highest voted maps
		var selected_maps: Array[String]
		var highest_value: int
		for key in map_votes:
			if map_votes[key] > highest_value:
				selected_maps.clear()
				highest_value = map_votes[key]
			
			if map_votes[key] == highest_value:
				selected_maps.append(key)
		
		# If nobody chose a map, pick a random one.
		if selected_maps.is_empty():
			selected_maps.append(map_list.get_maps().pick_random().get_map_id())
		
		_map_selected.rpc(selected_maps.pick_random())


## Called by authority when the map vote ends.
@rpc("authority", "reliable", "call_local")
func _map_selected(map_id: String) -> void:
	print(map_id)
	map_selected.emit(map_list.get_map_by_id(map_id))
