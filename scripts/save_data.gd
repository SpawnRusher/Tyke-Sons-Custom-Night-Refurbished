extends Node

const FILE_PATH: String = "user://TS_Refurbished.ini"
var config_file
var error_check

func _ready() -> void:
	config_file = ConfigFile.new() # Creates new ConfigFile node
	error_check = config_file.load(FILE_PATH) # Sets a variable to the error output
	
	if error_check == 7: # 7 = No file exists!
		config_file.save(FILE_PATH) # Creates file
		error_check = config_file.load(FILE_PATH) # Sets error output again
		
	if error_check != OK: # Error occurs
		print("An error occurred when loading save data: ", error_check)
		
	else: # Success!
		update_settings()

func change_data(group: String, setting: String, value, default):
	if value == "toggle":
		config_file.set_value(group,setting,!(config_file.get_value(group,setting,default)))
	else:
		config_file.set_value(group,setting,value)
	config_file.save(FILE_PATH)
	update_settings()
	
func update_settings():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if config_file.get_value("settings","fullscreen",false) == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
