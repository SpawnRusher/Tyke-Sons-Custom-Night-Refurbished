extends Button

const BUTTON_PRESS_LOUD: AudioStream = preload("uid://dljncvmipnl1d")

@export var settings_menu: Control
@export var tab: VBoxContainer

func _on_pressed() -> void:
	settings_menu.reset_to_defaults.emit(tab.name.to_lower())
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD)
