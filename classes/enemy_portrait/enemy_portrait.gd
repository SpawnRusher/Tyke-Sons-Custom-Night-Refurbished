class_name Enemy_Portrait extends TextureRect

const BUTTON_PRESS_QUIET: AudioStream = preload("uid://dubq1cwtm73fs")

@export var enabled: bool
@export var border: TextureButton
@export var enemy_id: Enemy.ENEMY_IDS
@export_multiline var enemy_tooltip: String
@export var menu: Node2D

signal enemy_portrait_toggled(enemy_portrait: Enemy_Portrait)

func _ready() -> void:
	assert(enemy_id > -1,"Enemy ID has not been set for one of the enemy portraits!")

func _input(event: InputEvent) -> void:
	if not menu.disable_menu:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and border.is_hovered():
			if enabled:
				toggle(false)
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and border.is_hovered():
			if not enabled:
				toggle(true)

func toggle(state: bool, quiet:= false) -> void:
	if enabled == state:
		return
	enabled = state
	texture.region = Rect2(120 * int(enabled),0,120,120)
	if not quiet:
		SpecialFunctions.create_audio(BUTTON_PRESS_QUIET)
		enemy_portrait_toggled.emit(self)
