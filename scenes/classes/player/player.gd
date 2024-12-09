class_name Player extends Node

## Nickname specified by the player.
@export var nick: String = "There's no way to set this yet so you'll just be named this."
## Kart that the player is going to use.
@export var kart_metadata: KartMetadata
## Kart that is loaded for the player.
@export var kart: Kart
## Kart that is loaded for character previews.
@export var preview_kart: Kart
## Unique ID assigned for multiplayer.
@export var player_id: int
## Is the player waiting to join the game in the next round?
@export var queued: bool
## What map has the player voted for?
@export var map_vote: String
## What lap is the player on?
@export var lap: int
## What place did the player end in?
@export var place: int
