extends Control

const QUIETBUTTONPRESS: AudioStream = preload("uid://dubq1cwtm73fs")
const LOUD_BUTTON_PRESS: AudioStream = preload("uid://dljncvmipnl1d")

@onready var tabs_container: TabContainer

var remapping: bool
var remapping_action: String
var remapping_button: Button
var remapping_state_label: RichTextLabel

@export var username_vbox: VBoxContainer
@export var username_lineedit: LineEdit
@export var user_token_vbox: VBoxContainer 
@export var user_token_lineedit: LineEdit
@export var login_button: Button
@export var auto_login_button: Button
@export var gamejolt_info_text: RichTextLabel

var settings_types: Dictionary = {
	"display": {
		"max_fps" : {
			"type":"slider",
			"min_value":0,
			"max_value":360,
		},
		"window_mode" : {
			"type":"dropdown",
			"options": {
				"Windowed":0,
				"Borderless":3,
				"Exclusive":4
			},
		},
		"vsync_mode" : {
			"type":"dropdown",
			"options": {
				"Disabled":0,
				"Enabled":1,
				"Adaptive":2,
				"Fast":3
			},
		},
		"antialiasing": {
			"type":"toggle"
		},
	},
	"game": {
		"volume": {
			"type":"divider"
		},
		"master_volume": {
			"type":"slider",
			"min_value":0,
			"max_value":100
		},
		"jumpscare_volume": {
			"type":"slider",
			"min_value":0,
			"max_value":100
		},
		"quality_of_life": {
			"type":"divider"
		},
		"auto_restart_on_death": {
			"type":"toggle"
		},
		"skip_loading_night": {
			"type":"toggle"
		},
		"use_old_camera_scrolling": {
			"type":"toggle"
		},
		"movement": {
			"type":"divider"
		},
		"movement_mode": {
			"type":"dropdown",
			"options": {
				"Hover":1,
				"Click":2,
				"Keyboard":3,
				"Hover+Keyboard":4,
				"Click+Keyboard":5
			}
		},
		"forward_screen_margin": {
			"type":"slider",
			"min_value":1,
			"max_value":300
		},
		"left_screen_margin": {
			"type":"slider",
			"min_value":1,
			"max_value":300
		},
		"backward_screen_margin": {
			"type":"slider",
			"min_value":1,
			"max_value":300
		},
		"right_screen_margin": {
			"type":"slider",
			"min_value":1,
			"max_value":300
		}
	},
	"keybinds": {
		"global": {
			"type":"divider"
		},
		"restart_night": {
			"type":"keybind",
		},
		"return_to_menu": {
			"type":"keybind",
		},
		"game": {
			"type":"divider"
		},
		"toggle_lamp": {
			"type":"keybind",
		},
		"go_to_sleep": {
			"type":"keybind",
		},
		"close_curtain": {
			"type":"keybind",
		},
		"use_flashlight": {
			"type":"keybind",
		},
		"movement": {
			"type":"divider"
		},
		"click_move": {
			"type":"keybind",
		},
		"move_forward": {
			"type":"keybind",
		},
		"move_left": {
			"type":"keybind",
		},
		"move_backward": {
			"type":"keybind",
		},
		"move_right": {
			"type":"keybind",
		},
	},
}

signal reset_to_defaults(tab_name: String)
signal resetted_to_defaults()
signal toggle_button(button: Button, group_name: String, setting_name: String, setting_label: String, state_label: RichTextLabel)
signal dropdown_button(index: int, button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, state_label: RichTextLabel)
signal slider_button(button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, dropdown: OptionButton)
signal keybind_button(button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, state_label: RichTextLabel)

