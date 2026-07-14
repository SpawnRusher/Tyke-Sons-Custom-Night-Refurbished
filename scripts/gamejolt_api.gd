@icon("res://sprites/gamejolt/gamejolt_icon.svg")
extends Node 

var fix_string_bools: bool = false
var auto_login: bool = true

#var game_id: int = 1077734
#var private_key: String = "3a582ce926142adf8e355dbeebfcee6e"

var game_id: int = 819351
var private_key: String = "c7be032df3d1da0db5125d214793f44c"

var authorized_username: String
var authorized_user_token: String

#region API URLs
const api_url: String = "https://api.gamejolt.com/api/game/v1_2/"
var url_endpoints: Dictionary[String,Dictionary] = {
	"users": {
		"auth": api_url + "users/auth/?game_id=" + str(game_id),
		"fetch": api_url + "users/?game_id=" + str(game_id)
	},
	"sessions": {
		"open": api_url + "sessions/open/?game_id=" + str(game_id),
		"ping": api_url + "sessions/ping/?game_id=" + str(game_id),
		"check": api_url + "sessions/check/?game_id=" + str(game_id),
		"close": api_url + "sessions/close/?game_id=" + str(game_id)
	},
	"scores": {
		"fetch": api_url + "scores/fetch/?game_id=" + str(game_id),
		"tables": api_url + "scores/tables/?game_id=" + str(game_id),
		"add": api_url + "scores/add/?game_id=" + str(game_id),
		"get_rank": api_url + "scores/get-rank/?game_id=" + str(game_id)
	},
	"trophies": {
		"fetch": api_url + "trophies/fetch/?game_id=" + str(game_id),
		"add_achieved": api_url + "trophies/add_achieved/?game_id=" + str(game_id),
		"remove_achieved": api_url + "trophies/remove_achieved/?game_id=" + str(game_id)
	},
	"data-store": {
		"set": api_url + "data-store/set/?game_id=" + str(game_id),
		"update": api_url + "data-store/update/?game_id=" + str(game_id),
		"remove": api_url + "data-store/remove/?game_id=" + str(game_id),
		"fetch": api_url + "data-store/fetch/?game_id=" + str(game_id),
		"get_keys": api_url + "data-store/get-keys/?game_id=" + str(game_id),
	},
	"friends" : {
		"friends": api_url + "friends/?game_id=" + str(game_id)
	},
	"time" : {
		"time": api_url + "time/?game_id=" + str(game_id)
	}}
#endregion

#region SIGNALS
var signals: Dictionary = {
	"users": {
		"auth": users_auth_completed,
		"fetch": users_fetch_completed
	},
	"sessions": {
		"open": sessions_open_completed,
		"ping": sessions_ping_completed,
		"check": sessions_check_completed,
		"close": sessions_close_completed
	},
	"scores": {
		"fetch": scores_fetch_completed,
		"tables": scores_tables_completed,
		"add": scores_add_completed,
		"get_rank": scores_get_rank_completed
	},
	"trophies": {
		"fetch": trophies_fetch_completed,
		"add_achieved": trophies_add_achieved_completed,
		"remove_achieved": trophies_remove_achieved_completed
	},
	"data-store": {
		"set": data_storage_set_completed,
		"update": data_storage_update_completed,
		"remove": data_storage_remove_completed,
		"fetch": data_storage_fetch_completed,
		"get_keys": data_storage_get_keys_completed,
	},
	"friends" : {
		"friends": friends_friends_completed
	},
	"time" : {
		"time": time_time_completed
	}}
signal users_auth_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal users_fetch_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal sessions_open_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal sessions_ping_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal sessions_check_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal sessions_close_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal scores_fetch_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal scores_tables_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal scores_add_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal scores_get_rank_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal trophies_fetch_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal trophies_add_achieved_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal trophies_remove_achieved_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal data_storage_set_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal data_storage_update_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal data_storage_remove_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal data_storage_fetch_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal data_storage_get_keys_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal friends_friends_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
signal time_time_completed(response: Dictionary, parameters: Dictionary, extra_info: Dictionary)
#endregion

func _ready() -> void:
	users_auth_completed.connect(_users_auth_completed)
	if auto_login:
		if SaveData.settings_data["gamejolt"]["username"] != "" and SaveData.settings_data["gamejolt"]["user_token"] != "":
			api_request("users","auth",{"username":SaveData.settings_data["gamejolt"]["username"],"user_token":SaveData.settings_data["gamejolt"]["user_token"]})

## Automatically converts the URL given into its signature and returns it along with the URL signature identifier for easy use.[br][br]Syntax: [code]url += _add_signature(url)[/code]
func _add_signature(url: String) -> String:
	url += private_key
	url = url.sha1_text()
	return "&signature="+url

## Simplifies the response PackedByteArray:[br][br]1. It converts it to a string before parsing it with JSON into a dictionary [br]2. It converts all string-bools into true bools (if fix_string_bools == true)[br]3. It moves all keys nested in the "response" key up one level in the dictionary for easier access and less redundancy (so you don't have to add ["response"] in every reference) [br][br]Basically this function exists to convert all finished HTTP requests into useful dictionaries.
func _simplify_response(response: PackedByteArray) -> Dictionary:
	var dict: Dictionary = JSON.parse_string(response.get_string_from_utf8())
	
	for item in dict["response"]:
		if fix_string_bools:
			if dict["response"][item] is String:
				if dict["response"][item] == "false":
					dict["response"][item] = false
				elif dict["response"][item] == "true":
					dict["response"][item] = true
			
		dict[item] = dict["response"][item]
		
	dict.erase("response")
	return dict

##All hyphens '-' are replaced with underscores '_'[br]
##[br][param extra_info]: Used to transfer data through api_request to request_completed calls, not used for GameJolt, but necessary
func api_request(group: String, type: String, parameters:={}, extra_info:={}) -> void:
	var url = url_endpoints[group][type]
	for parameter in parameters:
		if parameter == "user_id" and parameters[parameter] is Array:
			url += "&user_id="
			for id in parameters[parameter]:
				url += id
				if id != parameters[parameter][parameters[parameter].size()-1]:
					url += ","
			continue

		url += "&" + parameter + "=" + parameters[parameter]
		
	url += _add_signature(url)
	print_debug("request URL: " + url)
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(api_request_completed.bind(http,group,type,parameters,extra_info))
	http.request(url)

func api_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest, group: String, type: String, parameters: Dictionary, extra_info: Dictionary) -> void:
	http.queue_free()
	print_debug("API request completed. Result: " + str(result) + ", response_code: " + str(response_code))
	signals[group][type].emit(_simplify_response(body),parameters,extra_info)

func _users_auth_completed(result: Dictionary, parameters: Dictionary, extra_info: Dictionary) -> void:
	authorized_username = parameters["username"] if result["success"] == "true" else ""
	authorized_user_token = parameters["user_token"] if result["success"] == "true" else ""
		
		
		
