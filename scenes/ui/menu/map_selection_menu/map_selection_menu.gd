extends Control

signal map_selected(map: MapMetadata)

@export var maps: Array[MapMetadata]
var selected_map: MapMetadata

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for map in maps:
		var button = Button.new()
		$GridContainer.add_child(button)
		
		button.text = map.get_map_name()
		
		button.pressed.connect(self._on_map_selected.bind(map))


# Called when a map is selected
func _on_map_selected(map: MapMetadata) -> void:
	selected_map = map
	map_selected.emit(selected_map)
