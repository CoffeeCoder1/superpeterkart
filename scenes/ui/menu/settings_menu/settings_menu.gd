extends Menu

@onready var nickname_edit: LineEdit = %NicknameEdit
@onready var fps_counter_button: CheckButton = %FPSCounterButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameSettings.profile_changed.connect(_on_profile_changed)
	GameSettings.fps_counter_enabled_changed.connect(_on_fps_counter_enabled_changed)


func _on_profile_changed(new_profile: PlayerProfile) -> void:
	nickname_edit.text = new_profile.nickname


func _on_nickname_edit_text_submitted(new_text: String) -> void:
	GameSettings.profile.nickname = new_text


func _on_fps_counter_enabled_changed(enabled: bool) -> void:
	fps_counter_button.button_pressed = enabled


func _on_fps_counter_button_toggled(toggled_on: bool) -> void:
	GameSettings.fps_counter_enabled = toggled_on
