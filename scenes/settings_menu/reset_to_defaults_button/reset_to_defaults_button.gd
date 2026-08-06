extends Button

const BUTTON_PRESS_LOUD: AudioStream = preload("uid://dljncvmipnl1d")

@export var settings_menu: Control
@export var tab_name: String

func _on_pressed() -> void:
	settings_menu.reset_to_defaults.emit(tab_name)
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD)
