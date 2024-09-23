class_name CharacterButton extends Button

var character_preview_world: Node

@export var character_preview_world_scene: PackedScene = preload("res://scenes/classes/character_preview/character_preview_world.tscn")
@export var kart: KartMetadata:
	set(new_kart):
		# Set the kart to the new kart
		kart = new_kart


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hidden.connect(_on_hide)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_hide() -> void:
	# Remove the texture so Godot doesn't try to draw it and error because the viewport doesn't exist
	if icon:
		icon = null
	
	# Unload the character preview world to save memory
	if character_preview_world:
		character_preview_world.queue_free()


func _draw() -> void:
	# Create a new CharacterPreviewWorld for the kart if it doesn't already exist
	if !character_preview_world:
		character_preview_world = character_preview_world_scene.instantiate()
		add_child(character_preview_world)
	
	# Set the preview world kart
	character_preview_world.kart = kart
	
	# Set the button texture to the viewport texture
	icon = character_preview_world.get_texture()
