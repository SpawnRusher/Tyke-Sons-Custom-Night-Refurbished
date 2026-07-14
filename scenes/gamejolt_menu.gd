extends Control

const QUIETBUTTONPRESS: AudioStream = preload("uid://dubq1cwtm73fs")
const LOUD_BUTTON_PRESS: AudioStream = preload("uid://dljncvmipnl1d")

const TROPHY = preload("uid://cc30spbhiddw")
const SCOREBOARD = preload("uid://c2vxi6alnd0xa")
const SCOREBOARD_SCORE = preload("uid://cnjso7820f2hb")



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

@export var tab_container: TabContainer
@export var trophies_vbox: VBoxContainer

@export var scoreboards_hbox: HBoxContainer



var trophies_loaded: bool
var scoreboards_loaded: bool

signal toggle_button(button: Button, group_name: String, setting_name: String, setting_label: String, state_label: RichTextLabel)

func _ready() -> void:
	GameJolt.users_auth_completed.connect(_users_auth_completed)
	GameJolt.users_fetch_completed.connect(_users_fetch_completed)
	GameJolt.trophies_fetch_completed.connect(_trophies_fetch_completed)
	GameJolt.scores_tables_completed.connect(_scores_tables_completed)
	GameJolt.scores_fetch_completed.connect(_scores_fetch_completed)
	toggle_button.connect(_toggle_button)
	if GameJolt.authorized_username != "":
		_users_auth_completed({"success":"true"},{"username":GameJolt.authorized_username,"user_token":GameJolt.authorized_user_token},{})

func _on_return_to_menu_button_pressed() -> void:
	SceneManager.change_to_scene("res://scenes/menu.tscn")

func _toggle_button(button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, state_label: RichTextLabel) -> void:
	SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,button.button_pressed,group_name,setting_name)
	state_label.text = ["OFF","ON"][button.button_pressed as int]
	add_child(SpecialFunctions.create_audio(QUIETBUTTONPRESS))

func _on_login_button_pressed() -> void:
	GameJolt.api_request("users","auth",{"username":username_line_edit.text,"user_token":user_token_line_edit.text})

func _users_auth_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary) -> void:
	if response["success"] == "false":
		login_info.text = "Failed to log in with GameJolt. Double check Username and User Token."
		SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,"","gamejolt","username")
		SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,"","gamejolt","user_token")
	else:
		login_info.text = "Logged in successfully as " + GameJolt.authorized_username + "!"
		SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,parameters["username"],"gamejolt","username")
		SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,parameters["user_token"],"gamejolt","user_token")
		tab_container.set("tab_1/disabled",false)
		tab_container.set("tab_2/disabled",false)
		
func _users_fetch_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary) -> void:
	if extra_info["avatar"]:
		var http = HTTPRequest.new()
		add_child(http)
		http.request_completed.connect(_avatar_url_request_completed.bind(http,extra_info["avatar"],response["users"][0]["avatar_url"].right(3)))
		http.request(response["users"][0]["avatar_url"])

func _trophies_fetch_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary) -> void:
	for trophy in response["trophies"]:
		var new_trophy:= TROPHY.instantiate()
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
		
		elif "secret" not in trophy["image_url"]:
			image.texture = trophy_images[trophy["difficulty"]]
		else:
			image.texture = trophy_images_secret[trophy["difficulty"]]
			trophy["description"] = "[i][color=gray]Description hidden. Achieve this trophy to read it![/color][/i]"
		
		text.text = "[font_size=32][b]" + trophy["title"] + "[/b][/font_size][br][font_size=16]" + trophy["description"] + "[/font_size]"
		trophies_vbox.add_child(new_trophy)
		
func _trophy_icon_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest, texture_rect: TextureRect, image_type: String) -> void:
	var trophy_image = Image.new()
	if image_type == "jpg":
		trophy_image.load_jpg_from_buffer(body)
	else:
		trophy_image.load_png_from_buffer(body)
	texture_rect.texture = ImageTexture.create_from_image(trophy_image)
	http.queue_free()
	
func _scores_tables_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary) -> void:
	for table in response["tables"]:
		var scoreboard = SCOREBOARD.instantiate()
		var scoreboard_name = scoreboard.find_child("Name")
		scoreboard.name = table["name"]
		scoreboard_name.text = "[font_size=32]" + table["name"] + "[/font_size]"
		if table["description"]:
			scoreboard_name.text = scoreboard_name.text + "[br][font_size=16]" + table["description"] + "[/font_size]"
		scoreboards_hbox.add_child(scoreboard)
		GameJolt.api_request("scores","fetch",{"limit":"100","table_id":table["id"]},{"scoreboard":scoreboard})
		
func _scores_fetch_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary) -> void:
	for score in response["scores"]:
		var scoreboard_score = SCOREBOARD_SCORE.instantiate()
		var border_box = StyleBoxFlat.new()
		border_box = scoreboard_score.get_theme_stylebox("panel").duplicate()
		if score["user"] == GameJolt.authorized_username:
			border_box.border_color = Color(0.0, 1.0, 0.0, 1.0)
			scoreboard_score.add_theme_stylebox_override("panel",border_box)
		var avatar = scoreboard_score.find_child("Avatar")
		var text = scoreboard_score.find_child("Text")
		var username
		if score["user"]:
			username = score["user"]
		else:
			username = score["guest"]
		text.text = "[font_size=24]" + str(response["scores"].find(score)+1) + ". " + username + "[/font_size][br][font_size=16]" + score["score"] + "[/font_size]"
		
		extra_info["scoreboard"].find_child("VBoxContainer").add_child(scoreboard_score)
		
		GameJolt.api_request("users","fetch",{"user_id":score["user_id"]},{"avatar":avatar})

func _avatar_url_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest, avatar: TextureRect, image_type: String) -> void:
	var avatar_image = Image.new()
	if image_type == "jpg":
		avatar_image.load_jpg_from_buffer(body)
	else:
		avatar_image.load_png_from_buffer(body)
	avatar.texture = ImageTexture.create_from_image(avatar_image)
	http.queue_free()

func _on_tab_changed(tab: int) -> void:
	add_child.call_deferred(SpecialFunctions.create_audio(LOUD_BUTTON_PRESS))
	if tab_container.get_tab_title(tab) == "Trophies" and not trophies_loaded:
		trophies_loaded = true
		GameJolt.api_request("trophies","fetch",{"username":GameJolt.authorized_username,"user_token":GameJolt.authorized_user_token})
	elif tab_container.get_tab_title(tab) == "Scoreboards" and not scoreboards_loaded:
		scoreboards_loaded = true
		GameJolt.api_request("scores","tables")
