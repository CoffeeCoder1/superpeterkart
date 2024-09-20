extends Control

signal character_selected(karts: Array[KartMetadata])

@export var kart_list: Array[KartMetadata]
var selected_karts: Array[KartMetadata]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for kart in kart_list:
		var button = Button.new()
		$GridContainer.add_child(button)
		
		var viewport = SubViewport.new()
		button.add_child(viewport)
		
		var kart_node = kart.instantiate()
		viewport.add_child(kart_node)
		button.text = kart.get_kart_name()
		
		button.pressed.connect(self._on_character_selected.bind(kart))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_character_selected(kart: KartMetadata) -> void:
	print(kart.get_kart_name())
	selected_karts.append(kart)
	character_selected.emit(selected_karts)
