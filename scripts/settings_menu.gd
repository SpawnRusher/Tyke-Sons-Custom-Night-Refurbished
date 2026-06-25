extends Control

const QUIETBUTTONPRESS: AudioStream = preload("uid://dubq1cwtm73fs")
const LOUD_BUTTON_PRESS: AudioStream = preload("uid://dljncvmipnl1d")

@onready var tabs_container: TabContainer
@onready var tabs_children: Array[Node]

@onready var slider_button = preload("res://scenes/settings_menu/slider_button.tscn")
@onready var dropdown_button = preload("res://scenes/settings_menu/dropdown_button.tscn")

@onready var toggle_button = preload("res://scenes/settings_menu/toggle_button.tscn")

@onready var keybind_button = preload("res://scenes/settings_menu/keybind_button.tscn")
var remapping = false
var remapping_action = null
var remapping_button = null

var settings_types: Dictionary = {
	"settings": {
		"volume": {
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
		},
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
	},
	"quality_of_life": {
		"auto_restart_on_death": {
			"type":"toggle"
			},
		"skip_loading_night": {
			"type":"toggle"
			},
		"enable_moving_with_keyboard": {
			"type":"toggle"
			},
	},
	"keybinds": {
		"restart_night": {
			"type":"key",
			"physical_keycode":KEY_R
		},
		"return_to_menu": {
			"type":"key",
			"physical_keycode":KEY_F2
		},
		"toggle_lamp": {
			"type":"key",
			"physical_keycode":KEY_SHIFT
			},
		"go_to_sleep": {
			"type":"key",
			"physical_keycode":KEY_B
			},
		"close_curtain": {
			"type":"mouse_button",
			"button_index":1
		},
		"use_flashlight": {
			"type":"mouse_button",
			"button_index":2
		},
		"move_forward": {
			"type":"key",
			"physical_keycode":KEY_W
		},
		"move_left": {
			"type":"key",
			"physical_keycode":KEY_A
		},
		"move_backward": {
			"type":"key",
			"physical_keycode":KEY_S
		},
		"move_right": {
			"type":"key",
			"physical_keycode":KEY_D
		},
	},
	"gamejolt": {
		"username":"",
		"user_token":""
	},
}

func _ready() -> void:
	tabs_container = find_child("TabContainer")
	tabs_children = tabs_container.get_children()
	for tab in tabs_children:
		if tab.name == "Settings":
			_add_settings(tab)
		if tab.name == "Quality of Life":
			_add_qol(tab)
		if tab.name == "Keybinds":
			_add_keybinds(tab)
			
func _input(event: InputEvent) -> void:
	if remapping:
		if event is InputEventKey or event is InputEventMouseButton:
			if event.is_pressed():
				if event is InputEventMouseButton and event.double_click:
					event.double_click = false
				InputMap.action_erase_events(remapping_action)
				InputMap.action_add_event(remapping_action, event)
				_update_action_list(remapping_button, remapping_action, event)
				
				SpecialFunctions.audio(QUIETBUTTONPRESS)
				
				remapping = false
				remapping_action = null
				remapping_button = null
				
				accept_event()

