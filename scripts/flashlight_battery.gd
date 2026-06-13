extends TextureProgressBar

const QUIETBUTTONPRESS = preload("uid://dubq1cwtm73fs")

var using_flashlight: bool

@export var office: AnimatedSprite2D
@export var batteries: TextureProgressBar
@export var batteries_button: TextureButton
@export var batteries_cooldown: float

const FLASHLIGHT = preload("uid://b1ly4og0c82sg")

var current_batteries_cooldown: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.flashlight_off.connect(flashlight_off)
	SignalBus.flashlight_on.connect(flashlight_on)
	SignalBus.phantom_jumpscare.connect(phantom_jumpscare)

	batteries.max_value = batteries_cooldown

func _process(delta: float) -> void:
	visibility_checks()
	if using_flashlight == true:
		value -= 5 * delta
	if value == 0:
		if using_flashlight == true:
			using_flashlight = false
			SpecialFunctions.audio(FLASHLIGHT)
			SignalBus.update_flashlight_state.emit(false)
	if current_batteries_cooldown < batteries_cooldown:
		current_batteries_cooldown += 1 * delta
	

func flashlight_off() -> void:
	if value > 0:
		if using_flashlight == true:
			using_flashlight = false
			SpecialFunctions.audio(FLASHLIGHT)
		SignalBus.update_flashlight_state.emit(using_flashlight)
	
func flashlight_on() -> void:
	if value > 0:
		if using_flashlight == false:
			using_flashlight = true
			SpecialFunctions.audio(FLASHLIGHT)
		SignalBus.update_flashlight_state.emit(using_flashlight)

func phantom_jumpscare() -> void:
	value -= 30


func _on_batteries_button_pressed() -> void:
	if current_batteries_cooldown == batteries_cooldown:
		value = 100.0
		current_batteries_cooldown = 0
		SpecialFunctions.audio(QUIETBUTTONPRESS)

func visibility_checks():
	if office.animation != "open_b":
		batteries.visible = false
	else:
		batteries.visible = true
		batteries.value = 0
		if office.frame == 1:
			batteries.value = current_batteries_cooldown
	
