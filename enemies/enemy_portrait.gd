extends TextureRect
class_name Enemy_Portrait

@export var enabled: bool
@export var enemy_id: Enemy.ENEMY_IDS
@export var enemy_tooltip: String

@onready var border: TextureButton = $PortraitBorder

const QUIETBUTTONPRESS: AudioStream = preload("uid://dubq1cwtm73fs")


func _ready() -> void:
	enabled = false
	assert(enemy_id > Enemy.ENEMY_IDS.NONE,"Enemy ID has not been set for one of the enemy portraits!")
	tooltip_text = enemy_tooltip

func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and border.is_hovered():
		if enabled:
			enabled = false
			Global.ENABLED_IDS[enemy_id] = false
			SpecialFunctions.audio(QUIETBUTTONPRESS)
			texture.region = Rect2(0,0,120,120)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and border.is_hovered():
		if not enabled:
			enabled = true
			Global.ENABLED_IDS[enemy_id] = true
			SpecialFunctions.audio(QUIETBUTTONPRESS)
			texture.region = Rect2(120,0,120,120)
