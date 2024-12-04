extends Control

@export var kart_list: KartList
@export var button_minimum_size: Vector2 = Vector2(100, 100)
## Should the character menu wait for the server to advance?
@export var timed: bool = false
@export var timer_time: float = 15.0

## Emitted when a character is selected on the client that selected the player.
## If the client didn't select a player, this will be emitted on timeout with a random player.
signal character_selected(kart: KartMetadata)
## Emitted when the timer ends or the menu is closed.
signal menu_advance

@onready var button_container: GridContainer = $ButtonContainer
@onready var timer_label: Label = $TimerLabel

var selected_kart: KartMetadata
var time_left: float


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


func _process(delta: float) -> void:
	if timed and multiplayer.get_unique_id() == get_multiplayer_authority():
		if time_left <= 0:
			_timeout_reached.rpc()
			time_left = 0
			timed = false
		else:
			time_left -= delta
			_sync_time.rpc(time_left)
	timer_label.text = str(time_left)


## Starts character selection and keeps clients synced to authority.
func start() -> void:
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		select_remote.rpc()


## Selects a kart and doesn't wait for the server.
## The server will take over if it starts character selection.
func select_local() -> void:
	timed = false


@rpc("authority", "reliable", "call_local")
func select_remote() -> void:
	timed = true
	time_left = timer_time


## Syncs time to a client
@rpc("authority", "reliable")
func _sync_time(time: float) -> void:
	time_left = time


func _on_character_selected(kart: KartMetadata) -> void:
	selected_kart = kart
	character_selected.emit(kart)
	if not timed:
		_timeout_reached()


## Called by the authority when the menu timeout is reached.
## Called locally when timed is false.
@rpc("authority", "reliable", "call_local")
func _timeout_reached() -> void:
	# Pick a random kart if the player didn't pick one.
	if !selected_kart:
		character_selected.emit(kart_list.karts.pick_random())
	menu_advance.emit()
