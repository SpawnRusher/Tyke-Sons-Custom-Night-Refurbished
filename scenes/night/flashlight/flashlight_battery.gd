extends TextureProgressBar

const BUTTON_PRESS_QUIET: AudioStream = preload("uid://dubq1cwtm73fs")
const FLASHLIGHT: AudioStream = preload("uid://b1ly4og0c82sg")
const FLASHLIGHT_DEAD: AudioStream = preload("uid://iwmdlvotnfwa")

var flashlight_state: Global.FLASHLIGHT_STATES

@export var office: AnimatedSprite2D
@export var batteries: TextureProgressBar
@export var batteries_button: TextureButton
@export var batteries_cooldown: float

var current_batteries_cooldown: float
var enable_cooldown: float

func _ready() -> void:
	SignalBus.flashlight_off.connect(_flashlight_off)
	SignalBus.flashlight_on.connect(_flashlight_on)
	SignalBus.phantom_jumpscare.connect(_phantom_jumpscare)
	SignalBus.activate_happyshroom.connect(_activate_happyshroom)

	batteries.max_value = batteries_cooldown

func _process(delta: float) -> void:
	_visibility_checks()
	if flashlight_state == Global.FLASHLIGHT_STATES.ON:
		value -= 15 * delta
		SaveData.set_data(SaveData.FILE_TYPE.SAVE,["statistics","general","flashlight_battery_drained"],15 * delta,SaveData.SET_DATA_SPECIAL.ADD)
	if current_batteries_cooldown < batteries_cooldown:
		current_batteries_cooldown += 1 * delta
	if enable_cooldown > 0:
		enable_cooldown -= 1 * delta
	
func _on_value_changed() -> void:
	if value == 0:
		if flashlight_state == Global.FLASHLIGHT_STATES.ON:
			flashlight_state = Global.FLASHLIGHT_STATES.OFF
			SpecialFunctions.create_audio(FLASHLIGHT_DEAD)
			SignalBus.update_flashlight_state.emit(Global.FLASHLIGHT_STATES.DEAD)
	
func _flashlight_off(cooldown:= 0.0) -> void:
	if value > 0:
		if flashlight_state == Global.FLASHLIGHT_STATES.ON:
			enable_cooldown = cooldown
			flashlight_state = Global.FLASHLIGHT_STATES.OFF
			SpecialFunctions.create_audio(FLASHLIGHT)
			SignalBus.update_flashlight_state.emit(flashlight_state)
	
func _flashlight_on() -> void:
	if value > 0 and enable_cooldown <= 0:
		if flashlight_state == Global.FLASHLIGHT_STATES.OFF:
			flashlight_state = Global.FLASHLIGHT_STATES.ON
			SpecialFunctions.create_audio(FLASHLIGHT)
			SignalBus.update_flashlight_state.emit(flashlight_state)
			SaveData.set_data(SaveData.FILE_TYPE.SAVE,["statistics","general","flashlight_flashes"],1,SaveData.SET_DATA_SPECIAL.ADD)
	else:
		SpecialFunctions.create_audio(FLASHLIGHT_DEAD)

func _phantom_jumpscare() -> void:
	value -= 30

func _on_batteries_button_pressed() -> void:
	if current_batteries_cooldown >= batteries_cooldown:
		flashlight_state = Global.FLASHLIGHT_STATES.OFF
		SignalBus.update_flashlight_state.emit(flashlight_state)
		value = 100.0
		current_batteries_cooldown = 0
		SpecialFunctions.create_audio(BUTTON_PRESS_QUIET)
		SaveData.set_data(SaveData.FILE_TYPE.SAVE,["statistics","general","flashlight_batteries_picked_up"],1,SaveData.SET_DATA_SPECIAL.ADD)

func _visibility_checks() -> void:
	batteries.visible = false
	if office.animation == "open_b":
		batteries.visible = true
		batteries.value = 0
		if flashlight_state == Global.FLASHLIGHT_STATES.ON:
			batteries.value = current_batteries_cooldown
			
func _activate_happyshroom() -> void:
	value = 100
	flashlight_state = Global.FLASHLIGHT_STATES.OFF
	SignalBus.update_flashlight_state.emit(flashlight_state)
