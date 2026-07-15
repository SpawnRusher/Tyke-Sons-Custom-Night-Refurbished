extends Node

#region GAME SETTINGS
var ENABLED_IDS: Array[bool]
var sleep_assurance_points: int = 1
var current_preset_name: String
var survival_mode: bool
#endregion
var win_sleep_assurance: float
var win_time: int


var dead_enemy_id: Enemy.ENEMY_IDS = Enemy.ENEMY_IDS.NOT_SET
var dead_sleep_assurance: float
var dead_time: int

var version_type: PastebinChecks.VERSION_TYPE
var pastebin_version: String

enum FLASHLIGHT_STATES {DEAD=-1, OFF, ON}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ENABLED_IDS.resize(14)
	SignalBus.pastebin_version_check.connect(_pastebin_version_check)

func _pastebin_version_check(vt: PastebinChecks.VERSION_TYPE, pb_v: String) -> void:
	version_type = vt
	pastebin_version = pb_v

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("return_to_menu"):
		PauseManager.unpause()
		SceneManager.change_to_scene("res://scenes/menu.tscn")
	if event.is_action_pressed("restart_night"):
		PauseManager.unpause()
		if get_tree().current_scene.scene_file_path == "res://scenes/night.tscn":
			get_tree().reload_current_scene()
		elif get_tree().current_scene.scene_file_path == "res://scenes/game_over.tscn":
			SceneManager.change_to_scene("res://scenes/night.tscn")
