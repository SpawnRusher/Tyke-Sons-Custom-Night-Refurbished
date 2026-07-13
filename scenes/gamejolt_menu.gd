extends Control

const QUIETBUTTONPRESS: AudioStream = preload("uid://dubq1cwtm73fs")
const LOUD_BUTTON_PRESS: AudioStream = preload("uid://dljncvmipnl1d")

@export var username_line_edit: LineEdit
@export var user_token_line_edit: LineEdit
@export var login_info: RichTextLabel

signal toggle_button(button: Button, group_name: String, setting_name: String, setting_label: String, state_label: RichTextLabel)

func _ready() -> void:
	GameJolt.users_auth_completed.connect(_users_auth_completed)
	toggle_button.connect(_toggle_button)
	if GameJolt.authorized_username != "":
		_users_auth_completed({"success":"true"},{"username":GameJolt.authorized_username,"user_token":GameJolt.authorized_user_token})

func _on_return_to_menu_button_pressed() -> void:
	SceneManager.change_to_scene("res://scenes/menu.tscn")

func _toggle_button(button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, state_label: RichTextLabel) -> void:
	SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,button.button_pressed,group_name,setting_name)
	state_label.text = ["OFF","ON"][button.button_pressed as int]
	add_child(SpecialFunctions.create_audio(QUIETBUTTONPRESS))

func _on_login_button_pressed() -> void:
	GameJolt.api_request("users","auth",{"username":username_line_edit.text,"user_token":user_token_line_edit.text})

func _users_auth_completed(response: Dictionary, parameters: Dictionary) -> void:
	if response["success"] == "false":
		login_info.text = "Failed to log in with GameJolt. Double check Username and User Token."
		SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,"","gamejolt","username")
		SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,"","gamejolt","user_token")
	else:
		login_info.text = "Logged in successfully as " + GameJolt.authorized_username + "!"
		SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,parameters["username"],"gamejolt","username")
		SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,parameters["user_token"],"gamejolt","user_token")
