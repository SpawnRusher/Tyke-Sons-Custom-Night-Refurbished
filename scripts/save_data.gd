extends Node

const file_paths: Array[String] = ["user://tscn_settings.json","user://tscn_save.json"]
enum FILE_TYPE {SETTINGS, SAVE, DEFAULT_SETTINGS, DEFAULT_SAVE}
enum SET_DATA_SPECIAL {NONE,TOGGLE_BOOL,ADD,SUBTRACT,MULTIPLY,DIVIDE,DIVIDE_INT,MODULO,EXPONENT,ROOT}

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
		"use_old_camera_scrolling":false,
		"use_old_front_window_hitbox":false,
		"movement_mode":0,
		"top_screen_margin":100,
		"left_screen_margin":100,
		"bottom_screen_margin":100,
		"right_screen_margin":100
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
		"click_front_window": {
			"type":"mouse_button",
			"button_index":1
		},
		"click_move": {
			"type":"mouse_button",
			"button_index":1
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
		"user_token":"",
		"auto_login":false
	},}
	
var default_save_data: Dictionary = {
	"statistics": {
		"deaths": {
			Enemy.ENEMY_IDS.CHIPOMAT_1:0,
			Enemy.ENEMY_IDS.CHIPOMAT_2:0,
			Enemy.ENEMY_IDS.CHIPOMAT_3:0,
			Enemy.ENEMY_IDS.FUN_FUNGAL:0,
			Enemy.ENEMY_IDS.SPRINGCRAB:0,
			Enemy.ENEMY_IDS.NIGHTMARE_CHIPPER:0,
			Enemy.ENEMY_IDS.SEABILL:0,
			Enemy.ENEMY_IDS.FREDBEAR:0,
			Enemy.ENEMY_IDS.BIDY:0,
			Enemy.ENEMY_IDS.BUSTER:0,
			Enemy.ENEMY_IDS.BRUCE:0,
			Enemy.ENEMY_IDS.CHIPPER:0,
			Enemy.ENEMY_IDS.TOY:0,
			Enemy.ENEMY_IDS.PHANTOM_CHIPOMAT:0,
			Enemy.ENEMY_IDS.HAPPYSHROOM:0,
		},
		"flashlight_battery_used":0,
		"flashlight_batteries_picked_up":0,
		"total_flashes":0,
		
	}}
	
var settings_data_to_migrate: Dictionary = {
	"display": {
		"texture_filter":"antialiasing"
	},
	"game": {
		"forward_screen_margin":"top_screen_margin",
		"backward_screen_margin":"bottom_screen_margin"
	},
	"keybinds": {
		"Toggle Lamp":"toggle_lamp"
	},}
	
var save_data_to_migrate: Dictionary = {}

var settings_data: Dictionary = default_settings_data
var save_data: Dictionary = default_save_data
var save_data_encryption_key: String

var settings_data_file: FileAccess
var save_data_file: FileAccess

signal settings_data_loaded
signal save_data_loaded

func _ready() -> void:
	@warning_ignore_start("standalone_ternary")
	_load_file(FILE_TYPE.SETTINGS) if _check_for_file(FILE_TYPE.SETTINGS) else _create_file(FILE_TYPE.SETTINGS)
	_load_file(FILE_TYPE.SAVE) if _check_for_file(FILE_TYPE.SAVE) else _create_file(FILE_TYPE.SAVE)

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
		_save_file(type)
		settings_data_loaded.emit()
		_update_settings()
		_update_keybinds_actions()
	else:
		save_data_file = FileAccess.open(file_paths[type], FileAccess.READ_WRITE)
		json.parse(save_data_file.get_as_text())
		if json.data:
			save_data = json.data
		_save_file(type)
		save_data_loaded.emit()
		_migrate_data(FILE_TYPE.SAVE)
		_add_missing_data(FILE_TYPE.SAVE)

func _create_file(type: FILE_TYPE) -> void:
	var create_file:= FileAccess.open(file_paths[type], FileAccess.WRITE)
	create_file.store_string("")
	create_file.close()
	_load_file(type)
	
func _update_settings() -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"),(settings_data["game"]["master_volume"])/100.0)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Jumpscare"),(settings_data["game"]["jumpscare_volume"])/100.0)
	
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

