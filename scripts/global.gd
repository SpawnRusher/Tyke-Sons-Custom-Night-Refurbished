extends Node

var ENABLED_IDS: Array[bool]

var died_to_id: Enemy.ENEMY_IDS

var version_type: PastebinChecks.VERSION_TYPE
var pastebin_version: String

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ENABLED_IDS.resize(16)
	SignalBus.pastebin_version_check.connect(_pastebin_version_check)
	
func _pastebin_version_check(vt: PastebinChecks.VERSION_TYPE, pb_v: String) -> void:
	version_type = vt
	pastebin_version = pb_v

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("return_to_menu"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
		print("returntomenu")
	if event.is_action_pressed("restart_night"):
		if get_tree().current_scene.scene_file_path == "res://scenes/night.tscn":
			get_tree().paused = false
			get_tree().reload_current_scene()
			print("restart")
		elif get_tree().current_scene.scene_file_path == "res://scenes/game_over.tscn":
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/night.tscn")
			print("restart from gameover")
