extends Node

const api_link: String = "https://api.gamejolt.com/api/game/v1_2/"
const users_auth_link: String = "users/auth/"
const users_fetch_link: String = "users/fetch/"
	

var authorized_username: String = ""
var authorized_user_token: String = ""

var game_id: int = 1077734
var game_key: String = "11de50d5fd3622d9f81394e176a81bbf"

var current_request: String = ""

#region SIGNALS
signal request_auth(username: String, user_token: String)
signal users_auth_completed(result: bool, username: String, user_token: String)
#endregion

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_G:
			_users_auth("SpawnRusher","LP2dZ1")

func _ready() -> void:
	request_auth.connect(_users_auth)

func _append_game_id() -> String:
	return "?game_id="+str(game_id)

func _http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print_debug("RESULT: " + str(result) + " | RESPONSE_CODE: " + str(response_code))
	print_debug(headers)
	print_debug(body)
	
func _users_auth(username: String, user_token: String) -> void:
	print("Attempting to auth")
	var http = HTTPRequest.new()
	add_child(http)
	var http_link = api_link + "users/auth/" + _append_game_id() + "&username="+username+"&user_token="+user_token
	http_link += ("&signature="+_create_signature(http_link))
	print("Auth link: " + http_link)
	http.request(http_link)
	http.request_completed.connect(_users_auth_request_completed.bind(username, user_token))
	
func _users_auth_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, username: String, user_token: String) -> void:
	print("RESULT: " + str(result) + " | RESPONSE_CODE: " + str(response_code))
	print("RAW HEADERS: ", headers)
	print("RAW BODY: ", body)
	var text_body = body.get_string_from_utf8()
	print("TEXT BODY: " + text_body)
	var json_body = JSON.parse_string(text_body)
	print("JSON BODY: ", json_body)
	users_auth_completed.emit(json_body["response"]["success"],username,user_token)
	if json_body["response"]["success"] == "true":
		authorized_username = username
		authorized_user_token = user_token
	
func _create_signature(link: String, post:= false) -> String:
	if post == false:
		return (link+game_key).sha1_text()
	else:
		return "not done yet"
