class_name CharacterButton extends TextureButton

@export var character_preview_world_scene: PackedScene = preload("res://scenes/classes/character_preview/character_preview_world.tscn")
@export var kart: KartMetadata:
	set(new_kart):
		# Set the kart to the new kart
		kart = new_kart
		
		# Create a new CharacterPreviewWorld for the kart
		var character_preview_world = character_preview_world_scene.instantiate()
		character_preview_world.kart = new_kart
		add_child(character_preview_world)
		
		# Set the button texture to the viewport texture
		texture_normal = character_preview_world.get_texture()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
