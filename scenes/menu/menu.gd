extends Node2D

const LOUD_BUTTON_PRESS: AudioStream = preload("uid://dljncvmipnl1d")
const BIG_BUTTON_PRESS: AudioStream = preload("uid://o2ay73rlokbq")

@export var fade: ColorRect
@export var enemy_portrait_grid: GridContainer
@export var enemy_tooltip: RichTextLabel
@export var ver_string: RichTextLabel

@onready var camera: Camera2D = get_viewport().get_camera_2d()

func _ready() -> void:
	SceneManager.unload_scene("res://scenes/menu/menu.tscn")
	SceneManager.load_scene("res://scenes/later_that_night/later_that_night.tscn")
	SceneManager.load_scene("res://scenes/gamejolt_menu/gamejolt_menu.tscn")
	ver_string.text = ProjectSettings.get_setting("application/config/version")
	fade.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(fade,"self_modulate:a",0,0.5)
	
func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event is InputEventKey and event.is_pressed():
			if event.keycode == KEY_F:
				GameJolt.api_request("trophies","fetch",{"username":GameJolt.authorized_username,"user_token":GameJolt.authorized_user_token})
	
func _on_settings_button_button_down() -> void:
	SpecialFunctions.create_audio(LOUD_BUTTON_PRESS)
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"position:y",720,0.2)

func _on_menu_button_button_down() -> void:
	SpecialFunctions.create_audio(LOUD_BUTTON_PRESS)
	var tween = get_tree().create_tween()
	tween.tween_property(camera,"position:y",0,0.2)

func _on_start_button_pressed() -> void:
	SpecialFunctions.create_audio(BIG_BUTTON_PRESS)
	var tween = get_tree().create_tween()
	tween.tween_property(fade,"self_modulate:a",1,0.5)
	await tween.finished
	SceneManager.change_to_scene("res://scenes/scenes/later_that_night.tscn")

func _on_enemy_portrait_mouse_entered(source: Control) -> void:
	enemy_tooltip.text = source.enemy_tooltip
	
func _on_enemy_portrait_mouse_exited() -> void:
	enemy_tooltip.text = "Hover over an enemy to see tips!"

static func _on_gamejolt_button_pressed() -> void:
	SpecialFunctions.create_audio(LOUD_BUTTON_PRESS,0,1,1,0,true,true)
	SceneManager.change_to_scene("res://scenes/gamejolt_menu/gamejolt_menu.tscn")
