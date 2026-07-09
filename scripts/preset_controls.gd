extends Panel

@export_group("Nodes")
@export var text: RichTextLabel
@export var presets: Node
@export var left_button: TextureButton
@export var right_button: TextureButton

@onready var preset_list: Array[Node] = presets.get_children()

var current_preset: int = -1

func _ready() -> void:
	if Global.current_preset != -1:
		_set_preset(Global.current_preset)
	else:
		_set_preset(0)

func _on_preset_button_left_pressed() -> void:
	pass # Replace with function body.

func _on_preset_button_right_pressed() -> void:
	pass # Replace with function body.

func _set_preset(index: int) -> void:
	current_preset = index
	text.text = preset_list[index].name
