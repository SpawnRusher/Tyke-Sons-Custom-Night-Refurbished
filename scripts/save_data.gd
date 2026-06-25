extends Node

var file_paths: Array[String] = ["user://tscn_settings.json","user://tscn_save.json"]
enum FILE_TYPE {SETTINGS, SAVE}

var default_settings_data: Dictionary = {
	"display": {
		"max_fps":max(60,DisplayServer.screen_get_refresh_rate()),
		"window_mode":DisplayServer.WINDOW_MODE_WINDOWED,
		"vsync_mode":DisplayServer.VSYNC_DISABLED,
		"antialiasing":get_viewport().DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	},
	"game": {
		"master_volume":50,
		"jumpscare_volume":50,
		"auto_restart_on_death":false,
		"skip_loading_night":false,
		"movement_mode":0
	},
	"keybinds": {
		"restart_night": {
			"type":"key",
			"physical_keycode":KEY_R
		},
		"return_to_menu": {
			"type":"key",
			"physical_keycode":KEY_F2
		},
		"toggle_lamp": {
			"type":"key",
			"physical_keycode":KEY_SHIFT
			},
		"go_to_sleep": {
			"type":"key",
			"physical_keycode":KEY_B
			},
		"close_curtain": {
			"type":"mouse_button",
			"button_index":1
		},
		"use_flashlight": {
			"type":"mouse_button",
			"button_index":2
		},
		"move_forward": {
			"type":"key",
			"physical_keycode":KEY_W
		},
		"move_left": {
			"type":"key",
			"physical_keycode":KEY_A
		},
		"move_backward": {
			"type":"key",
			"physical_keycode":KEY_S
		},
		"move_right": {
			"type":"key",
			"physical_keycode":KEY_D
		},
	},
	"gamejolt": {
		"username":"",
		"user_token":""
	},
}
	
var default_save_data: Dictionary = {
}
	
var settings_data_to_migrate: Dictionary = {
	"display": {
		"texture_filter":"antialiasing"
	}
}
	
var save_data_to_migrate: Dictionary = {
	
}

var settings_data: Dictionary = default_settings_data
var save_data: Dictionary = default_save_data
var save_data_encryption_key: String

var settings_data_file: FileAccess
var save_data_file: FileAccess

func _ready() -> void:
	if _check_for_file(FILE_TYPE.SETTINGS):
		_load_file(FILE_TYPE.SETTINGS)
	else:
		_create_file(FILE_TYPE.SETTINGS)

	if _check_for_file(FILE_TYPE.SAVE):
		_load_file(FILE_TYPE.SAVE)
	else:
		_create_file(FILE_TYPE.SAVE)
	
func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event is InputEventKey and event.is_pressed():
			if event.keycode == KEY_C:
				_save_file(FILE_TYPE.SETTINGS)
			if event.keycode == KEY_D:
				_save_file(FILE_TYPE.SAVE)
	
func _check_for_file(type: FILE_TYPE) -> bool:
	var check_file:= FileAccess.open(file_paths[type], FileAccess.READ)
	if check_file:
		check_file.close()
		return true
	check_file.close()
	return false
	
func _save_file(type: FILE_TYPE) -> void:
	if type == FILE_TYPE.SETTINGS:
		settings_data_file = FileAccess.open(file_paths[type], FileAccess.WRITE)
		settings_data_file.store_string(JSON.stringify(settings_data, "\t"))
		settings_data_file.close()
		_update_settings()
	elif type == FILE_TYPE.SAVE:
		save_data_file = FileAccess.open(file_paths[type], FileAccess.WRITE)
		save_data_file.store_string(JSON.stringify(save_data, "\t"))
		save_data_file.close()

func _load_file(type: FILE_TYPE) -> void:
	var json:= JSON.new()
	
	if type == FILE_TYPE.SETTINGS:
		settings_data_file = FileAccess.open(file_paths[type], FileAccess.READ_WRITE)
		json.parse(settings_data_file.get_as_text())
		if json.data:
			settings_data = json.data
		await _migrate_data(FILE_TYPE.SETTINGS)
		await _add_missing_data(FILE_TYPE.SETTINGS)
		_update_settings()
		_update_keybinds_actions()
	else:
		save_data_file = FileAccess.open(file_paths[type], FileAccess.READ_WRITE)
		json.parse(save_data_file.get_as_text())
		if json.data:
			save_data = json.data
		_migrate_data(FILE_TYPE.SAVE)
		_add_missing_data(FILE_TYPE.SAVE)

