extends Node2D

const LOUD_BUTTON_PRESS = preload("uid://dljncvmipnl1d")

@onready var camera: Camera2D = $Camera/Camera
@onready var fade: ColorRect = $Camera/Fade

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

func _on_start_button_pressed() -> void:
	SpecialFunctions.audio(LOUD_BUTTON_PRESS,0,1,1,0,0,0,true)
	var tween = get_tree().create_tween()
	tween.tween_property(fade,"self_modulate:a",1,0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/later_that_night.tscn")
