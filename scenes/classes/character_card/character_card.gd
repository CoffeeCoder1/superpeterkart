class_name CharacterCard extends Control

@export var player: Player
@export var map_list: MapList
## Show what place that the player ended in.
@export var show_places: bool = false
## Show what map the player voted for.
@export var show_map_vote: bool = false

@onready var place_label: Label = %PlaceLabel
@onready var name_label: Label = %NameLabel
@onready var character_display: CharacterPreviewRect = %CharacterDisplay
@onready var map_label: Label = %MapLabel


func _process(delta: float) -> void:
	place_label.visible = show_places
	map_label.visible = show_map_vote
	
	if is_instance_valid(player):
		place_label.text = str(player.place + 1)
		name_label.text = player.nick
		
		# If no preview kart exists, create one
		# TODO: Remove this from process loop
		if !is_instance_valid(player.preview_kart) and player.kart_metadata:
			player.preview_kart = player.kart_metadata.instantiate()
		
		character_display.kart = player.preview_kart
		
		var map_vote := map_list.get_map_by_id(player.map_vote)
		if is_instance_valid(map_vote):
			map_label.text = map_vote.get_map_name()
