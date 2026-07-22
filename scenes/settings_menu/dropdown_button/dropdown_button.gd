extends Button

@export var settings_menu: Control
@export var group_name: String
@export var setting_name: String
@export var setting_label: RichTextLabel
@export var dropdown: OptionButton

func _ready() -> void:
	_update()
	settings_menu.resetted_to_defaults.connect(_update)

func _update() -> void:
	dropdown.select(dropdown.get_item_index(SaveData.get_data(SaveData.FILE_TYPE.SETTINGS,[group_name,setting_name])))
	
func _on_dropdown_item_selected(index: int) -> void:
	settings_menu.dropdown_button.emit(index,self,group_name,setting_name,setting_label,dropdown)
