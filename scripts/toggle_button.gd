extends Button

@export var settings_menu: Control
@export var group_name: String
@export var setting_name: String
@export var setting_label: RichTextLabel
@export var state_label: RichTextLabel

func _ready() -> void:
	_update()
	if button_pressed == true:
		GameJolt.request_users_auth.emit(SaveData.settings_data["gamejolt"]["username"],SaveData.settings_data["gamejolt"]["user_token"])
	settings_menu.resetted_to_defaults.connect(_update)
	
func _update() -> void:
	button_pressed = SaveData.settings_data[group_name][setting_name]
	state_label.text = ["OFF","ON"][button_pressed as int]
	
func _on_toggled(toggled_on: bool) -> void:
	settings_menu.toggle_button.emit(self,group_name,setting_name,setting_label,state_label)
