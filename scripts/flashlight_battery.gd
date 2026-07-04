extends TextureProgressBar

const QUIETBUTTONPRESS: AudioStream = preload("uid://dubq1cwtm73fs")
const FLASHLIGHT: AudioStream = preload("uid://b1ly4og0c82sg")
const FLASHLIGHT_DEAD: AudioStream = preload("uid://iwmdlvotnfwa")

var flashlight_state: bool

@export var office: AnimatedSprite2D
@export var batteries: TextureProgressBar
@export var batteries_button: TextureButton
@export var batteries_cooldown: float

var current_batteries_cooldown: float

func _ready() -> void:
	SignalBus.flashlight_off.connect(flashlight_off)
	SignalBus.flashlight_on.connect(flashlight_on)
	SignalBus.phantom_jumpscare.connect(phantom_jumpscare)
	SignalBus.activate_happyshroom.connect(_activate_happyshroom)

	batteries.max_value = batteries_cooldown

func _process(delta: float) -> void:
	visibility_checks()
	if flashlight_state:
		value -= 5 * delta
	if current_batteries_cooldown < batteries_cooldown:
		current_batteries_cooldown += 1 * delta
	
func _on_value_changed(bat: float) -> void:
	if bat == 0:
		if flashlight_state:
			flashlight_state = false
			SpecialFunctions.audio(FLASHLIGHT_DEAD)
			SignalBus.update_flashlight_state.emit(false)
			SignalBus.flashlight_dead.emit()
	
func flashlight_off() -> void:
	if value > 0:
		if flashlight_state:
			flashlight_state = false
			SpecialFunctions.audio(FLASHLIGHT)
		SignalBus.update_flashlight_state.emit(flashlight_state)
	
func flashlight_on() -> void:
	if value > 0:
		if not flashlight_state:
			flashlight_state = true
			SpecialFunctions.audio(FLASHLIGHT)
		SignalBus.update_flashlight_state.emit(flashlight_state)
	else:
		SpecialFunctions.audio(FLASHLIGHT_DEAD)

func phantom_jumpscare() -> void:
	value -= 30

func _on_batteries_button_pressed() -> void:
	if current_batteries_cooldown >= batteries_cooldown:
		value = 100.0
		current_batteries_cooldown = 0
		SpecialFunctions.audio(QUIETBUTTONPRESS)

func visibility_checks() -> void:
	batteries.visible = false
	if office.animation == "open_b":
		batteries.visible = true
		batteries.value = 0
		if flashlight_state:
			batteries.value = current_batteries_cooldown
			
func _activate_happyshroom() -> void:
	value = 100
	flashlight_state = false
	SignalBus.update_flashlight_state.emit(flashlight_state)
