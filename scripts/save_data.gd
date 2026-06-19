extends Node

const FILE_PATH: String = "user://TS_Refurbished.ini"
var config_file
var error_check

var default_values: Dictionary[String,float] = {
	"master_volume":50,
	"jumpscare_volume":50,
	"fullscreen_mode":0,
	"vsync_mode":0,
	"msaa_quality":0,
	"max_fps":max(DisplayServer.screen_get_refresh_rate(),60)

	}

var default_keybinds: Dictionary[String,Key] = {
	"return_to_menu":KEY_F2,
	"restart_night":KEY_R
	}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	config_file = ConfigFile.new() # Creates new ConfigFile node
	error_check = config_file.load(FILE_PATH) # Sets a variable to the error output
	
	if error_check == 7: # 7 = No file exists
		config_file.save(FILE_PATH) # Creates file
		error_check = config_file.load(FILE_PATH) # Sets error output again
		
	if error_check != OK:
		print("An error occurred when loading save data: ", error_check)
		
	else: # Success!
		SignalBus.save_data_loaded.emit()
		_update_settings()

func change_data(group: String, setting: String, value, default):
	if value is String and value == "toggle":
		config_file.set_value(group,setting,!(config_file.get_value(group,setting,default)))
	else:
		config_file.set_value(group,setting,value)
	config_file.save(FILE_PATH)
	print("Data changed: ",group,"|",setting,"|",value,"|",default)
	_update_settings()
	
func _update_settings():
	AudioServer.set_bus_volume_linear(0,(config_file.get_value("settings","master_volume",default_values["master_volume"])/100.0))
	AudioServer.set_bus_volume_linear(1,(config_file.get_value("settings","jumpscare_volume",default_values["jumpscare_volume"])/100.0))
	
	Engine.max_fps = config_file.get_value("settings","max_fps",default_values["max_fps"])
	DisplayServer.window_set_mode(config_file.get_value("settings","fullscreen_mode",default_values["fullscreen_mode"]))
	DisplayServer.window_set_vsync_mode(config_file.get_value("settings","vsync_mode",default_values["vsync_mode"]))
	RenderingServer.viewport_set_msaa_2d(get_viewport().get_viewport_rid(),config_file.get_value("settings","msaa_quality",default_values["msaa_quality"]))
	
