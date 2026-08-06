extends Button

@export var settings_menu: Control
@export var group_name: String = "keybinds"
@export var setting_name: String
@export var setting_label: RichTextLabel
@export var state_label: RichTextLabel

func _ready() -> void:
	_update()
	if settings_menu.has_signal("reset_to_defaults"):
		settings_menu.reset_to_defaults.connect(_reset_to_defaults)
	
func _update() -> void:
	state_label.text = InputMap.action_get_events(setting_name)[0].as_text().trim_suffix(" - Physical")

func _on_pressed() -> void:
	settings_menu.keybind_button.emit(self,group_name,setting_name,setting_label,state_label)
	
func _reset_to_defaults(tab_name: String) -> void:
	if tab_name != group_name:
		return
		
	SaveData.set_data(SaveData.FILE_TYPE.SETTINGS,[group_name,setting_name],SaveData.get_data(SaveData.FILE_TYPE.DEFAULT_SETTINGS,[group_name,setting_name]),SaveData.SET_DATA_SPECIAL.KEYBIND)
	InputMap.action_erase_events(setting_name)
	InputMap.action_add_event(setting_name, SaveData.get_data(SaveData.FILE_TYPE.SETTINGS,[group_name,setting_name],SaveData.GET_DATA_SPECIAL.KEYBIND))
	_update()
