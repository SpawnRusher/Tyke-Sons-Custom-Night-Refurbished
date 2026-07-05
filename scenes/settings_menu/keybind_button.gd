extends Button

@export var settings_menu: Control
@export var group_name: String = "keybinds"
@export var setting_name: String
@export var setting_label: RichTextLabel
@export var state_label: RichTextLabel

func _ready() -> void:
	_update()
	settings_menu.resetted_to_defaults.connect(_update)
	
func _update() -> void:
	state_label.text = InputMap.action_get_events(setting_name)[0].as_text().trim_suffix(" - Physical")

func _on_pressed() -> void:
	settings_menu.keybind_button.emit(self,group_name,setting_name,setting_label,state_label)
