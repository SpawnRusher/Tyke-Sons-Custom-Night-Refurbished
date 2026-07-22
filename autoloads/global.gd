extends Node

#region GAME SETTINGS
var ENABLED_IDS: Array[bool]
var sleep_assurance_points: int = 1
var current_preset_name: String
var survival_mode: bool
#endregion
var win_sleep_assurance: float
var win_time: int


var dead_enemy_id: Enemy.ENEMY_IDS = -1
var dead_sleep_assurance: float
var dead_time: int

var version_type: PastebinChecks.VERSION_TYPE
var pastebin_version: String

enum FLASHLIGHT_STATES {DEAD=-1, OFF, ON}

var scene_start_time: int
var scene_time: int

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ENABLED_IDS.resize(14)
	SignalBus.pastebin_version_check.connect(_pastebin_version_check)
	SceneManager.scene_changing.connect(_scene_changing)
	SceneManager.scene_reloading.connect(_scene_reloading)
	SceneManager.scene_changed.connect(_update_scene_start_time.unbind(2))
	SceneManager.scene_reloaded.connect(_update_scene_start_time.unbind(1))

func _process(delta: float) -> void:
	scene_time = Time.get_ticks_msec() - scene_start_time

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveData.set_data(SaveData.FILE_TYPE.SAVE,["statistics","playtime","general","total"],Time.get_ticks_msec(),SaveData.SET_DATA_SPECIAL.ADD)

func _scene_changing(previous: String, next: String) -> void:	
	match previous:
		"res://scenes/menu.tscn":
			SaveData.set_data(SaveData.FILE_TYPE.SAVE,["statistics","playtime","general","menu"],scene_time,SaveData.SET_DATA_SPECIAL.ADD)
		"res://scenes/gamejolt_menu.tscn":
			SaveData.set_data(SaveData.FILE_TYPE.SAVE,["statistics","playtime","general","gamejolt_menu"],scene_time,SaveData.SET_DATA_SPECIAL.ADD)
		
func _scene_reloading(path: String) -> void:
	if path == "res://scenes/night.tscn":
		SaveData.set_data(SaveData.FILE_TYPE.SAVE,["statistics","playtime","general","night"],scene_time,SaveData.SET_DATA_SPECIAL.ADD)
		SaveData.set_data(SaveData.FILE_TYPE.SAVE,["statistics","playtime","presets",Global.current_preset_name],scene_time,SaveData.SET_DATA_SPECIAL.ADD)

func _update_scene_start_time() -> void:
	scene_start_time = Time.get_ticks_msec()

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
			SceneManager.reload_scene()
		elif get_tree().current_scene.scene_file_path == "res://scenes/game_over.tscn":
			SceneManager.change_to_scene("res://scenes/night.tscn")
