extends Control

const BUTTON_PRESS_QUIET: AudioStream = preload("uid://dubq1cwtm73fs")
const BUTTON_PRESS_LOUD: AudioStream = preload("uid://dljncvmipnl1d")

@onready var tabs_container: TabContainer

var remapping: bool
var remapping_action: String
var remapping_button: Button
var remapping_state_label: RichTextLabel

signal reset_to_defaults(tab_name: String)
signal resetted_to_defaults()
signal toggle_button(button: Button, group_name: String, setting_name: String, setting_label: String, state_label: RichTextLabel)
signal dropdown_button(index: int, button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, state_label: RichTextLabel)
signal slider_button(button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, dropdown: OptionButton)
signal keybind_button(button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, state_label: RichTextLabel)

func _ready() -> void:
	reset_to_defaults.connect(_reset_to_defaults)
	toggle_button.connect(_toggle_button)
	slider_button.connect(_slider_button)
	dropdown_button.connect(_dropdown_button)
	keybind_button.connect(_keybind_button)
		
func _input(event: InputEvent) -> void:
	if remapping:
		if event is InputEventKey or event is InputEventMouseButton:
			if event.is_pressed():
				if event is InputEventMouseButton and event.double_click:
					event.double_click = false
				InputMap.action_erase_events(remapping_action)
				InputMap.action_add_event(remapping_action, event)
				_update_action_list(remapping_button, remapping_state_label, remapping_action, event)
				
				SpecialFunctions.create_audio(BUTTON_PRESS_QUIET)
				
				remapping = false
				remapping_action = ""
				remapping_button = null
				remapping_state_label = null
				
				accept_event()

func _reset_to_defaults(tab_name: String) -> void:
	for setting in SaveData.get_data(SaveData.FILE_TYPE.SETTINGS,[tab_name]):
		SaveData.set_data(SaveData.FILE_TYPE.SETTINGS,[tab_name,setting],SaveData.get_data(SaveData.FILE_TYPE.DEFAULT_SETTINGS,["tab_name","setting"]))
	resetted_to_defaults.emit()

func _keybind_button(button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, state_label: RichTextLabel) -> void:
	if not remapping:
		remapping = true
		remapping_button = button
		remapping_action = setting_name
		remapping_state_label = state_label
		state_label.text = "Press any input..."
		SpecialFunctions.create_audio(BUTTON_PRESS_QUIET)

func _update_action_list(button: Button, state_label, action: String, event: InputEvent) -> void:
	state_label.text = event.as_text().trim_suffix(" - Physical")
	SaveData.set_data(SaveData.FILE_TYPE.SETTINGS,["keybinds",remapping_action],_serialize_input_event(event))
	
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
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD)
	
func _slider_button(button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, state_label: RichTextLabel, slider: Range) -> void:
	SaveData.set_data(SaveData.FILE_TYPE.SETTINGS,[group_name,setting_name],slider.value)
	state_label.text = str(int(slider.value))
	SpecialFunctions.create_audio(BUTTON_PRESS_QUIET)
	
func _dropdown_button(index: int, button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, dropdown: OptionButton) -> void:
	SaveData.set_data(SaveData.FILE_TYPE.SETTINGS,[group_name,setting_name],dropdown.get_item_id(index))
	SpecialFunctions.create_audio(BUTTON_PRESS_QUIET)
	
func _toggle_button(button: Button, group_name: String, setting_name: String, setting_label: RichTextLabel, state_label: RichTextLabel) -> void:
	SaveData.set_data(SaveData.FILE_TYPE.SETTINGS,[group_name,setting_name],button.button_pressed)
	state_label.text = ["OFF","ON"][button.button_pressed as int]
	SpecialFunctions.create_audio(BUTTON_PRESS_QUIET)
