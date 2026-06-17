extends Node2D

@onready var camera: Camera2D = $Camera/Camera
@onready var fade: ColorRect = $Menu/Fade



func _ready() -> void:
	fade.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(fade,"self_modulate:a",0,0.5)


func _on_settings_button_button_down() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"position:y",720,0.2)


func _on_menu_button_button_down() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"position:y",0,0.2)
