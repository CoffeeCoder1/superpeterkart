extends Menu

@export var kart_list: KartList
@export var game: Game
@export var button_minimum_size: Vector2 = Vector2(100, 100)

## Emitted when a character is selected on the client that selected the player.
## If the client didn't select a player, this will be emitted on timeout with a random player.
signal character_selected(kart: KartMetadata)
## Emitted when the timer ends or the menu is closed.
signal menu_advance

@onready var button_container: GridContainer = $ButtonContainer

var selected_kart: KartMetadata


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for kart in kart_list.get_karts():
		# Create a button
		var button_node = CharacterButton.new()
		button_node.kart = kart
		
		button_node.custom_minimum_size = button_minimum_size
		
		# Add the button to the button grid
		button_container.add_child(button_node)
		
		# Connect the pressed signal from the button
		button_node.pressed.connect(self._on_character_selected.bind(kart))


func _on_character_selected(kart: KartMetadata) -> void:
	selected_kart = kart
	character_selected.emit(kart)
	if game.game_state == Game.GameState.PLAYING:
		_selection_ended()


func _on_next_button() -> void:
	_selection_ended.rpc()


## Called by the authority when selection ends.
## Called locally when the game is in progress.
@rpc("authority", "reliable", "call_local")
func _selection_ended() -> void:
	# Pick a random kart if the player didn't pick one.
	if !selected_kart:
		character_selected.emit(kart_list.karts.pick_random())
	menu_advance.emit()
