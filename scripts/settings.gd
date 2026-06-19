extends CanvasLayer

@onready var settings = $Settings

func _ready() -> void:
	var children = settings.get_children()
	for i in children:
		if i is OptionButton:
			i.select(i.get_item_index(SaveData.config_file.get_value("settings",i.name,0)))
		if i is Slider:
			i.value = SaveData.config_file.get_value("settings",i.name,SaveData.default_values[i.name])
			
func _on_option_button_item_selected(index: int, source: OptionButton) -> void:
	SaveData.change_data("settings",source.name,source.get_item_id(index),SaveData.default_values[source.name])

func _on_slider_value_changed(value: float, source: Range) -> void:
	SaveData.change_data("settings",source.name,source.value,SaveData.default_values[source.name])
