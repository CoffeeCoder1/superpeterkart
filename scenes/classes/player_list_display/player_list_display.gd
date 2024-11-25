class_name PlayerListDisplay extends Control

@export var player_list: PlayerList

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
				
				add_child(character_card)
