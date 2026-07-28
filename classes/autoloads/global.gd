extends Node

var pastebin_current_version: String

var scene_start_time: int
var scene_time: int

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	SceneManager.scene_changing.connect(_scene_changing)
	SceneManager.scene_reloading.connect(_scene_reloading)
	SceneManager.scene_changed.connect(_update_scene_start_time.unbind(2))
	SceneManager.scene_reloaded.connect(_update_scene_start_time.unbind(1))

func _process(delta: float) -> void:
	scene_time = Time.get_ticks_msec() - scene_start_time

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveData.set_data(SaveData.FILE_TYPE.SAVE,["statistics","playtime","total"],Time.get_ticks_msec(),SaveData.SET_DATA_SPECIAL.ADD)

func _scene_changing(previous: String, next: String) -> void:	
	if previous == "res://scenes/menu/menu.tscn":
		SaveData.set_data(SaveData.FILE_TYPE.SAVE,["statistics","playtime","menu"],scene_time,SaveData.SET_DATA_SPECIAL.ADD)
		
func _scene_reloading(path: String) -> void:
	if path == "res://scenes/night/night.tscn":
		SaveData.set_data(SaveData.FILE_TYPE.SAVE,["statistics","playtime","night"],scene_time,SaveData.SET_DATA_SPECIAL.ADD)
		SaveData.set_data(SaveData.FILE_TYPE.SAVE,["statistics","playtime",GameInfo.current_preset_name],scene_time,SaveData.SET_DATA_SPECIAL.ADD)

func _update_scene_start_time() -> void:
	scene_start_time = Time.get_ticks_msec()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("return_to_menu"):
		PauseManager.unpause()
		SceneManager.change_to_scene("res://scenes/menu/menu.tscn")
	if event.is_action_pressed("restart_night"):
		PauseManager.unpause()
		if get_tree().current_scene.scene_file_path == "res://scenes/night/night.tscn":
			SceneManager.reload_scene()
		elif get_tree().current_scene.scene_file_path == "res://scenes/game_over/game_over.tscn":
			SceneManager.change_to_scene("res://scenes/night/night.tscn")
