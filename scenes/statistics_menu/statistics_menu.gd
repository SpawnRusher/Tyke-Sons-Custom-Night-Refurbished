extends Control

const BUTTON_PRESS_LOUD = preload("uid://dljncvmipnl1d")

func _ready() -> void:
	pass

func _on_tab_container_tab_changed(tab: int) -> void:
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD)
