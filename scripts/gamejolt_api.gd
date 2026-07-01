extends Node

const api_link: String = "https://api.gamejolt.com/api/game/v1_2/"
const game_id: int = 1077734
const game_key: String = "11de50d5fd3622d9f81394e176a81bbf"

var authorized_username: String = ""
var authorized_user_token: String = ""

enum SESSION_STATUSES {NONE=-1,IDLE=0,ACTIVE=1}

#region SIGNALS
#region INCOMING_REQUESTS
signal request_users_auth(username: String, user_token: String)
signal request_users_fetch(user: Variant)
signal request_sessions_open(username: String, user_token: String)
signal request_sessions_ping(username: String, user_token: String, status: SESSION_STATUSES)
signal request_sessions_check(username: String, user_token: String)
signal request_sessions_close(username: String, user_token: String)
signal request_scores_fetch(limit: int, table_id: int, username: String, user_token: String, guest: String, better_than: int, worse_than: int)
#endregion
#region OUTGOING_COMPLETIONS
signal users_auth_completed(result: bool, username: String, user_token: String)
signal users_fetch_completed(json_body: Dictionary, user: Variant)
signal sessions_open_completed(json_body: Dictionary, username: String, user_token: String)
signal sessions_ping_completed(json_body: Dictionary, username: String, user_token: String, status: SESSION_STATUSES)
signal sessions_check_completed(json_body: Dictionary, username: String, user_token: String)
signal sessions_close_completed(json_body: Dictionary, username: String, user_token: String)
signal scores_fetch_completed(json_body: Dictionary, username: String, user_token: String)
#endregion
#endregion

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		#if event.keycode == KEY_G:
			#_users_auth("SpawnRusher","LP2dZ1")
		#if event.keycode == KEY_S:
			#_scores_fetch()
		pass
		
func _ready() -> void:
	request_users_auth.connect(_users_auth)
	request_users_fetch.connect(_users_fetch)
	
	request_sessions_open.connect(_sessions_open)
	request_sessions_ping.connect(_sessions_ping)
	request_sessions_check.connect(_sessions_check)
	request_sessions_close.connect(_sessions_close)

	request_scores_fetch.connect(_scores_fetch)
	
# This function exists instead of just adding it in every API call so that the game_id can be changed easily through one place.
func _append_game_id() -> String:
	return "?game_id="+str(game_id)

#region USERS/
func _users_auth(username: String, user_token: String) -> void:
	print("Attempting to auth")
	var http = HTTPRequest.new()
	add_child(http)
	var http_link = api_link + "users/auth/" + _append_game_id() + "&username=" + username + "&user_token=" + user_token
	http_link += ("&signature="+_create_signature(http_link))
	print("Auth link: " + http_link)
	http.request(http_link)
	http.request_completed.connect(_users_auth_request_completed.bind(username, user_token))

func _users_fetch(user: Variant) -> void:
	if user is not String and user is not int:
		push_error("Parameter 'user' in _users_fetch must be either a string (username) or an int (user_id).")
		return
	print("Attempting to fetch")
	var http = HTTPRequest.new()
	add_child(http)
	var http_link = api_link + "users/fetch/" + _append_game_id()
	if user is String: http_link += "&username="+user
	if user is int: http_link += "&user_id="+user
	http_link += ("&signature="+_create_signature(http_link))
	print("Fetch link: " + http_link)
	http.request(http_link)
	http.request_completed.connect(_users_fetch_request_completed.bind(user))

func _users_auth_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, username: String, user_token: String) -> void:
	print("RESULT: " + str(result) + " | RESPONSE_CODE: " + str(response_code))
	var json_body = JSON.parse_string(body.get_string_from_utf8())
	print("JSON BODY: ", json_body)
	users_auth_completed.emit(json_body["response"]["success"],username,user_token)
	if json_body["response"]["success"] == "true":
		authorized_username = username
		authorized_user_token = user_token

func _users_fetch_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, user: Variant) -> void:
	print("RESULT: " + str(result) + " | RESPONSE_CODE: " + str(response_code))
	var json_body = JSON.parse_string(body.get_string_from_utf8())
	print("JSON BODY: ", json_body)
	users_fetch_completed.emit(json_body["response"]["success"],user)
#endregion