func _add_settings(tab: Node) -> void:
	var vbox = tab.find_child("TabVBox")
	for group in settings_types["settings"]:
		#var divider = group_divider.instantiate()
		#var group_label = divider.find_child("GroupLabel")
		#vbox.add_child(divider)
		#group_label.text = group.capitalize()
		for setting in settings_types["settings"][group]:
			if settings_types["settings"][group][setting]["type"] == "toggle":
				var button:= toggle_button.instantiate()
				vbox.add_child(button)
				var setting_label:= button.find_child("SettingLabel")
				var state_label:= button.find_child("StateLabel")
				button.button_pressed = SaveData.settings_data[group][setting]
				#button.set_tooltip_text(settings_types["settings"][group][setting]["tooltip"])
				setting_label.text = setting.capitalize()
				state_label.text = "OFF" if button.button_pressed == false else "ON"
				button.pressed.connect(_on_button_toggled.bind(button, group, setting, setting_label, state_label))
				
			if settings_types["settings"][group][setting]["type"] == "dropdown":
				var dropdown:= dropdown_button.instantiate()
				vbox.add_child(dropdown)
				var dropdown_box:= dropdown.find_child("Dropdown")
				var dropdown_label:= dropdown.find_child("DropdownLabel")
				dropdown_label.text = setting.capitalize()
				for option in settings_types["settings"][group][setting]["options"]:
					dropdown_box.add_item(option,settings_types["settings"][group][setting]["options"][option])
				#dropdown.set_tooltip_text(settings_types["settings"][group][setting]["tooltip"])
				dropdown_box.select(dropdown_box.get_item_index(SaveData.settings_data[group][setting]))
				dropdown_box.item_selected.connect(_on_dropdown_setting_selected.bind(dropdown_box, group, setting, dropdown_label))
				
			if settings_types["settings"][group][setting]["type"] == "slider":
				var slider_setting:= slider_button.instantiate()
				vbox.add_child(slider_setting)
				var slider:= slider_setting.find_child("Slider")
				var slider_label:= slider_setting.find_child("SliderLabel")
				var slider_value_label:= slider_setting.find_child("SliderValueLabel")
				slider.min_value = settings_types["settings"][group][setting]["min_value"]
				slider.max_value = settings_types["settings"][group][setting]["max_value"]
				slider.value = SaveData.settings_data[group][setting]
				#slider_setting.set_tooltip_text(settings_types["settings"][group][setting]["tooltip"])
				slider_label.text = setting.capitalize()
				slider_value_label.text = str(int(slider.value))
				slider.value_changed.connect(_on_slider_value_changed.bind(slider, group, setting, slider_label, slider_value_label))
								
func _on_slider_value_changed(value, slider: Slider, group, setting, slider_label, slider_value_label) -> void:
	SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,slider.value,group,setting)
	slider_value_label.text = str(int(slider.value))
	SpecialFunctions.audio(QUIETBUTTONPRESS)
	
func _on_dropdown_setting_selected(index, dropdown, group, setting, dropdown_label) -> void:
	SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,dropdown.get_item_id(index),group,setting)
	SpecialFunctions.audio(QUIETBUTTONPRESS)
	
func _add_qol(tab: Node) -> void:
	for setting in settings_types["quality_of_life"]:
		if settings_types["quality_of_life"][setting]["type"] == "toggle":
			var button:= toggle_button.instantiate()
			var setting_label:= button.find_child("SettingLabel")
			var state_label:= button.find_child("StateLabel")
			
			button.button_pressed = SaveData.settings_data["quality_of_life"][setting]
			setting_label.text = setting.capitalize()
			state_label.text = "OFF" if button.button_pressed == false else "ON"
			tab.find_child("TabVBox").add_child(button)
			button.pressed.connect(_on_button_toggled.bind(button, "quality_of_life", setting, setting_label, state_label))
		
func _on_button_toggled(button: Button, group, setting, setting_label, state_label) -> void:
	setting = setting.to_lower().replace(" ","_")
	SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,button.button_pressed,group,setting)
	state_label.text = "OFF" if button.button_pressed == false else "ON"
	SpecialFunctions.audio(QUIETBUTTONPRESS)

func _add_keybinds(tab: Node) -> void:
	var action_list = InputMap.get_actions()
	var my_actions_index: int = -1
	for action in action_list:
		if action.left(2) != "ui":
			if my_actions_index == -1:
				my_actions_index = action_list.find(action)
	
	for i in action_list.size():
		if my_actions_index > 0:
			action_list.remove_at(0)
			my_actions_index -= 1
	
	for action in action_list:
		var button:= keybind_button.instantiate()
		var action_label:= button.find_child("ActionLabel")
		var input_label:= button.find_child("InputLabel")
		
		action_label.text = action.capitalize()
		
		var action_events = InputMap.action_get_events(action)
		if action_events.size() > 0:
			input_label.text = action_events[0].as_text().trim_suffix(" - Physical")
		else:
			input_label.text = "No Input Bound"
			
		tab.find_child("TabVBox").add_child(button)
		button.pressed.connect(_edit_keybind.bind(button, action))

func _edit_keybind(button: Button, action: String) -> void:
	if not remapping:
		remapping = true
		remapping_action = action
		remapping_button = button
		button.find_child("InputLabel").text = "Press any input..."
		SpecialFunctions.audio(QUIETBUTTONPRESS)

func _update_action_list(button: Button, action: String, event: InputEvent) -> void:
	button.find_child("InputLabel").text = event.as_text().trim_suffix(" - Physical")
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
	
func _on_tab_changed(tab: int, source: TabContainer) -> void:
	SpecialFunctions.audio(LOUD_BUTTON_PRESS)
