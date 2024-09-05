extends Control

signal character_selected(karts: Array[Node])

@export var karts: Array[PackedScene]
var selected_karts: Array[Node]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for e in karts:
		var button = Button.new()
		$GridContainer.add_child(button)
		
		var viewport = SubViewport.new()
		button.add_child(viewport)
		
		var kart = e.instantiate()
		viewport.add_child(kart)
		button.text = kart.get_kart_name()
		
		button.pressed.connect(self._on_character_selected.bind(kart))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_character_selected(kart: Node) -> void:
	print(kart.get_kart_name())
	selected_karts.append(kart)
	kart.get_parent().remove_child(kart)
	character_selected.emit(selected_karts)
