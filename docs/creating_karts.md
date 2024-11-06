# Creating a Kart

Karts should be of type Kart, and need to have the following nodes to function.

* CollisionShape (required by CharacterBody3D)
* Camera3D (used to follow the player)
* MultiplayerSynchronizer (used to sync properties in multiplayer, should sync position, rotation,
	and any kart-specific stuff that needs to be displayed on all clients)