func _ready() -> void:
	GameJolt.users_auth_completed.connect(_users_auth_completed)
	reset_to_defaults.connect(_reset_to_defaults)
	toggle_button.connect(_toggle_button)
	slider_button.connect(_slider_button)
	dropdown_button.connect(_dropdown_button)
	keybind_button.connect(_keybind_button)
	
	if GameJolt.authorized_username != "":
		_users_auth_completed({"success":"true"},{"username":GameJolt.authorized_username,"user_token":GameJolt.authorized_user_token})
	elif SaveData.settings_data["gamejolt"]["auto_login"] == true:
		GameJolt.api_request("users","auth",{"username":SaveData.settings_data["gamejolt"]["username"],"user_token":SaveData.settings_data["gamejolt"]["user_token"]})
		
func _input(event: InputEvent) -> void:
	if remapping:
		if event is InputEventKey or event is InputEventMouseButton:
			if event.is_pressed():
				if event is InputEventMouseButton and event.double_click:
					event.double_click = false
				InputMap.action_erase_events(remapping_action)
				InputMap.action_add_event(remapping_action, event)
				_update_action_list(remapping_button, remapping_state_label, remapping_action, event)
				
				SpecialFunctions.audio(QUIETBUTTONPRESS)
				
				remapping = false
				remapping_action = ""
				remapping_button = null
				remapping_state_label = null
				
				accept_event()

func _reset_to_defaults(tab_name: String) -> void:
	for setting in SaveData.settings_data[tab_name]:
		SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,SaveData.default_settings_data[tab_name][setting],tab_name,setting)
	resetted_to_defaults.emit()

func _keybind_button(button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, state_label: RichTextLabel) -> void:
	if not remapping:
		remapping = true
		remapping_button = button
		remapping_action = setting_name
		remapping_state_label = state_label
		state_label.text = "Press any input..."
		SpecialFunctions.audio(QUIETBUTTONPRESS)

func _update_action_list(button: Button, state_label, action: String, event: InputEvent) -> void:
	state_label.text = event.as_text().trim_suffix(" - Physical")
	SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,_serialize_input_event(event),"keybinds",remapping_action)
	
## Converts an InputEvent of type Key or MouseButton into readable data which can be deserialized to create and InputEvent of equal type when loading data. [br]
## [br] Deserialization function is in SaveData.
func _serialize_input_event(event: InputEvent) -> Dictionary:
	var dict: Dictionary
	
	if event is InputEventKey:
		dict["type"] = "key"
		dict["physical_keycode"] = event.physical_keycode
		
	if event is InputEventMouseButton:
		dict["type"] = "mouse_button"
		dict["button_index"] = event.button_index
	
	return dict

func _on_tab_changed(tab: int) -> void:
	SpecialFunctions.audio(LOUD_BUTTON_PRESS,0,1,1,0,0,0,false,true)
	
func _slider_button(button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, state_label: RichTextLabel, slider: Range) -> void:
	SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,slider.value,group_name,setting_name)
	state_label.text = str(int(slider.value))
	SpecialFunctions.audio(QUIETBUTTONPRESS)
	
func _dropdown_button(index: int, button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, dropdown: OptionButton) -> void:
	SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,dropdown.get_item_id(index),group_name,setting_name)
	SpecialFunctions.audio(QUIETBUTTONPRESS)
	
func _toggle_button(button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, state_label: RichTextLabel) -> void:
	SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,button.button_pressed,group_name,setting_name)
	state_label.text = ["OFF","ON"][button.button_pressed as int]
	SpecialFunctions.audio(QUIETBUTTONPRESS)

func _on_login_button_pressed() -> void:
	GameJolt.api_request("users","auth",{"username":username_lineedit.text,"user_token":user_token_lineedit.text})

func _users_auth_completed(result: Dictionary, parameters: Dictionary) -> void:
	if result["success"] == "false":
		gamejolt_info_text.text = "Failed to login with GameJolt. Username or user token may be incorrect."
	else:
		gamejolt_info_text.text = "Logged in successfully as " + parameters["username"] +"!"
		SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,parameters["username"],"gamejolt","username")
		SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,parameters["user_token"],"gamejolt","user_token")