func _create_file(type: FILE_TYPE) -> void:
	var create_file:= FileAccess.open(file_paths[type], FileAccess.WRITE)
	create_file.store_string("")
	create_file.close()
	_load_file(type)
	
func _update_settings() -> void:
	AudioServer.set_bus_volume_linear(0,(settings_data["volume"]["master_volume"])/100.0)
	AudioServer.set_bus_volume_linear(1,(settings_data["volume"]["jumpscare_volume"])/100.0)
	
	DisplayServer.window_set_mode(settings_data["display"]["window_mode"])
	DisplayServer.window_set_vsync_mode(settings_data["display"]["vsync_mode"])
	
	Engine.max_fps = settings_data["display"]["max_fps"]
	
	get_tree().root.canvas_item_default_texture_filter = settings_data["display"]["antialiasing"]

func change_data(type: FILE_TYPE, value: Variant, key1: String, key2: String) -> void:
	if type == FILE_TYPE.SETTINGS:
		settings_data[key1][key2] = value
		print_debug("Settings data updated: [",key1,"][",key2,"] = " + str(value))
	elif type == FILE_TYPE.SAVE:
		save_data[key1][key2] = value
		print_debug("Save data updated: [", key1,"][",key2,"] = " + str(value))
	_save_file(type)

## Runs after loading settings and save data to migrate any old keys to new ones safely while maintaining values.[br]
## Currently only supports editing second keys.
func _migrate_data(type: FILE_TYPE) -> void:
	var temp_value: Variant
	var current_data: Dictionary
	var migrate_data: Dictionary
	
	# Gets the Settings and Save data dictionaries into one set of variables to not need to copy paste the same code twice
	if type == FILE_TYPE.SETTINGS:
		current_data = settings_data.duplicate_deep()
		migrate_data = settings_data_to_migrate.duplicate_deep()
	else:
		current_data = save_data.duplicate_deep()
		migrate_data = save_data_to_migrate.duplicate_deep()
		
	for first_key in migrate_data: # Loop the first-level keys (groups)
		if first_key in current_data:
			for second_key in migrate_data[first_key]: # Loop the second-level keys (the keys with the actual values, a.k.a. the settings or save data)
				if second_key in current_data[first_key]:
					temp_value = current_data[first_key][second_key] # Saves the value
					current_data[first_key].erase(second_key) # Delete the old key
					current_data[first_key][migrate_data[first_key][second_key]] = temp_value # Set the value on the new key. Done!
	
	# Update the Dictionaries for Settings and Save data
	if type == FILE_TYPE.SETTINGS:
		settings_data = current_data
		settings_data_to_migrate = migrate_data
	else:
		save_data = current_data
		save_data_to_migrate = migrate_data
	_save_file(type)

func _add_missing_data(type: FILE_TYPE) -> void:
	var current_data: Dictionary
	var default_data: Dictionary
	
	if type == FILE_TYPE.SETTINGS:
		current_data = settings_data
		default_data = default_settings_data
	else:
		current_data = save_data
		default_data = default_save_data
		
	for first_key in default_data:
		if first_key not in current_data:
			current_data[first_key] = {}
		if first_key in current_data:
			for second_key in default_data[first_key]:
				if second_key not in current_data[first_key]:
					current_data[first_key][second_key] = default_data[first_key][second_key]
	
	if type == FILE_TYPE.SETTINGS:
		settings_data = current_data
	else:
		save_data = current_data
	_save_file(type)

func _update_keybinds_actions() -> void:
	for action in settings_data["keybinds"]:
		InputMap.action_add_event(action,_deserialize_input_event(settings_data["keybinds"][action]))

func _deserialize_input_event(event: Dictionary) -> InputEvent:
	var new_event: InputEvent = null
	match event["type"]:
		"key":
			new_event = InputEventKey.new()
			new_event.physical_keycode = event["physical_keycode"]
			
		"mouse_button":
			new_event = InputEventMouseButton.new()
			new_event.button_index = event["button_index"]
			
			
	return new_event
		
