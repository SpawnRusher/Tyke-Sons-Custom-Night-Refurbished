extends Node

var ENABLED_IDS: Array[bool] = []

var died_to_id: int

var version_type: String
var pastebin_version: String

func _ready() -> void:
	SignalBus.pastebin_version_check.connect(_pastebin_version_check)
	
func _pastebin_version_check(vt,pb_v) -> void:
	version_type = vt
	pastebin_version = pb_v

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == SaveData.config_file.get_value("keybinds","return_to_menu",SaveData.default_keybinds["return_to_menu"]):
			get_tree().change_scene_to_file("res://scenes/menu.tscn")
		if event.keycode == SaveData.config_file.get_value("keybinds","restart_night",SaveData.default_keybinds["restart_night"]):
			get_tree().reload_current_scene()