#region SESSIONS/
func _sessions_open(username:= authorized_username, user_token:= authorized_user_token) -> void:
	print("sessions/open/")
	var http = HTTPRequest.new()
	add_child(http)
	var http_link = api_link + "sessions/open/" + _append_game_id() + "&username=" + username + "&user_token=" + user_token
	http_link += ("&signature="+_create_signature(http_link))
	print("sessions/open/ link: " + http_link)
	http.request(http_link)
	http.request_completed.connect(_sessions_open_completed.bind(username, user_token))
	
func _sessions_ping(username:= authorized_username, user_token:= authorized_user_token, status:= SESSION_STATUSES.NONE) -> void:
	var http = HTTPRequest.new()
	add_child(http)
	var http_link = api_link + "sessions/ping/" + _append_game_id() + "&username=" + username + "&user_token=" + user_token
	if status != SESSION_STATUSES.NONE: http_link += "&status=" + ["idle","active"][status]
	http_link += ("&signature="+_create_signature(http_link))
	http.request(http_link)
	http.request_completed.connect(_sessions_ping_completed.bind(username, user_token, status))
	
func _sessions_check(username:= authorized_username, user_token:= authorized_user_token) -> void:
	var http = HTTPRequest.new()
	add_child(http)
	var http_link = api_link + "sessions/ping/" + _append_game_id() + "&username=" + username + "&user_token=" + user_token
	http_link += ("&signature="+_create_signature(http_link))
	http.request(http_link)
	http.request_completed.connect(_sessions_check_completed.bind(username, user_token))

func _sessions_close(username:= authorized_username, user_token:= authorized_user_token) -> void:
	var http = HTTPRequest.new()
	add_child(http)
	var http_link = api_link + "sessions/close/" + _append_game_id() + "&username=" + username + "&user_token=" + user_token
	http_link += ("&signature="+_create_signature(http_link))
	http.request(http_link)
	http.request_completed.connect(_sessions_close_completed.bind(username, user_token))

func _sessions_open_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, username: String, user_token: String) -> void:
	print("RESULT: " + str(result) + " | RESPONSE_CODE: " + str(response_code))
	var json_body = JSON.parse_string(body.get_string_from_utf8())
	print("JSON BODY: ", json_body)
	sessions_open_completed.emit(json_body, username, user_token)

func _sessions_ping_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, username: String, user_token: String, status: SESSION_STATUSES) -> void:
	print("RESULT: " + str(result) + " | RESPONSE_CODE: " + str(response_code))
	var json_body = JSON.parse_string(body.get_string_from_utf8())
	print("JSON BODY: ", json_body)
	sessions_ping_completed.emit(json_body, username, user_token, status)

func _sessions_check_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, username: String, user_token: String) -> void:
	print("RESULT: " + str(result) + " | RESPONSE_CODE: " + str(response_code))
	var json_body = JSON.parse_string(body.get_string_from_utf8())
	print("JSON BODY: ", json_body)
	sessions_check_completed.emit(json_body, username, user_token)

func _sessions_close_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, username: String, user_token: String) -> void:
	print("RESULT: " + str(result) + " | RESPONSE_CODE: " + str(response_code))
	var json_body = JSON.parse_string(body.get_string_from_utf8())
	print("JSON BODY: ", json_body)
	sessions_close_completed.emit(json_body, username, user_token)

#endregion

#region SCORES/
func _scores_fetch(limit:= 10, table_id:= 0, username:= "", user_token:= "", guest:= "", better_than:= 0, worse_than:= 0) -> void:
	var http = HTTPRequest.new()
	add_child(http)
	var http_link = api_link + "scores/fetch/" + _append_game_id() + "&limit=" + str(limit)
	if table_id != 0: http_link += "&table_id=" + str(table_id)
	if username != "": http_link += "&username=" + username
	if user_token != "": http_link += "&user_token=" + user_token
	if guest != "": http_link += "&guest=" + guest
	if better_than != 0: http_link += "&better_than=" + str(better_than)
	if worse_than != 0: http_link += "&worse_than=" + str(worse_than)
	http_link += ("&signature="+_create_signature(http_link))
	http.request(http_link)
	http.request_completed.connect(_scores_fetch_completed.bind())
	
func _scores_fetch_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("RESULT: " + str(result) + " | RESPONSE_CODE: " + str(response_code))
	var json_body = JSON.parse_string(body.get_string_from_utf8())
	print("JSON BODY: ", json_body)
	scores_fetch_completed.emit(json_body)

#endregion

func _create_signature(link: String) -> String:
	return (link+game_key).sha1_text()