func set_data(type: FILE_TYPE, keys: Array[String], value: Variant, special:= SET_DATA_SPECIAL.NONE) -> void:
	var current_dict: Dictionary = [settings_data,save_data][type]
	var key: Variant
	for i in keys.size():
		key = keys[i]
		if current_dict[key] is not Dictionary:
			break
		if not current_dict.has(key):
			push_error("Failed to set data as key ", key, " is not present in ", FILE_TYPE.keys()[type], keys)
			return
		current_dict = current_dict[key]
		
	if special == SET_DATA_SPECIAL.TOGGLE_BOOL:
		if current_dict[keys[keys.size()-1]] is not bool:
			push_error("Cannot run set_data special operation ", SET_DATA_SPECIAL.keys()[special], " as the ", FILE_TYPE.keys()[type], " data being modified is not a boolean.")
			return
		if value is not bool:
			push_error("Cannot run set_data special operation ", SET_DATA_SPECIAL.keys()[special], " as the value parameter is not a boolean.")
			return
	
	if special > SET_DATA_SPECIAL.TOGGLE_BOOL:
		if current_dict[keys[keys.size()-1]] is not int and current_dict[keys[keys.size()-1]] is not float:
			push_error("Cannot run set_data special operation ", SET_DATA_SPECIAL.keys()[special], " as the ", FILE_TYPE.keys()[type], " data being modified is not numerical.")
			return
		if value is not int and value is not float:
			push_error("Cannot run set_data special operation ", SET_DATA_SPECIAL.keys()[special], " as the value parameter is not numerical.")
			return
	
	match special:
		SET_DATA_SPECIAL.NONE:
			current_dict[keys[keys.size()-1]] = value
			print_debug("Changed ", keys, " in ", FILE_TYPE.keys()[type], " to ", value)
		SET_DATA_SPECIAL.ADD:
			current_dict[keys[keys.size()-1]] += value
			print_debug("Changed ", keys, " in ", FILE_TYPE.keys()[type], " to add ", value, " (",current_dict[keys[keys.size()-1]],")")
		SET_DATA_SPECIAL.SUBTRACT:
			current_dict[keys[keys.size()-1]] -= value
			print_debug("Changed ", keys, " in ", FILE_TYPE.keys()[type], " to subtract ", value, " (",current_dict[keys[keys.size()-1]],")")
		SET_DATA_SPECIAL.MULTIPLY:
			current_dict[keys[keys.size()-1]] *= value
			print_debug("Changed ", keys, " in ", FILE_TYPE.keys()[type], " to multiply ", value, " (",current_dict[keys[keys.size()-1]],")")
		SET_DATA_SPECIAL.DIVIDE:
			current_dict[keys[keys.size()-1]] /= value
			print_debug("Changed ", keys, " in ", FILE_TYPE.keys()[type], " to (float) divide ", value, " (",current_dict[keys[keys.size()-1]],")")
		SET_DATA_SPECIAL.DIVIDE_INT:
			current_dict[keys[keys.size()-1]] = floor(current_dict[keys[keys.size()-1]] / value)
			print_debug("Changed ", keys, " in ", FILE_TYPE.keys()[type], " to (int) divide ", value, " (",current_dict[keys[keys.size()-1]],")")
		SET_DATA_SPECIAL.MODULO:
			current_dict[keys[keys.size()-1]] %= value
			print_debug("Changed ", keys, " in ", FILE_TYPE.keys()[type], " to modulo ", value, " (",current_dict[keys[keys.size()-1]],")")
		SET_DATA_SPECIAL.EXPONENT:
			current_dict[keys[keys.size()-1]] **= value
			print_debug("Changed ", keys, " in ", FILE_TYPE.keys()[type], " to exponent ", value, " (",current_dict[keys[keys.size()-1]],")")
		SET_DATA_SPECIAL.ROOT:
			current_dict[keys[keys.size()-1]] **= (1.0/value)
			print_debug("Changed ", keys, " in ", FILE_TYPE.keys()[type], " to root ", value, " (",current_dict[keys[keys.size()-1]],")")
		
	_save_file(type)
	
func get_data(type: FILE_TYPE, keys: Array[Variant]) -> Variant:
	var current_dict: Dictionary = [settings_data,save_data,default_settings_data,default_save_data][type]
	var key: Variant
	for i in keys.size()-1:
		key = keys[i]
		if not current_dict.has(key):
			push_error("Failed to get data as key ", key, " is not present in ", FILE_TYPE.keys()[type], keys)
			return
		if current_dict[key] is not Dictionary:
			break
		current_dict = current_dict[key]
	return current_dict[keys[keys.size()-1]]


## Runs after loading settings and save data to migrate any old keys to new ones safely while maintaining values.[br]
## Currently only supports editing second keys.
func _migrate_data(type: FILE_TYPE) -> void:
	var temp_value: Variant
	# Create reference variables to the dictionaries to be able to reuse the same code for both
	var current_data: Dictionary = [settings_data,save_data][type]
	var migrate_data: Dictionary = [settings_data_to_migrate,save_data_to_migrate][type]
		
	for first_key in migrate_data: # Loop the first-level keys (groups)
		if first_key in current_data:
			for second_key in migrate_data[first_key]: # Loop the second-level keys (the keys with the actual values, a.k.a. the settings or save data)
				if second_key in current_data[first_key]:
					temp_value = current_data[first_key][second_key] # Saves the value
					current_data[first_key].erase(second_key) # Delete the old key
					current_data[first_key][migrate_data[first_key][second_key]] = temp_value # Set the value on the new key. Done!

func _add_missing_data(type: FILE_TYPE) -> void:
	# Create reference variables to the dictionaries to be able to reuse the same code for both
	var current_data: Dictionary = [settings_data,save_data][type]
	var default_data: Dictionary = [default_settings_data,default_save_data][type]

	for first_key in default_data:
		if first_key not in current_data:
			current_data[first_key] = {}
		if first_key in current_data:
			for second_key in default_data[first_key]:
				if second_key not in current_data[first_key]:
					current_data[first_key][second_key] = default_data[first_key][second_key]

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
		
