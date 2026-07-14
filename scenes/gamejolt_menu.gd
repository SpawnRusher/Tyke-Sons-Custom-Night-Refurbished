extends Control

const QUIETBUTTONPRESS: AudioStream = preload("uid://dubq1cwtm73fs")
const LOUD_BUTTON_PRESS: AudioStream = preload("uid://dljncvmipnl1d")

const TROPHY = preload("uid://cc30spbhiddw")

const trophy_images: Dictionary[String,Resource] = {
	"Bronze":preload("uid://0v0x60882ttn"),
	"Silver":preload("uid://droo2c354fvl7"),
	"Gold":preload("uid://7y46si1whh3m"),
	"Platinum":preload("uid://2rmo5irqvj2j") }
	
const trophy_images_secret: Dictionary[String,Resource] = {
	"Bronze":preload("uid://crbob87uk318t"),
	"Silver":preload("uid://ja2bpxd358ci"),
	"Gold":preload("uid://dssvh1553nhoh"),
	"Platinum":preload("uid://bl4gonb7wgn4") }

@export var username_line_edit: LineEdit
@export var user_token_line_edit: LineEdit
@export var login_info: RichTextLabel

@export var trophies_vbox: VBoxContainer

signal toggle_button(button: Button, group_name: String, setting_name: String, setting_label: String, state_label: RichTextLabel)

func _ready() -> void:
	GameJolt.users_auth_completed.connect(_users_auth_completed)
	GameJolt.trophies_fetch_completed.connect(_trophies_fetch_completed)
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
		GameJolt.api_request("trophies","fetch",{"username":GameJolt.authorized_username,"user_token":GameJolt.authorized_user_token})

func _trophies_fetch_completed(response: Dictionary, parameters: Dictionary) -> void:
	for trophy in response["trophies"]:
		var new_trophy:= TROPHY.instantiate()
		trophies_vbox.add_child(new_trophy)
		var image = new_trophy.find_child("Icon",true)
		var text = new_trophy.find_child("Text",true)
		var border_box = StyleBoxFlat.new()
		border_box = new_trophy.get_theme_stylebox("panel").duplicate()
		if trophy["achieved"] == "false":
			border_box.border_color = Color(1.0, 0.0, 0.0, 1.0)
			new_trophy.add_theme_stylebox_override("panel",border_box)
		else:
			border_box.border_color = Color(0.0, 1.0, 0.0, 1.0)
			new_trophy.add_theme_stylebox_override("panel",border_box)
		if "https://s.gjcdn.net/img/trophy-" not in trophy["image_url"]:
			var http = HTTPRequest.new()
			add_child(http)
			http.request_completed.connect(_trophy_icon_request_completed.bind(http,image,trophy["image_url"].right(3)))
			http.request(trophy["image_url"])
			continue
			
		if "secret" not in trophy["image_url"]:
			image.texture = trophy_images[trophy["difficulty"]]
		else:
			image.texture = trophy_images_secret[trophy["difficulty"]]
			trophy["description"] = "[i][color=gray]Description hidden. Achieve this trophy to read it![/color][/i]"
		
		text.text = "[font_size=40][b]" + trophy["title"] + "[/b][/font_size][br][font_size=20]" + trophy["description"] + "[/font_size]"
		
func _trophy_icon_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest, texture_rect: TextureRect, image_type: String) -> void:
	var trophy_image = Image.new()
	if image_type == "jpg":
		trophy_image.load_jpg_from_buffer(body)
	else:
		trophy_image.load_png_from_buffer(body)
	texture_rect.texture = ImageTexture.create_from_image(trophy_image)
	http.queue_free()

func _on_tab_changed(tab: int) -> void:
	add_child(SpecialFunctions.create_audio(LOUD_BUTTON_PRESS))
