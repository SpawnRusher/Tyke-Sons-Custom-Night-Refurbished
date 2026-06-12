extends Node

	
func _input(event) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_F11 and event.is_pressed():
			SaveData.change_data("settings","fullscreen","toggle",false)

func _update_settings() -> void:
	if SaveData.save_data["fullscreen"] == false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
	if SaveData.save_data["antialiasing"] == false:
		pass
