extends Menu

@export var player_list: PlayerList

signal menu_advance

@onready var player_list_display: PlayerListDisplay = $PlayerListDisplay


func _update() -> void:
	# Sort players by place
	var sorted_player_list: PlayerList = player_list
	sorted_player_list.players.sort_custom(func(a, b): return a.place < b.place)
	
	# Display players
	player_list_display.player_list = sorted_player_list


func _on_next_button() -> void:
	menu_advance.emit()
