extends Node

var ENABLED_IDS: Array[bool] = []

var died_to_id: int

var version_type: String
var pastebin_version: String

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ENABLED_IDS.resize(16)
	SignalBus.pastebin_version_check.connect(_pastebin_version_check)
	
func _pastebin_version_check(vt,pb_v) -> void:
	version_type = vt
	pastebin_version = pb_v

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Return_To_Menu"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
		print("returntomenu")
	if event.is_action_pressed("Restart_Night") and get_tree().current_scene.scene_file_path == "res://scenes/night.tscn":
		get_tree().reload_current_scene()
		print("restart")
