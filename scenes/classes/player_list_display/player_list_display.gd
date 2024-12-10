class_name PlayerListDisplay extends VBoxContainer

@export var player_list: PlayerList
## Show the places that each player ended in.
@export var show_places: bool = false:
	set(new_show_places):
		for card in character_cards:
			var character_card = character_cards[card] as CharacterCard
			character_card.show_places = new_show_places
		show_places = new_show_places
## Show what maps each player voted for.
@export var show_map_vote: bool = false:
	set(new_show_map_vote):
		for card in character_cards:
			var character_card = character_cards[card] as CharacterCard
			character_card.show_map_vote = new_show_map_vote
		show_map_vote = new_show_map_vote

const CHARACTER_CARD = preload("res://scenes/classes/character_card/character_card.tscn")

var character_cards: Dictionary


func _process(delta: float) -> void:
	if player_list:
		for player in player_list.players:
			if not character_cards.has(player.player_id):
				# Create a character card for any players that don't have one
				var character_card = CHARACTER_CARD.instantiate()
				character_cards[player.player_id] = character_card
				
				character_card.player = player
				character_card.show_places = show_places
				
				add_child(character_card)
