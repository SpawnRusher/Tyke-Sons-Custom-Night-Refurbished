extends Node2D

const LOUD_BUTTON_PRESS: AudioStream = preload("uid://dljncvmipnl1d")
const BIG_BUTTON_PRESS: AudioStream = preload("uid://o2ay73rlokbq")

@export var fade: ColorRect
@export var enemy_portrait_grid: GridContainer
@export var enemy_tooltip: RichTextLabel
@export var ver_string: RichTextLabel

@onready var camera: Camera2D = get_viewport().get_camera_2d()

func _ready() -> void:
	SceneManager.unload_scene("res://scenes/menu.tscn")
	SceneManager.load_scene("res://scenes/later_that_night.tscn")
	ver_string.text = ProjectSettings.get_setting("application/config/version")
	fade.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(fade,"self_modulate:a",0,0.5)
	
func _on_settings_button_button_down() -> void:
	SpecialFunctions.audio(LOUD_BUTTON_PRESS,0,1,1,0,0,0,true)
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"position:y",720,0.2)

func _on_menu_button_button_down() -> void:
	SpecialFunctions.audio(LOUD_BUTTON_PRESS,0,1,1,0,0,0,true)
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"position:y",0,0.2)

func _on_start_button_pressed() -> void:
	SpecialFunctions.audio(BIG_BUTTON_PRESS,0,1,1,0,0,0,true)
	var tween = get_tree().create_tween()
	tween.tween_property(fade,"self_modulate:a",1,0.5)
	await tween.finished
	SceneManager.change_to_scene("res://scenes/later_that_night.tscn")

func _on_enemy_portrait_mouse_entered(source: Control) -> void:
	enemy_tooltip.text = source.enemy_tooltip
	
func _on_enemy_portrait_mouse_exited() -> void:
	enemy_tooltip.text = "Hover over an enemy to see tips!"
