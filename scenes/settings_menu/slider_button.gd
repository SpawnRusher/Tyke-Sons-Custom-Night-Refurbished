extends Button

@export var settings_menu: Control
@export var group_name: String
@export var setting_name: String
@export var setting_label: RichTextLabel
@export var state_label: RichTextLabel
@export var slider: Range

func _ready() -> void:
	_update()
	settings_menu.resetted_to_defaults.connect(_update)
	
func _update() -> void:
	slider.value = SaveData.settings_data[group_name][setting_name]
	state_label.text = str(int(slider.value))

func _on_slider_value_changed(value: float) -> void:
	settings_menu.slider_button.emit(self,group_name,setting_name,setting_label,state_label,slider)
