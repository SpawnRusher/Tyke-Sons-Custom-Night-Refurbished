extends Button

const LOUD_BUTTON_PRESS: AudioStream = preload("uid://dljncvmipnl1d")

@export var settings_menu: Control
@export var tab_name: String

func _on_pressed() -> void:
	settings_menu.reset_to_defaults.emit(tab_name)
	SpecialFunctions.audio(LOUD_BUTTON_PRESS)
