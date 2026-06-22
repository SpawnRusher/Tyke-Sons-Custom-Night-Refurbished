extends Node

var file_paths: Dictionary[String,String] = {"settings":"user://tscn_settings.json","save":"user://tscn_save.json"}


var default_settings_data: Dictionary = {
	"volume": {
		"master_volume":50,
		"jumpscare_volume":50
		},
	"display": {
		"max_fps":max(60,DisplayServer.screen_get_refresh_rate()),
		"window_mode":DisplayServer.WINDOW_MODE_WINDOWED,
		"vsync_mode":DisplayServer.VSYNC_DISABLED,
		"texture_filter":get_viewport().DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		}
	}

var settings_data: Dictionary = default_settings_data
var save_data: Dictionary
var save_data_encryption_key: String

func _ready() -> void:
	load_file("settings")
	load_file("save")
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_C:
			save_file("settings")
		if event.keycode == KEY_D:
			save_file("save")
	
func save_file(type: String) -> void:
	var path:= file_paths[type]
	var file:= FileAccess.open(path, FileAccess.WRITE)
	if type == "settings":
		file.store_string(JSON.stringify(settings_data, "\t"))
		_update_settings()
	elif type == "save":
		file.store_string(JSON.stringify(save_data, "\t"))
	else:
		push_error("Incorrect type used when attempting to save!")

func load_file(type: String) -> void:
	var path:= file_paths[type]
	var file:= FileAccess.open(path, FileAccess.READ)
	var json:= JSON.new()
	
	if FileAccess.file_exists(path):
		json.parse(file.get_as_text())
		if type == "settings":
			settings_data = json.data
			_update_settings()
		elif type == "save":
			save_data = json.data
		else:
			push_error("Failed to load data as the type was incorrect.")

func _update_settings() -> void:
	AudioServer.set_bus_volume_linear(0,(settings_data["volume"]["master_volume"])/100.0)
	AudioServer.set_bus_volume_linear(1,(settings_data["volume"]["jumpscare_volume"])/100.0)
	
	Engine.max_fps = settings_data["display"]["max_fps"]

	DisplayServer.window_set_mode(settings_data["display"]["window_mode"])
	DisplayServer.window_set_vsync_mode(settings_data["display"]["vsync_mode"])
	
	get_tree().root.canvas_item_default_texture_filter = settings_data["display"]["texture_filter"]

## Pass an array of keys!
func change_data(type: String, value: Variant, key1: String, key2: String) -> void:
	if type != "settings" and type != "save":
		push_error("Failed to change data as incorrect type was used.")
		return
	if type == "settings":
		settings_data[key1][key2] = value
		print("Settings data updated: [", key1,"][",key2,"] = " + str(value))
	elif type == "save":
		save_data[key1][key2] = value
		print("Save data updated: [", key1,"][",key2,"] = " + str(value))
	save_file(type)
