class_name CharacterPreviewRect extends TextureRect

var character_preview_world: CharacterPreviewWorld

@export var character_preview_world_scene: PackedScene = preload("res://scenes/classes/character_preview/character_preview_world.tscn")
@export var kart: Kart:
	set(new_kart):
		# Swap the kart out if the kart has changed
		if kart != new_kart and is_instance_valid(character_preview_world):
			character_preview_world.kart = new_kart
		
		# Set the kart to the new kart
		kart = new_kart


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hidden.connect(_on_hide)


func _on_hide() -> void:
	# Remove the texture so Godot doesn't try to draw it and error because the viewport doesn't exist
	if texture:
		texture = null
	
	# Unload the character preview world to save memory
	if is_instance_valid(character_preview_world):
		# Don't queue free the kart with the preview world
		kart.get_parent().remove_child(kart)
		character_preview_world.queue_free()


func _draw() -> void:
	# Create a new CharacterPreviewWorld for the kart if it doesn't already exist
	if !character_preview_world:
		character_preview_world = character_preview_world_scene.instantiate()
		add_child(character_preview_world)
	
	# Set the button texture to the viewport texture
	texture = character_preview_world.get_texture()
