extends Node2D

@export var text: RichTextLabel

enum VERSION_TYPE {CURRENT, OUTDATED, DISABLED, DEV}

var version_type: VERSION_TYPE:
	set(value):
		version_type = value
		text.text = messages[version_type] % [ProjectSettings.get_setting("application/config/version"), pastebin_current_version]
var pastebin_current_version: String:
	set(value):
		pastebin_current_version = value
		Global.pastebin_current_version = value
var pastebin_disabled_versions: Array # cant static type since its being parsed in JSON
var patch_notes: Dictionary # cant static type since its being parsed in JSON
const messages: Array[String] = [
	"This version of the game (%s) is the current, most up-to-date version!\r\nPress 'Space' to continue to the menu.\r\n[color=black]%s",
	"This version of the game (%s) is outdated.\r\nPress 'G' to open GameJolt to download the latest version (%s).\r\nPress space to continue playing on this version.",
	"This version of the game (%s) has been disabled.\r\nVersions of the game are only disabled if there is something catastrophic.\r\n\r\nPress G to open GameJolt to update the game to the latest version (%s) to play.\r\n Alternatively, play on an older version if you please.",
	"This version of the game (%s) is newer than the current public release (%s).\r\nThis could mean that this is either a build in-development, or I forgot to update the Pastebin.\r\n\r\nPress 'Space' to continue to the menu."]

const pastebin_link: String = "https://pastebin.com/raw/iRTnzuBH"
		
func _ready() -> void:
	SceneManager.load_scene("res://scenes/menu/menu.tscn")
	var http: HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_http_request_completed.bind(http))
	http.request(pastebin_link)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if version_type != VERSION_TYPE.DISABLED:
			if event.keycode == KEY_SPACE:
				SceneManager.change_to_scene("res://scenes/menu/menu.tscn",SceneManager.CHANGE_SCENE_BEHAVIOR.AWAIT)
		if event.keycode == KEY_G:
			OS.shell_open("https://gamejolt.com/games/tscn_refurbished/1077734")
	
func _http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void:
	_get_data_from_pastebin(JSON.parse_string(body.get_string_from_utf8()))
	http.queue_free()

func _get_data_from_pastebin(paste: Dictionary) -> void:
	for key in paste:
		match key:
			"current_version":
				pastebin_current_version = paste[key]
			"disabled_versions":
				pastebin_disabled_versions = paste[key]
			"patch_notes":
				patch_notes = paste[key]
	_compare_version()
	
func _compare_version() -> void:
	if pastebin_current_version == ProjectSettings.get_setting("application/config/version"):
		version_type = VERSION_TYPE.CURRENT
		return
	for version in pastebin_disabled_versions:
		if version == ProjectSettings.get_setting("application/config/version"):
			version_type = VERSION_TYPE.DISABLED
			return
	if _convert_version_to_int(ProjectSettings.get_setting("application/config/version")) < _convert_version_to_int(pastebin_current_version):
		version_type = VERSION_TYPE.OUTDATED
		return
	version_type = VERSION_TYPE.DEV
	
func _convert_version_to_int(version: String) -> int: # Used for checking if version is outdated or newer than the pastebin version
	version = version.right(version.length()-1) # eliminates the "v" infront of the version number
	var version_string_before_int: String = ""
	for string in version.split("."):
		version_string_before_int += string
	return int(version_string_before_int)
	
