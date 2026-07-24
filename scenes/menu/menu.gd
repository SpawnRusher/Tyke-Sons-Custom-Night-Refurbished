extends Node2D

const BUTTON_PRESS_LOUD: AudioStream = preload("uid://dljncvmipnl1d")
const BUTTON_PRESS_BIG: AudioStream = preload("uid://o2ay73rlokbq")

@export var fade: ColorRect
@export var enemy_portrait_grid: GridContainer
@export var enemy_tooltip: RichTextLabel
@export var ver_string: RichTextLabel

@onready var camera: Camera2D = get_viewport().get_camera_2d()
var disable_menu: bool

func _ready() -> void:
	SceneManager.unload_scene("res://scenes/menu/menu.tscn")
	SceneManager.load_scene("res://scenes/later_that_night/later_that_night.tscn")
	SceneManager.load_scene("res://scenes/gamejolt_menu/gamejolt_menu.tscn")
	ver_string.text = ProjectSettings.get_setting("application/config/version")
	fade.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(fade,"self_modulate:a",0,0.5)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
	if OS.is_debug_build():
		if event is InputEventKey and event.is_pressed():
			pass
	
func _on_settings_button_pressed() -> void:
	disable_menu = true
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD)
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"position:y",720,0.2)

func _on_settings_return_to_menu_button_pressed() -> void:
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD)
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"position:y",0,0.2)
	await tween.finished
	disable_menu = false

func _on_start_button_pressed() -> void:
	if not disable_menu:
		disable_menu = true
		SpecialFunctions.create_audio(BUTTON_PRESS_BIG)
		var tween = get_tree().create_tween()
		tween.tween_property(fade,"self_modulate:a",1,0.5)
		await tween.finished
		SceneManager.change_to_scene("res://scenes/later_that_night/later_that_night.tscn")

func _on_enemy_portrait_mouse_entered(source: Control) -> void:
	enemy_tooltip.text = source.enemy_tooltip
	
func _on_enemy_portrait_mouse_exited() -> void:
	enemy_tooltip.text = "Hover over an enemy to see tips!"

func _on_gamejolt_button_pressed() -> void:
	disable_menu = true
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD,0,1,1,0,true,true)
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"position:x",1280,0.2)

func _on_gamejolt_return_to_menu_button_pressed() -> void:
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD,0,1,1,0,true,true)
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"position:x",0,0.2)
	await tween.finished
	disable_menu = false

func _on_statistics_button_pressed() -> void:
	disable_menu = true
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD,0,1,1,0,true,true)
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"position:x",-1280,0.2)

func _on_statistics_return_to_menu_button_pressed() -> void:
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD,0,1,1,0,true,true)
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"position:x",0,0.2)
	await tween.finished
	disable_menu = false
	
