extends TextureButton 
class_name Enemy_Portrait

@onready var border = $Portrait_Border

var enabled: bool

func _ready() -> void:
	border.button_down.connect(_update_enabled)
	
func _update_enabled():
	button_pressed = !button_pressed
