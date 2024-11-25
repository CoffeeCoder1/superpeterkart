extends Control

@export var kart_list: KartList
@export var button_minimum_size: Vector2 = Vector2(100, 100)

signal character_selected(karts: Array[KartMetadata])

var selected_karts: Array[KartMetadata]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for kart in kart_list.get_karts():
		# Create a button
		var button_node = CharacterButton.new()
		button_node.kart = kart
		
		button_node.custom_minimum_size = button_minimum_size
		
		# Add the button to the button grid
		$GridContainer.add_child(button_node)
		
		# Connect the pressed signal from the button
		button_node.pressed.connect(self._on_character_selected.bind(kart))


func _on_character_selected(kart: KartMetadata) -> void:
	print(kart.get_kart_name())
	selected_karts.append(kart)
	character_selected.emit(selected_karts)
