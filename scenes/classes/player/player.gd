class_name Player extends Node

## Nickname specified by the player.
@export var nick: String
## Kart that the player is going to use.
@export var kart_metadata: KartMetadata
## Kart that is loaded for the player.
@export var kart: Kart
## Unique ID assigned for multiplayer.
@export var player_id: int
## Is the player waiting to join the game in the next round?
@export var queued: bool
