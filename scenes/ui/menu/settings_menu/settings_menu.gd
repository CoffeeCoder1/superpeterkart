extends Menu

@onready var nickname_edit: LineEdit = %NicknameEdit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameSettings.profile_changed.connect(_on_profile_changed)


func _on_profile_changed(new_profile: PlayerProfile) -> void:
	nickname_edit.text = new_profile.nickname


func _on_nickname_edit_text_submitted(new_text: String) -> void:
	GameSettings.profile.nickname = new_text
