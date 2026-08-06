extends Button

@export var settings_menu: Control
@export var group_name: String
@export var setting_name: String
@export var setting_label: RichTextLabel
@export var dropdown: OptionButton

func _ready() -> void:
	_update()
	if settings_menu.has_signal("reset_to_defaults"):
		settings_menu.reset_to_defaults.connect(_reset_to_defaults)

func _update() -> void:
	dropdown.select(dropdown.get_item_index(SaveData.get_data(SaveData.FILE_TYPE.SETTINGS,[group_name,setting_name])))
	
func _on_dropdown_item_selected(index: int) -> void:
	settings_menu.dropdown_button.emit(index,self,group_name,setting_name,setting_label,dropdown)

func _reset_to_defaults(tab_name: String) -> void:
	if tab_name != group_name:
		return
	SaveData.set_data(SaveData.FILE_TYPE.SETTINGS,[group_name,setting_name],SaveData.get_data(SaveData.FILE_TYPE.DEFAULT_SETTINGS,[group_name,setting_name]))
	_update()
