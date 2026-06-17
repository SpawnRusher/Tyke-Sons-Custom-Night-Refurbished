extends Node2D

@onready var text: RichTextLabel = $Text

var version_type: String

func _ready() -> void:
	SignalBus.pastebin_version_check.connect(_pastebin_version_check)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if version_type != "disabled":
			if event.keycode == KEY_SPACE:
				get_tree().change_scene_to_file("res://scenes/menu.tscn")
		if event.keycode == KEY_G:
			OS.shell_open("https://gamejolt.com/games/tscn_refurbished/1077734")
	
	
func _pastebin_version_check(vt,pb_v) -> void:
	version_type = vt
	if version_type == "dev":
		text.text = "This version of the game (" +ProjectSettings.get_setting("application/config/version") + ") is newer than the current public release.\r\nThis could mean that this is either a build in-development, or I forgot to update the Pastebin.\r\n\r\nPress 'Space' to continue to the menu."
	elif version_type == "disabled":
		text.text = "This version of the game (" +ProjectSettings.get_setting("application/config/version") + ") has been disabled.\r\nVersions of the game are only disabled if there is something catastrophic.\r\n\r\nPress G to open GameJolt to update the game to the latest version (" + pb_v + ") to play.\r\n Alternatively, play on an older version if you please."
	elif version_type == "outdated":
		text.text = "This version of the game (" +ProjectSettings.get_setting("application/config/version") + ") is outdated.\r\nPress 'G' to open GameJolt to download the latest version (" + pb_v + ").\r\nPress space to continue playing on this version."
	elif version_type == "current":
		text.text = "This version of the game (" +ProjectSettings.get_setting("application/config/version") + ") is the current, most up-to-date version!\r\nPress 'Space' to continue to the menu."
