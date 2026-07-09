extends TextureRect
class_name Enemy_Portrait

@export var enabled: bool
@export var border: TextureButton
@export var enemy_id: Enemy.ENEMY_IDS
@export_multiline var enemy_tooltip: String

const QUIETBUTTONPRESS: AudioStream = preload("uid://dubq1cwtm73fs")

func _ready() -> void:
	assert(enemy_id > Enemy.ENEMY_IDS.NOT_SET,"Enemy ID has not been set for one of the enemy portraits!")

func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and border.is_hovered():
		if enabled:
			toggle(false)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and border.is_hovered():
		if not enabled:
			toggle(true)

func toggle(state: bool, quiet:= false) -> void:
	if enabled == state:
		return
	if not state:
		enabled = false
		texture.region = Rect2(0,0,120,120)
	else:
		enabled = true
		texture.region = Rect2(120,0,120,120)
	if not quiet:
		SpecialFunctions.audio(QUIETBUTTONPRESS)
	SignalBus.enemy_portrait_toggled.emit(self)
