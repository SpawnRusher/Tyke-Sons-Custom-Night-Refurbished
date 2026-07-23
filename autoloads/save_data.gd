extends Node

const file_paths: Array[String] = ["user://tscn_settings.json","user://tscn_save.json"]
enum FILE_TYPE {SETTINGS, SAVE, DEFAULT_SETTINGS, DEFAULT_SAVE}
enum SET_DATA_SPECIAL {NONE,TOGGLE_BOOL,ADD,SUBTRACT,MULTIPLY,DIVIDE,DIVIDE_INT,MODULO,EXPONENT,ROOT}

const DEFAULT_SETTINGS_DATA: Dictionary = {
	"display": {
		"max_fps":60,
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
const MIGRATE_SETTINGS_DATA: Dictionary = {
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
var settings_data: Dictionary = DEFAULT_SETTINGS_DATA
var settings_data_file: FileAccess
signal settings_data_loaded

const DEFAULT_SAVE_DATA: Dictionary = {
	"statistics": {
		"flashlight": {
			"flashlight_battery_drained":0,
			"phantom_chipomat_flashlight_battery_drained":0,
			"flashlight_batteries_picked_up":0,
			"flashlight_total_flashes":0,
		},
		"jumpscares": {
			"CHIPOMAT_1":0,
			"CHIPOMAT_2":0,
			"CHIPOMAT_3":0,
			"FUN_FUNGAL":0,
			"SPRINGCRAB":0,
			"NIGHTMARE_CHIPPER":0,
			"SEABILL":0,
			"FREDBEAR":0,
			"BIDY":0,
			"BUSTER":0,
			"BRUCE":0,
			"CHIPPER":0,
			"TOY":0,
			"PHANTOM_CHIPOMAT":0,
			"HAPPYSHROOM":0,
		},
		"playtime": {
			"general": {
				"total":0,
				"menu":0,
				"gamejolt_menu":0,
				"night":0,
			},
			"presets": {
				"Custom Night":0,
				"Top Row":0,
				"Bottom Row":0,
				"Sleep Insomnia":0,
			},
		},		
	}}
const MIGRATE_SAVE_DATA: Dictionary = {}
var save_data: Dictionary = DEFAULT_SAVE_DATA
var save_data_file: FileAccess
const save_data_encryption_key: String = ""
signal save_data_loaded

func _ready() -> void:
	_load_file(FILE_TYPE.SETTINGS) if _check_for_file(FILE_TYPE.SETTINGS) else _create_file(FILE_TYPE.SETTINGS)
	_load_file(FILE_TYPE.SAVE) if _check_for_file(FILE_TYPE.SAVE) else _create_file(FILE_TYPE.SAVE)

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
	else:
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
		await _add_missing_data(FILE_TYPE.SETTINGS)
		await _migrate_data(FILE_TYPE.SETTINGS)
		_save_file(type)
		settings_data_loaded.emit()
		_update_settings()
		_update_keybinds_actions()
	else:
		save_data_file = FileAccess.open(file_paths[type], FileAccess.READ_WRITE)
		json.parse(save_data_file.get_as_text())
		if json.data:
			save_data = json.data
		_add_missing_data(FILE_TYPE.SAVE)
		_migrate_data(FILE_TYPE.SAVE)
		_save_file(type)
		save_data_loaded.emit()

func _create_file(type: FILE_TYPE) -> void:
	var create_file:= FileAccess.open(file_paths[type], FileAccess.WRITE)
	create_file.store_string("")
	create_file.close()
	_load_file(type)
	
func _update_settings() -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"),(get_data(FILE_TYPE.SETTINGS,["game","master_volume"]))/100.0)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Jumpscare"),(get_data(FILE_TYPE.SETTINGS,["game","jumpscare_volume"]))/100.0)
	
	DisplayServer.window_set_mode(settings_data["display"]["window_mode"])
	DisplayServer.window_set_vsync_mode(settings_data["display"]["vsync_mode"])
	
	Engine.max_fps = settings_data["display"]["max_fps"]
	
	get_tree().root.canvas_item_default_texture_filter = settings_data["display"]["antialiasing"]

func set_data(type: FILE_TYPE, keys: Array[String], value: Variant, special:= SET_DATA_SPECIAL.NONE) -> void:
	var current_dict: Dictionary = [settings_data,save_data][type]
	var key: Variant
	for i in keys.size():
		key = keys[i]
		if not current_dict.has(key):
			keys.pop_back()
			push_error("Failed to set data as key ", key, " is not present in ", FILE_TYPE.keys()[type], keys)
			return
		if current_dict[key] is not Dictionary:
			break
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
	var current_dict: Dictionary = [settings_data,save_data,DEFAULT_SETTINGS_DATA,DEFAULT_SAVE_DATA][type]
	var key: Variant
	
	if keys.size() == 1:
		if not current_dict.has(keys[0]):
			push_error("Failed to get data as key ", keys[0], " is not present in ", FILE_TYPE.keys()[type], keys)
			return
		return current_dict[keys[0]]

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
func _migrate_data(type: FILE_TYPE) -> void:
	# Create reference variables to the dictionaries to be able to reuse the same code for both
	var current_data: Dictionary = [settings_data,save_data][type]
	var migrate_data: Dictionary = [MIGRATE_SETTINGS_DATA,MIGRATE_SAVE_DATA][type]
	
	for first_key in migrate_data:
		if first_key in current_data:
			if first_key in current_data and current_data[first_key] is not Dictionary:
				current_data[migrate_data[first_key]] = current_data[first_key]
				current_data.erase(first_key)
				continue
				
			for second_key in migrate_data[first_key]:
				if second_key in current_data[first_key]:
					if second_key == "MIGRATE_PREVIOUS_KEY":
						current_data[migrate_data[first_key][second_key]] = current_data[first_key]
						current_data.erase(first_key)
						continue
					if second_key in current_data[first_key] and current_data[first_key][second_key] is not Dictionary:
						current_data[first_key][migrate_data[first_key][second_key]] = current_data[first_key][second_key]
						current_data[first_key].erase(second_key)
						
					for third_key in migrate_data[first_key][second_key]:
						if third_key in current_data[first_key][second_key]:
							if third_key == "MIGRATE_PREVIOUS_KEY":
								current_data[migrate_data[first_key][second_key][third_key]] = current_data[first_key][second_key]
								current_data[first_key].erase(second_key)
								continue
							if third_key in current_data[first_key][second_key] and current_data[first_key][second_key][third_key] is not Dictionary:
								current_data[first_key][second_key][migrate_data[first_key][second_key][third_key]] = current_data[first_key][second_key][third_key]
								current_data[first_key][second_key].erase(third_key)
								
							for fourth_key in migrate_data[first_key][second_key][third_key]:
								if fourth_key in current_data[first_key][second_key][third_key]:
									if fourth_key == "MIGRATE_PREVIOUS_KEY":
										current_data[migrate_data[first_key][second_key][third_key][fourth_key]] = current_data[first_key][second_key][third_key]
										current_data[first_key][second_key].erase(third_key)
										continue
									if fourth_key in current_data[first_key][second_key][third_key] and current_data[first_key][second_key][third_key][fourth_key] is not Dictionary:
										current_data[first_key][second_key][third_key][migrate_data[first_key][second_key][third_key][fourth_key]] = current_data[first_key][second_key][third_key][fourth_key]
										current_data[first_key][second_key][third_key].erase(fourth_key)

func _add_missing_data(type: FILE_TYPE) -> void:
	# Create reference variables to the dictionaries to be able to reuse the same code for both
	var current_data: Dictionary = [settings_data,save_data][type]
	var default_data: Dictionary = [DEFAULT_SETTINGS_DATA,DEFAULT_SAVE_DATA][type]


	for first_key in default_data:
		if first_key not in current_data:
			current_data[first_key] = default_data[first_key]
			continue
			
		if default_data[first_key] is Dictionary:
			for second_key in default_data[first_key]:
				if second_key not in current_data[first_key]:
					current_data[first_key][second_key] = default_data[first_key][second_key]
					continue
				
				if default_data[first_key][second_key] is Dictionary:
					for third_key in default_data[first_key][second_key]:
						if third_key not in current_data[first_key][second_key]:
							current_data[first_key][second_key][third_key] = default_data[first_key][second_key][third_key]
							continue
						
						if default_data[first_key][second_key][third_key] is Dictionary:
							for fourth_key in default_data[first_key][second_key][third_key]:
								if fourth_key not in current_data[first_key][second_key][third_key]:
									current_data[first_key][second_key][third_key][fourth_key] = default_data[first_key][second_key][third_key][fourth_key]
									continue

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
		
