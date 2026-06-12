extends TextureRect
class_name Enemy_Portrait

enum IDS {
	NONE,
	THE_CHIPOMATS,
	FUN_FUNGAL,
	SPRINGCRAB,
	NIGHTMARE_CHIPPER,
	HAPPYSHROOM,
	THE_ROCKSTARS,
	THE_LUMBERERS,
	TOY,
	SEABILL,
	PHANTOM_CHIPOMAT }

@export var enabled: bool
@export var id: IDS

@onready var border: TextureButton = $Portrait_Border

const QUIETBUTTONPRESS = preload("uid://dubq1cwtm73fs")


func _ready() -> void:
	enabled = false
	assert(id > 0,"Enemy ID has not been set for one of the enemy portraits!")

func _process(delta: float) -> void:
	pass
				

func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and border.is_hovered():
		if enabled:
			enabled = false
			Global.ENABLED_IDS[id] = false
			SpecialFunctions.audio(QUIETBUTTONPRESS,1,1,0,0,0,false)
			self.texture.region = Rect2(0,0,120,120)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and border.is_hovered():
		if not enabled:
			enabled = true
			Global.ENABLED_IDS[id] = true
			SpecialFunctions.audio(QUIETBUTTONPRESS,1,1,0,0,0,false)
			self.texture.region = Rect2(120,0,120,120)
