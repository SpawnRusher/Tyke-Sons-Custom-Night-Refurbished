extends Node2D

@export var text: RichTextLabel

var version_type: Pastebin.VERSION_TYPE

func _ready() -> void:
	SceneManager.load_scene("res://scenes/menu/menu.tscn")
	SignalBus.pastebin_version_check.connect(_pastebin_version_check)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if version_type != Pastebin.VERSION_TYPE.DISABLED:
			if event.keycode == KEY_SPACE:
				SceneManager.change_to_scene("res://scenes/menu/menu.tscn",SceneManager.CHANGE_SCENE_BEHAVIOR.AWAIT)
		if event.keycode == KEY_G:
			OS.shell_open("https://gamejolt.com/games/tscn_refurbished/1077734")
	
	
func _pastebin_version_check(vt: Pastebin.VERSION_TYPE, pb_v: String) -> void:
	version_type = vt
	if version_type == Pastebin.VERSION_TYPE.DEV:
		text.text = "This version of the game (" + ProjectSettings.get_setting("application/config/version") + ") is newer than the current public release.\r\nThis could mean that this is either a build in-development, or I forgot to update the Pastebin.\r\n\r\nPress 'Space' to continue to the menu."
		SceneManager.load_scene("res://scenes/menu/menu.tscn")
	elif version_type == Pastebin.VERSION_TYPE.DISABLED:
		text.text = "This version of the game (" + ProjectSettings.get_setting("application/config/version") + ") has been disabled.\r\nVersions of the game are only disabled if there is something catastrophic.\r\n\r\nPress G to open GameJolt to update the game to the latest version (" + pb_v + ") to play.\r\n Alternatively, play on an older version if you please."
	elif version_type == Pastebin.VERSION_TYPE.OUTDATED:
		text.text = "This version of the game (" + ProjectSettings.get_setting("application/config/version") + ") is outdated.\r\nPress 'G' to open GameJolt to download the latest version (" + pb_v + ").\r\nPress space to continue playing on this version."
		SceneManager.load_scene("res://scenes/menu/menu.tscn")
	elif version_type == Pastebin.VERSION_TYPE.LATEST:
		text.text = "This version of the game (" + ProjectSettings.get_setting("application/config/version") + ") is the current, most up-to-date version!\r\nPress 'Space' to continue to the menu."
		SceneManager.load_scene("res://scenes/menu/menu.tscn")
