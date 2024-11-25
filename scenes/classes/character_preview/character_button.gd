class_name CharacterButton extends Button

var character_preview_world: CharacterPreviewWorld
var kart_node: Kart:
	set(new_kart_node):
		if is_instance_valid(character_preview_world):
			character_preview_world.kart = new_kart_node
		
		kart_node = new_kart_node

@export var character_preview_world_scene: PackedScene = preload("res://scenes/classes/character_preview/character_preview_world.tscn")
@export var kart: KartMetadata:
	set(new_kart):
		# Swap the kart out if the kart has changed
		if kart != new_kart:
			_load_kart(new_kart)
		
		# Set the kart to the new kart
		kart = new_kart


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hidden.connect(_on_hide)
	draw.connect(_on_draw)
	expand_icon = true


func _load_kart(kart: KartMetadata) -> void:
	# If a kart already exists, delete it
	if is_instance_valid(kart_node):
		kart_node.queue_free()
	
	# Instantiate the new kart
	kart_node = kart.instantiate()


func _on_hide() -> void:
	# Remove the texture so Godot doesn't try to draw it and error because the viewport doesn't exist
	if icon:
		icon = null
	
	# Unload the character preview world to save memory
	if is_instance_valid(character_preview_world):
		character_preview_world.queue_free()


func _on_draw() -> void:
	# Create a new CharacterPreviewWorld for the kart if it doesn't already exist
	if !is_instance_valid(character_preview_world):
		character_preview_world = character_preview_world_scene.instantiate()
		add_child(character_preview_world)
	
	# Load the kart if it doesn't exist
	if !is_instance_valid(kart_node):
		_load_kart(kart)
	
	# Set the preview world kart
	character_preview_world.kart = kart_node
	
	# Set the button texture to the viewport texture
	await RenderingServer.frame_post_draw
	icon = character_preview_world.get_texture()
