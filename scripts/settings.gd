extends CanvasLayer

@export var settings_list: Control

func _ready() -> void:
	var groups: Array[Node] = settings_list.get_children()
	for i in groups:
		var settings: Array[Node] = i.get_children()
		for setting in settings:
			if setting is OptionButton:
				setting.select(setting.get_item_index(SaveData.settings_data[setting.get_parent().name][setting.name]))
			if setting is Slider:
				setting.value = SaveData.settings_data[setting.get_parent().name][setting.name]
			if setting is CheckBox or setting is CheckButton:
				setting.button_pressed = SaveData.settings_data[setting.get_parent().name][setting.name]
			
func _on_option_button_item_selected(index: int, source: OptionButton) -> void:
	SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,source.get_item_id(index),source.get_parent().name,source.name)

func _on_slider_value_changed(value: int, source: Range) -> void:
	SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,value,source.get_parent().name,source.name)
	var text = source.get_children()[0]
	text.text = text.name + ": " + str(value)

func _on_check_pressed(source: Button) -> void:
	SaveData.change_data(SaveData.FILE_TYPE.SETTINGS,source.button_pressed as int,source.get_parent().name,source.name)
