extends PanelContainer

@export var check_button: CheckButton

func _ready() -> void:
	check_button.button_pressed = GameInfo.happyshroom_test_mode
	
func _on_check_button_toggled(toggled_on: bool) -> void:
	GameInfo.happyshroom_test_mode = toggled_on
